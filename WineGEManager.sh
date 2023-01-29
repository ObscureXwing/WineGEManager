#!/bin/bash

: << 'LICENSE&COPYRIGHT'
    "WineGEManager" is a Bash script which makes it easy to download Wine-GE, synthesise the prefix, and run applications inside the prefix
    Copyright (C) 2023  ObscureXwing

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
LICENSE&COPYRIGHT

#==========
# [system]
#==========

gem_detectsystem()
{
	if [[ -f "/usr/bin/xbps-install" ]]; then echo "void"; fi
	if [[ -f "/usr/bin/pacman" ]]; then echo "arch"; fi
	if [[ -f "/usr/bin/apt" && "$(cat "/etc/os-release" | grep "PRETTY_NAME")" == *"Mint"* ]]; then echo "mint"; fi
	if [[ -f "/usr/bin/apt" && "$(cat "/etc/os-release" | grep "PRETTY_NAME")" == *"Ubuntu"* ]]; then echo "ubuntu"; fi
}

gem_checkdeps()
{
	pkgs_void="fontconfig fontconfig-32bit lcms2 lcms2-32bit libxml2 libxml2-32bit libXcursor libXcursor-32bit libXrandr libXrandr-32bit libXdamage libXdamage-32bit libXi libXi-32bit gettext gettext-32bit freetype freetype-32bit glu glu-32bit libSM libSM-32bit libgcc libgcc-32bit libpcap libpcap-32bit FAudio FAudio-32bit desktop-file-utils giflib giflib-32bit libpng libpng-32bit libldap libldap-32bit gnutls gnutls-32bit mpg123 libmpg123 libmpg123-32bit libopenal libopenal-32bit v4l-utils v4l-utils-32bit libpulseaudio libpulseaudio-32bit libgpg-error libgpg-error-32bit alsa-plugins alsa-plugins-32bit alsa-plugins-pulseaudio alsa-plugins-pulseaudio-32bit alsa-lib alsa-lib-32bit libjpeg-turbo libjpeg-turbo-32bit sqlite sqlite-32bit libXcomposite libXcomposite-32bit libXinerama libXinerama-32bit libgcrypt libgcrypt-32bit ncurses ncurses-base ncurses-libs ncurses-libs-32bit ocl-icd ocl-icd-32bit libxslt libxslt-32bit libva libva-32bit libva-glx libva-glx-32bit libva-intel-driver libva-intel-driver-32bit libva-vdpau-driver libva-vdpau-driver-32bit gtk+3 gtk+3-32bit gst-plugins-base1 gst-plugins-base1-32bit gst-plugins-good1 gst-plugins-good1-32bit gst-plugins-bad1 gst-plugins-bad1-32bit gst-plugins-ugly1 gst-plugins-ugly1-32bit vulkan-loader vulkan-loader-32bit"

	pkgs_arch="fontconfig lib32-fontconfig lcms2 lib32-lcms2 libxml2 lib32-libxml2 libxcursor lib32-libxcursor libxrandr lib32-libxrandr libxdamage lib32-libxdamage libxi lib32-libxi gettext lib32-gettext freetype2 lib32-freetype2 glu lib32-glu libsm lib32-libsm gcc-libs lib32-gcc-libs libpcap lib32-libpcap faudio lib32-faudio desktop-file-utils giflib lib32-giflib libpng lib32-libpng libldap lib32-libldap gnutls lib32-gnutls mpg123 lib32-mpg123 openal lib32-openal v4l-utils lib32-v4l-utils libpulse lib32-libpulse libgpg-error lib32-libgpg-error alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib libjpeg-turbo lib32-libjpeg-turbo sqlite lib32-sqlite libxcomposite lib32-libxcomposite libxinerama lib32-libxinerama libgcrypt lib32-libgcrypt ncurses lib32-ncurses ocl-icd lib32-ocl-icd libxslt lib32-libxslt libva lib32-libva gtk3 lib32-gtk3 gst-plugins-base-libs lib32-gst-plugins-base-libs gst-plugins-good lib32-gst-plugins-good gst-plugins-bad gst-plugins-ugly vulkan-icd-loader lib32-vulkan-icd-loader"

	case $(gem_detectsystem) in
		void) eval sudo xbps-install -S "$pkgs_void" ;;
		arch) eval sudo pacman -Sy "$pkgs_arch" ;;
	esac
}

