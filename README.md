# MDOS1SD

Modification of original MDOS 1.0 (01-Sep-92) for SD cards on DIVSD/DIVMMC compatible interfaces, based on dissasebly made by Flyyn, with routine names same as in book "Komentovany vypis MDOSu" (Kvaksoft 1995)

## QUICKSTART:

* Put .D40/.D80 disk images on FAT32 formated sd card
* Disk images can be anywhere on any path on sd card.
* Disk images **must be linear/not fragmented** - Use some file defragment utility, or preferably sd card where no file deletions was done
* Load mdos1sd (.tap or basic loader)
* Use NMI button to access NMI menu for selecting disk image
* Uses DIVxxx MAPRAM mode, so it depends on your interface how handles RESET (Use EXTRA button on eLeMeNt ZX / MB03)
* If you want to format disk image, **FORMAT only disk images with exact size 368640b (D40) or 737280b (D80)**
* Here is [Original D40 manual](https://mts.speccy.cz/doc/d40manu.pdf) ([mts.speccy.cz](https://mts.speccy.cz/)) (SK language)


##### TIP:

Use separate partition for disk images, where you will not delete files. Then you can safely use esxdos with deleting/modifying/replacing files


## Features:

* Works on **FAT32** partitioned or non-partitioned SD cards
* Supports up to 4 **primary** partitions (type 0xC - Fat32LBA) on both SD drives
* Disk images of type .D40 or .D80 can be **anywhere on sd card/path**
* Disk images **must be linear / not fragmented**
* NMI menu for disk image selection
* Write protect of disk images
* Modified basic FORMAT command for work with disk images (~10 seconds on 720K image)
* FORMAT ignores SINGLE SIDED parameter
* FORMAT only standard 9 sectors/40(80) tracks/2 sides, based on disk image size
* No extra features added into original MDOS
* No DMA used, possibly works on most DIVxxx sd interfaces (but i tested it only on eLeMeNt ZX), propably works ZX Next too
* Uses DIVxxx banks 0-3:
  * 3 for "eeprom part"
  * 0 for mdos rom/sram part
  * 1 for NMI menu
  * 2 for storing ZX screen during NMI
  * You can change this in mdos1sd.asm and mdosload.asm equates
* Works with 128K machines (unlike original D40/D80  interface due to ports conflicts) - but not 128K basic (of course)
* On reset, there is "positive blue screen" instead of original "red hell screen". But it is much faster than original reset on D40/D80 hardware, so propably it will not annoy anyone
* On eLeMeNt ZX and MB03, use EXTRA button for reset (normal reset resets DIVxxx mapram)
* On eLeMeNt ZX and MB03, can run with zx rom in URAM

## NMIMENU:

* use CURSOR for move, ENTER for confirm, BREAK to exit
* Main menu
  * W to toggle write protect
  * E to eject
  * S to make (original) MDOS SNAPSHOT (inside disk image)
  * BREAK to exit
* File browser
  * Shows only .D40 or .D80 files
  * No files sorting.
  * D for select drive/volume (partition)
  * R in drive select dialog reinitialize / reload SD drives
  * BREAK return to main menu without changing disk image

## FAQ:

* Q: Some software crashes when using NMI
* A: Yes. Seems like a original behavior. If I will be directed "why, if and how this can be fixed", I will try to fix MDOS
* Q: Why disk images must be linear/non-fragmented?
* A: Because MDOS1SD only knows about begining LBA address of disk image, to which is simply added LOGICAL sector during READ/WRITE. There is no FAT32 cluster work inside, only in NMI browser
* Q: Some disk image / software is not working
* A: It is propably using non-standard format or some copy-protection. If this disk image/software does not work in MDOS3 or emulators, it will not work here too.
* Q: Why it is not named MDOS4SD?
* A: Because higher version number evokes "more features, more fixes". This is not cause. It is simply "MDOS1 modified for SD card". So I opted to leave MDOS4 name for original authors of MDOS3 (or anyone else)
* Q: How i can put software into disk images?
* A: Use tools for manipulating .D80 images. On esxdos, you can use EXCELLENT .D80 utility from SCJoe
* Q: Will it supports original floppy drives?
* A: No.
* Q: Is there possibility to create empty disk image from NMI menu?
* A: No. But there is workaround - you can copy existing .D40/.D80 disk image in esxdos, and FORMAT it in MDOS
* Q: Some disk images from iternet are smaller than D40/D80 format. Can i use them?
* A: Yes. BUT, do not try to FORMAT them, or write on them. It will overwrite part of of next disk image on FAT32
* Q: On some SD card it is not working
* A: It is possible. Some SD cards needs many T states to initialize, current version opted to max 512 cycles in WAIT commands. It is fixable, but it needs to be tested / reported

## How to build:

* use SJASM
* compile mdos1sd.asm
* compile nmimenu.asm (org must be 8192/0x2000)
  * uses zx.fnt file (standart zx font format)
* THEN compile mdosload.asm
  * uses compiled mdos1sd.bin
  * uses compiled nmimenu.bin
  * uses middle part of logo.scr file

## License

Use it as you wish, also "I am not responsible for any data or hair loss" Etc. If you will use all or some part of code, just mention original source. Thank you.


> *Source code is currently in a bit "Bordel state", there is many places for improvement, optimization and cleanup, also in mdos source code there are still original routines, which are no longer used. But it works ;-)*
