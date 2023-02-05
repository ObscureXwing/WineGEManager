# WineGEManager

Bash script which makes it easy to download Wine-GE, synthesise the prefix, and run applications inside the prefix.

## How to use


``` ./WineGEManager.sh update ``` this command will fetch latest available Wine-GE, DXVK-Async, VKD3D-Proton, MF-Install, VCRHyb, and automatically download all the stuff

``` ./WineGEManager.sh update legacy ``` does the same, but with little difference, instead of getting latest available DXVK and VKD3D, for legacy PC's and Laptop's 1.10.3 and 2.6 will be downloaded respectively instead of new ones

``` ./WineGEManager.sh build ``` will start the synthesis process of Wine prefix, this also implies the automatic installation of all the basic components necessary to run games and programs inside the prefix, including the automatic installation of DXVK, VKD3D-Proton, Media Foundation libraries and VCRHyb

``` ./WineGEManager.sh run path/to/file ``` performs the process of starting an application with all the necessary basic environment variables to get a high performance of applications running through Wine-GE, this also implies that owners of laptops with Nvidia D-GPU do not need to use prime-run, also applications will run with 60 FPS locked

``` ./WineGEManager.sh run uninstaller ``` menu through which you can install(opens the file picker, it will be the same as running run path/to/filename.exe command) and uninstall programs

## Tips and tricks

``` ./WineGEManager.sh build x ``` you can leave it empty, and use "build" as is, without additional arguments, or instead of "x" you can also add the necessary components whose installation takes priority over that of the other components the script is programmed to install.

for example :

``` ./WineGEManager.sh build dotnet20 ``` installs .NET Framework 2.0, and only then proceeds to install other components

``` ./WineGEManager.sh build dotnet35 ``` the same, but for .NET Framework 3.5

## Requirements

``` unzip ``` ``` unrar ``` ``` tar ``` ``` xz ``` ``` gzip ``` ``` wget ``` ``` curl ``` ``` winetricks ``` ``` F-Sync supported kernel ```

## Installation

Run the following commands in your favourite terminal emulator :

``` mkdir WineGEManager && cd WineGEManager ``` 

(for the script to work correctly, its installation and first run have to in an empty directory)

``` wget https://raw.githubusercontent.com/ObscureXwing/WineGEManager/main/WineGEManager.sh ``` <br>
``` chmod +x WineGEManager.sh ```

## Troubleshooting

``` ./WineGEManager.sh build directmusic dsound ``` helps to fix the sound in some games, but also breaks the sound in some other games, for example in Juiced when you install directmusic and dsound, sounds start playing correctly, but at the same time in Prototype game the sound becomes just awful, use with caution

``` ./WineGEManager.sh run winecfg ``` with this command you can run the Wine configuration manager and, for example, if you run a rather old game where the sound doesn't work at all, you can change the Windows version to XP and this may solve your sound problems

## TODO

- implement automatic installation of system dependencies for Wine-GE to work correctly on freshly installed systems.
- add an argument that would call a menu where the user could configure in detail the behavior of the script when launching programs/games, such as the FPS limit, the number of processor threads on which the process will be allowed to run, and so on.