gem_install()
{
	if [[ -d "$1/x64" && -d "$1/x32" || -d "$1/x64" && -d "$1/x86" ]]; then
		export FARG="$1"
		export PATH=$PWD/Wine/bin/:$PATH
		export WINEPREFIX=$PWD/PFX
		export WINEDEBUG=-all
		export WINEDLLOVERRIDES="mscoree,mshtml="
		export REGKEY='HKEY_CURRENT_USER\Software\Wine\DllOverrides'
		export X86PLATFORMLIBS="x32"
		if [[ ! -d "$1/$X86PLATFORMLIBS" ]]; then X86PLATFORMLIBS="x86"; fi
		if [[ -d "PFX/drive_c/windows/syswow64" ]]; then PFXArch="64bit"; else PFXArch="32bit"; fi
		case $PFXArch in
			64bit)
				ls -1 $1/x64/ | xargs -0 -d '\n' -P1 -I % bash -c 'LIBNAME="$(basename % .dll)" && cp -v --reflink=auto "$FARG/x64/%" PFX/drive_c/windows/system32/ && wine reg add "$REGKEY" /v "$LIBNAME" /d native /f'
				ls -1 $1/$X86PLATFORMLIBS/ | xargs -0 -d '\n' -P1 -I % bash -c 'LIBNAME="$(basename % .dll)" && cp -v --reflink=auto "$FARG/$X86PLATFORMLIBS/%" PFX/drive_c/windows/syswow64/ && wine reg add "$REGKEY" /v "$LIBNAME" /d native /f' ;;
			32bit)
				ls -1 $1/$X86PLATFORMLIBS/ | xargs -0 -d '\n' -P1 -I % bash -c 'LIBNAME="$(basename % .dll)" && cp -v --reflink=auto "$FARG/$X86PLATFORMLIBS/%" PFX/drive_c/windows/system32/ && wine reg add "$REGKEY" /v "$LIBNAME" /d native /f' ;;
		esac
	fi
}

#==========
# [wine]
#==========

github_link-hack()
{
	if [[ ! -z "$(echo $1 | grep https)" ]]; then
		LinkHack=$(curl -s $(curl -s "$1" | grep '<include-fragment loading="lazy" src="https://github.com' | awk -F '"' '{print $6}' | head -1) | grep "a href" | awk -F '="/|" rel=' '{print $2}' | grep .tar | grep -v "archive")
		if [[ ! -z "$LinkHack" ]]; then LinkHack="https://github.com/$LinkHack" && echo "$LinkHack"; fi
	fi
}

get-latest_wine-ge()
{
	WINELink=`github_link-hack "https://github.com/GloriousEggroll/wine-ge-custom/releases"`
	if [[ ! -z "$WINELink" ]]; then echo "$WINELink"; fi
}

get-latest_dxvk()
{
	DXVK=`github_link-hack "https://github.com/Sporif/dxvk-async/releases"`
	if [[ ! -z "$DXVK" ]]; then echo "$DXVK"; fi
}

get-latest_vkd3d()
{
	DXVK=`github_link-hack "https://github.com/HansKristian-Work/vkd3d-proton/releases"`
	if [[ ! -z "$DXVK" ]]; then echo "$DXVK"; fi
}

get-latest-vcrhyb()
{
	VCRHyb="$(curl -s https://www.upload.ee/files/14035569/VCR_Hyb_x86_x64_09.04.2022.rar.html | awk -F 'a id="d_l" href="|" ' '{print $2}' | grep .rar | grep https)"
	if [[ ! -z "$VCRHyb" ]]; then echo "$VCRHyb"; fi
}

FindFile()
{
	if [[ ! -z "$1" ]]; then
		FindFile=$(ls | grep "$1" | head -1)
		if [[ ! -z "$FindFile" ]]; then echo "$FindFile"; fi
	fi
}

base_update()
{
	if [[ -z "$2" ]]; then
		if [[ -z $(FindFile wine-lutris) ]]; then wget $(get-latest_wine-ge); fi
		if [[ -z $(FindFile dxvk-async) ]]; then wget $(get-latest_dxvk); fi
		if [[ -z $(FindFile vkd3d-proton) ]]; then wget $(get-latest_vkd3d); fi
		if [[ ! -f "master.zip" ]]; then wget "$MF"; fi
		if [[ ! -f "VCR_Hyb_x86_x64_09.04.2022.rar" ]]; then wget $(get-latest-vcrhyb); fi
	fi
	if [[ "$2" = "legacy" ]]; then
		if [[ -z $(FindFile wine-lutris) ]]; then wget $(get-latest_wine-ge); fi
		if [[ -z $(FindFile dxvk-async) ]]; then wget "$DXVK_Legacy"; fi
		if [[ -z $(FindFile vkd3d-proton) ]]; then wget "$VKD3D_Legacy"; fi
		if [[ ! -f "master.zip" ]]; then wget "$MF"; fi
		if [[ ! -f "VCR_Hyb_x86_x64_09.04.2022.rar" ]]; then wget $(get-latest-vcrhyb); fi
	fi 
}

