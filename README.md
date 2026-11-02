# isoCMD
Minimal Windows PE based bootable ISO, boots straight into a fullscreen command prompt with drive detection.

## What it does

- Boots into a fullscreen black console (no desktop or GUI)
- Scans for Windows installations on the drives
- Lets you switch to a detected installation with one keypress
- Drops you at a clean command prompt on the selected drive

## Requirements

- Windows host
- [Microsoft ADK](https://learn.microsoft.com/en-us/windows-hardware/get-started/adk-install) + the WinPE add-on
- [MSYS2 UCRT64](https://www.msys2.org/) with gcc (run `pacman -S mingw-w64-ucrt-x86_64-gcc` inside the MSYS2 shell)
- [Rufus](https://rufus.ie/) (or whatever you want) to flash the ISO

## Build

1. Clone this repo

   ```powershell
   git clone https://github.com/ismocc/isoCMD.git
   cd isoCMD
   ```

2. Open PowerShell as Administrator in the repo folder and run:

   ```powershell
   .\build.ps1
   ```

3. Flash `Documents\isoCMD\isoCMD.iso` to a USB

> If PowerShell says running scripts is disabled, run this once:
> `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`

## Project structure

```
isoCMD/
├── build.ps1          # Automated build script
├── LICENSE
├── README.md
└── src/
    ├── isoCMD.cmd     # Boot script
    ├── launcher.c     # Borderless fullscreen cmd launcher
    └── winpeshl.ini   # WinPE launcher config
```

## License

[MIT](LICENSE)
