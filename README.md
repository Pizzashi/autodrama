# Autodrama
Finally, an automatic KissAsian downloader.

## Prerequisites
- Need to set `dom.allow_scripts_to_close_windows = true` in `about:config`.
- Default Browser must be Mozilla Firefox (for now).

## How to build
### For Autodrama
- There are three files needed: `Autodrama.exe`, `resources.dll`, and `aria2c.exe`. Copy them in one directory, and you're good to go.
- To compile `resources.dll`, go to `Autodrama\Resources`, then just run `packer.ahk`. A `resources.dll` file will be generated in the same directory.
- For aria2c, download the latest version from this [repository](https://github.com/aria2/aria2).
### For Autodrama Helper
- Download from Mozilla add on from [here](https://addons.mozilla.org/en-US/developers/).
- If you want to compile the add-on yourself, compile all the files in `AutodramaHelper` into a `.zip` file, and then go to [debugging](about:debugging#/runtime/this-firefox), and then click "Load Temporary Add-on..."
