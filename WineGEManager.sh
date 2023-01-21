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

strip-link()
{
	if [[ ! -z "$(echo $1 | grep https)" ]]; then
		StripLink=$(echo "$1" | awk -F '/' '{print $NF}')
		#StripLink=${StripLink//'.tar.xz'/""}
		if [[ ! -z "$DXVK" ]]; then echo "$DXVK"; fi
	fi
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
	if [[ ! -z "$1" ]]; then 
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
		if [[ -f "$2" ]]; then cd $(dirname "$2"); fi
		wine "${@:2}"
	fi
}

base_build()
{
	eval base_prep
	export PATH=$PWD/Wine/bin/:$PATH
	export WINEPREFIX=$PWD/PFX
	winetricks "${@:2}"
	winetricks quartz xact xact_x64 d3dx9 ffdshow d3dx10 d3dx10_43 d3dx11_42 d3dx11_43 d3dcompiler_42 d3dcompiler_43 d3dcompiler_46 d3dcompiler_47
	wine VCRHyb/VCRHyb64.exe
	winetricks corefonts mfc42 msxml3 msxml4 msxml6 binkw32 win10
	bash DXVK/setup_dxvk.sh install
	bash VKD3D/setup_vkd3d_proton.sh install
	bash MF/mf-install.sh
	echo "==================="
	echo "done."
}

init_script()
{
	if [[ "$WRKDIR" != "." ]]; then cd "$WRKDIR"; fi
	if [[ "$1" = "update" ]]; then eval base_update "$@"; fi
	if [[ "$1" = "build" ]]; then eval base_build "$@"; fi
	if [[ "$1" = "run" && ! -z "$2" ]]; then eval base_run "$@"; fi
}

export WRKDIR="$(dirname -- "${BASH_SOURCE[0]}")"
export DXVK_Legacy="https://github.com/Sporif/dxvk-async/releases/download/1.10.2/dxvk-async-1.10.2.tar.gz"
export VKD3D_Legacy="https://github.com/HansKristian-Work/vkd3d-proton/releases/download/v2.6/vkd3d-proton-2.6.tar.zst"
export MF="https://github.com/z0z0z/mf-install/archive/refs/heads/master.zip"
eval init_script "$@"
