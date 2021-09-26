# Microgames in TF2 // microtf2

A custom gamemode for Team Fortress 2 - Players compete against each other to get the most points by playing a series of rapid fire microgames in order to win the round!

## How to install the gamemode
We have created an install guide to help you install the gamemode - see wiki page here: https://github.com/gemidyne/microtf2/wiki/How-to-install-the-gamemode

## Commands 
See wiki page for more information: https://github.com/gemidyne/microtf2/wiki/Console-Commands

## Console Variables
See wiki page for more information: https://github.com/gemidyne/microtf2/wiki/Console-Variables

## Repository info

The /src folder contains the plugin source-code. 
The /assets folder contains data relating to the map, plugin overlays and sounds. It is strongly recommended that you use https://www.gemidyne.com/projects/tsukuru/ to build the map and pack in the necessary assets.

The "master" branch is the latest stable version of the gamemode. We recommend you use this branch on your game servers.
The "dev" branch is used for the latest development version of the gamemode. This branch contains work in progress projects so may be uncompilable, untested and not be the best experience for your players. We recommend you use the master branch over the dev branch.

## SourceMod Extension / Plugin Dependencies

The gamemode utilises the following extensions and plugins to run:

- SDKHooks extension (2.1 or above)
- SteamWorks extension - https://forums.alliedmods.net/showthread.php?t=229556 (Used for setting the game description)
- TF2Items extension - https://forums.alliedmods.net/showthread.php?t=115100 (Used for blocking wearables)
- TF2Attributes plugin - https://github.com/FlaminSarge/tf2attributes (Used for applying attributes to weapons)
- TFEconData plugin - https://github.com/nosoop/SM-TFEconData (Used for giving weapons to players)
- (Windows only) host_timescale_fix plugin - https://forums.alliedmods.net/showthread.php?t=324264 (Fixes a host_timescale issue only on Windows SRCDS installs. Not required if you are running the gamemode on Linux)

If you intend to use the SDK plugin for developing your own gamemodes or minigames, you will need:

- Sound Info Library extension: https://forums.alliedmods.net/showthread.php?t=105816   https://github.com/bcserv/soundlib (Used for determining sound file length for themes and minigames)

## Map Development

The map's master VMF file lives in /assets/warioware_redux_master.vmf - we use https://www.gemidyne.com/projects/tsukuru/ to build dev & release versions of the map and pack in data. You can import our map compile settings into Tsukuru by importing the warioware_redux_master.tsumc in the /assets/ folder - and then fix the file paths to be correct for your repository path. 

Our workflow for dev maps / release maps is to pack all necessary data into the BSP file, and then repack the BSP file. You can do all this by using Tsukuru. Packing all sounds, textures, models into the BSP file and repacking it means players will only need to download a single file to play the gamemode.

We intend to use [Hammer++](https://ficool2.github.io/HammerPlusPlus-Website/index.html) going forward for map development, as this version of Hammer has many fixes over the stock version of Hammer bundled with TF2. If you want to use the original Hammer, you can - we have not tested this however.

## Want to help translate the gamemode into other languages? 

We'd love to have you on board! If you are interested in contributing translations, there are two ways you can do it: 

1. We can add you onto our gemidyne.com Translator Tool which makes editing translations super quick and easy - [click this link](https://github.com/gemidyne/microtf2/issues/new/choose) and choose **Become a translator**.
2. You can add your own language "microtf2.phrases.txt" file built from the english file into your own translation folder - this way is more manual but you can contribute via pull requests if you want 

#### We currently have translators for the following languages:

- [X] French
- [X] Italian
- [X] Spanish
- [X] Russian
- [X] Portuguese
- [X] Brazilian Portuguese
- [X] Polish
- [X] German

## Credits

View the full gamemode credits here: https://www.gemidyne.com/projects/microtf2/credits

Resurrected by Gemidyne Softworks.
