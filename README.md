# Autodrama
[![TestedOn](https://img.shields.io/badge/Tested_on-Windows_10_and_11-brightgreen.svg?logo=Windows)](https://github.com/Baconfry/autodrama/releases)
[![made-with-AHK](https://img.shields.io/badge/Made%20with-AHK%20v1.1.33.09-blue)](http://autohotkey.com)

Finally, an automatic KissAsian downloader.

## Prerequisites
- For now, only Mozilla Firefox is supported.
- The **Default Browser** must be Mozilla Firefox (for now).
- You need to set `dom.allow_scripts_to_close_windows = true` in `about:config`.
- Under KissAsian [settings](https://kissasian.li/Profile) (account is required), the `Default server` must be set to **FE**, **SB**, or **SW** . `Default quality` can be ignored, as the app always prioritizes 360p, then 480p, then 720p, and then 1080p.

## Versions to pair
- Autodrama will work with the helper if their versions are both `x.x.x` (e.g. 1.0.5). The fourth digit is not important. For example, Autodrama `v0.5.0.1` will work with Autodrama Helper `v0.5.0.4`.

## Notes
- The helper "downloads" `.autodramatext` files in your Firefox download directory. These files are used to communicate information such as download links to the main application. The main application automatically cleans them so you should not have to worry about these files. Unfortunately, this is currently the only (practical) means of communication with the main application, and this method clutters up your Firefox download history.
  
## How to build
### For Autodrama
- There are three files needed: `Autodrama.exe`, `resources.dll`, and `aria2c.exe`. The application is completely portable; nothing is written in the Registry. Copy the three files in one directory, and you're good to go.
  - To build `Autodrama.exe`, simply compile `Autodrama.ahk` using AutoHotKey (the released versions are using AutoHotKey version 1.1.33.09). [BinMod.ahk](https://github.com/AutoHotkey/Ahk2Exe/blob/master/BinMod.ahk) is now required for compiling since the app handles sensitive data. Download the script and install it according to the instructions.
  - `Autodrama.exe` requires you to create a file named `TopicKeys.lic` that contains the ntfy topics. That is, it should contain `static daisyTopic := "topickey1" ` and ` static baconfryTopic := "topickey2"`.
  - To compile `resources.dll`, go to `Autodrama\Resources`, then just run `packer.ahk`. A `resources.dll` file will then be generated in the same directory.
  - For aria2c, download the latest version from this [repository](https://github.com/aria2/aria2). Or you can use the compiled binary at `Autodrama\External Requirements`.
### For Autodrama Helper
- Download the Mozilla addon from [here](https://addons.mozilla.org/en-US/developers/). Simple drag the `.xpi` file into the Mozilla Firefox window.
- If you want to compile the add-on yourself, compile all the files in `AutodramaHelper` into a `.zip` file, then go to [debugging](about:debugging#/runtime/this-firefox), and then click "Load Temporary Add-on..."
  - Alternatively, you can "load" the temporary addon by loading any file of the addon source, such as `manifest.json`.

## Special Thanks
This app uses the free and open-source [ntfy](https://ntfy.sh/). HUGE thanks to the awesome author, binwiederhier.

## Dedication
I dedicate this application to my loving mother who has worked hard all her life for my sister and I. Despite being a single mom, she's providing us with all our needs and most of our wants. You deserve all the dramas in the world, mom.