base_prep()
{
	if [[ ! -d "Wine" && ! -z $(FindFile wine-lutris) ]]; then
		Wine=$(FindFile wine-lutris)
		tar -xvf $Wine
		rm $Wine
		Wine=$(FindFile lutris)
		mv $Wine Wine/
	fi
	if [[ ! -d "DXVK" && ! -z $(FindFile dxvk-async) ]]; then
		DXVK=$(FindFile dxvk-async)
		tar -xvf $DXVK
		rm $DXVK
		DXVK=$(FindFile dxvk-async)
		mv $DXVK DXVK/
	fi
	if [[ ! -d "VKD3D-Proton" && ! -z $(FindFile vkd3d-proton) ]]; then
		VKD3D=$(FindFile vkd3d-proton)
		tar -I 'zstd' -xvf $VKD3D
		rm $VKD3D
		VKD3D=$(FindFile vkd3d-proton)
		mv $VKD3D VKD3D/
	fi
	if [[ ! -d "MF" && -f "master.zip" ]]; then
		MF="master.zip"
		unzip $MF
		rm $MF
		MF="mf-install-master"
		mv $MF MF
	fi
	if [[ ! -d "VCRHyb" && -f "VCR_Hyb_x86_x64_09.04.2022.rar" ]]; then
		VCRHyb="VCR_Hyb_x86_x64_09.04.2022.rar"
		unrar e $VCRHyb
		rm $VCRHyb
		rm Html.nfo
		rm Run
		VCRHyb="VCRHyb64.exe"
		mkdir VCRHyb
		mv $VCRHyb VCRHyb/
	fi
}

base_run()
{
	if [[ ! -z "$@" ]]; then 
		export RUNPATH="${@:2}"
		export PATH=$PWD/Wine/bin/:$PATH
		export WINEPREFIX=$PWD/PFX
		export WINEFSYNC=1
		export DXVK_ASYNC=1
		export DXVK_FRAME_RATE=60
		export DXVK_LOG_LEVEL=none
		export DXVK_LOG_PATH=none
		export __NV_PRIME_RENDER_OFFLOAD=1
		export __VK_LAYER_NV_optimus=NVIDIA_only
		export __GLX_VENDOR_LIBRARY_NAME=nvidia
		if [[ -f "$RUNPATH" ]]; then cd "$(dirname "$RUNPATH")"; fi
		wine "$(basename "$RUNPATH")"
	fi
}

base_build()
{
	eval base_prep
	export PATH=$PWD/Wine/bin/:$PATH
	export WINEPREFIX=$PWD/PFX
	if [[ ! -z "$2" ]]; then winetricks "${@:2}"; fi
	winetricks quartz xact xact_x64 d3dx9 ffdshow d3dx10 d3dx10_43 d3dx11_42 d3dx11_43 d3dcompiler_42 d3dcompiler_43 d3dcompiler_46 d3dcompiler_47
	wine VCRHyb/VCRHyb64.exe
	winetricks corefonts mfc42 msxml3 msxml4 msxml6 binkw32 win10
	if [[ -f "DXVK/setup_dxvk.sh" ]]; then bash DXVK/setup_dxvk.sh install; else eval gem_install "DXVK"; fi
	if [[ -f "VKD3D/setup_vkd3d_proton.sh" ]]; then bash VKD3D/setup_vkd3d_proton.sh install; else eval gem_install "VKD3D"; fi
	bash MF/mf-install.sh
	echo "==================="
	echo "done."
}

init_script()
{
	if [[ ! -z "$LNK" ]]; then WRKDIR="$(dirname -- "$LNK")"; else WRKDIR="$(dirname -- "$WRKPATH")"; fi
	if [[ "$WRKDIR" != "." ]]; then cd "$WRKDIR"; fi
	if [[ "$1" = "update" ]]; then eval base_update "$@"; fi
	if [[ "$1" = "build" ]]; then eval base_build "$@"; fi
	if [[ "$1" = "run" && ! -z "$2" ]]; then eval base_run "$@"; fi
	if [[ "$1" = "checkdeps" ]]; then eval gem_checkdeps "$@"; fi
}

export WRKPATH="${BASH_SOURCE[0]}"
export LNK="$(readlink "$WRKPATH")"
export DXVK_Legacy="https://github.com/Sporif/dxvk-async/releases/download/1.10.2/dxvk-async-1.10.2.tar.gz"
export VKD3D_Legacy="https://github.com/HansKristian-Work/vkd3d-proton/releases/download/v2.6/vkd3d-proton-2.6.tar.zst"
export MF="https://github.com/z0z0z/mf-install/archive/refs/heads/master.zip"
eval init_script "$@"
