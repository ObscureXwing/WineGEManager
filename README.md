# WineGEManager

Bash script which makes it easy to download Wine-GE, synthesise the prefix, and run applications inside the prefix.

## How to use


``` ./WineGEManager.sh update ``` this command will fetch latest available Wine-GE, DXVK-Async, VKD3D-Proton, MF-Install, VCRHyb, and automatically download all the stuff

``` ./WineGEManager.sh update legacy ``` does the same, but with little difference, instead of getting latest available DXVK and VKD3D, for legacy PC's and Laptop's 1.10.2 and 2.6 will be downloaded respectively instead of new ones

``` ./WineGEManager.sh build ``` will start the synthesis process of Wine prefix, this also implies the automatic installation of all the basic components necessary to run games and programs inside the prefix, including the automatic installation of DXVK, VKD3D-Proton, Media Foundation libraries and VCRHyb

``` ./WineGEManager.sh run path/to/file ``` performs the process of starting an application with all the necessary basic environment variables to get a high performance of applications running through Wine-GE, this also implies that owners of laptops with Nvidia D-GPU do not need to use prime-run, also applications will run with 60 FPS locked

## Requirements

``` unzip ``` ``` unrar ``` ``` tar ``` ``` xz ``` ``` gzip ``` ``` wget ``` ``` curl ``` ``` winetricks ``` ``` F-Sync supported kernel ```

## Installation

Run the following commands in your favourite terminal emulator :

``` mkdir WineGEManager && cd WineGEManager ``` 

(for the script to work correctly, its installation and first run have to in an empty directory)

``` wget https://raw.githubusercontent.com/ObscureXwing/WineGEManager/main/WineGEManager.sh ``` <br>
``` chmod +x WineGEManager.sh ```
