# ============================================================
#  isoCMD - Build Script
#  Requires: Windows ADK + WinPE add-on, MSYS2 (UCRT64 gcc)
#  Run in PowerShell as Administrator
# ============================================================

$ErrorActionPreference = "Stop"

# ---------- Config ----------
$WinPERoot = "C:\WinPE_amd64"
$MountDir  = "$WinPERoot\mount"
$WimFile   = "$WinPERoot\media\sources\boot.wim"
$SrcDir    = "$PSScriptRoot\src"
$OutDir    = "$([Environment]::GetFolderPath('MyDocuments'))\isoCMD"
$OutISO    = "$OutDir\isoCMD.iso"
$MsysBash  = "C:\msys64\usr\bin\bash.exe"
$ADKRoot   = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit"
$MakeMedia = "$ADKRoot\Windows Preinstallation Environment\MakeWinPEMedia.cmd"
$Sys32     = "$MountDir\Windows\System32"

function Step($n, $msg) { Write-Host "[$n/5] $msg" -ForegroundColor Cyan }
function Fail($msg)     { Write-Host "`nERROR: $msg`n" -ForegroundColor Red; exit 1 }

# ---------- Checks ----------
$admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $admin)                 { Fail "Run PowerShell as Administrator." }
if (-not (Test-Path $MsysBash))  { Fail "MSYS2 not found at C:\msys64." }
if (-not (Test-Path $MakeMedia)) { Fail "Windows ADK / WinPE add-on not found." }

# ADK env so MakeWinPEMedia finds its tools
$env:WinPERoot   = "$ADKRoot\Windows Preinstallation Environment"
$env:OSCDImgRoot = "$ADKRoot\Deployment Tools\amd64\Oscdimg"
$env:PATH += ";$env:OSCDImgRoot"

Write-Host ""

# First run: create the WinPE working folder
if (-not (Test-Path $WimFile)) {
    if (Test-Path $WinPERoot) { Fail "$WinPERoot exists but has no boot.wim. Delete that folder and run again." }
    Write-Host "First run: creating WinPE working folder..." -ForegroundColor Yellow
    & cmd /c "`"$ADKRoot\Windows Preinstallation Environment\copype.cmd`" amd64 `"$WinPERoot`""
    if (-not (Test-Path $WimFile)) { Fail "copype failed." }
}

# ---------- 1. Compile ----------
Step 1 "Compiling launcher.exe..."
Remove-Item "$SrcDir\launcher.exe" -ErrorAction SilentlyContinue
$SrcUnix = "/" + $SrcDir.Substring(0,1).ToLower() + ($SrcDir.Substring(2) -replace '\\','/')
$env:MSYSTEM = "UCRT64"
$env:CHERE_INVOKING = "1"
& $MsysBash -lc "gcc -O2 -s -o '$SrcUnix/launcher.exe' '$SrcUnix/launcher.c' -luser32"
if (-not (Test-Path "$SrcDir\launcher.exe")) { Fail "Compile failed. Check gcc is installed in MSYS2 UCRT64." }

# ---------- 2. Mount ----------
Step 2 "Mounting WIM..."
$mounted = dism /Get-MountedWimInfo | Select-String -SimpleMatch $MountDir
if ($mounted) {
    Write-Host "      Stale mount found, discarding it..." -ForegroundColor Yellow
    dism /Unmount-Image /MountDir:"$MountDir" /Discard | Out-Null
    dism /Cleanup-Wim | Out-Null
}
New-Item -ItemType Directory -Force -Path $MountDir | Out-Null
dism /Mount-Image /ImageFile:"$WimFile" /Index:1 /MountDir:"$MountDir"
if ($LASTEXITCODE -ne 0) { Fail "Mount failed." }

try {
    # ---------- 3. Copy ----------
    Step 3 "Copying files..."
    Copy-Item "$SrcDir\isoCMD.cmd"   "$Sys32\isoCMD.cmd"   -Force
    Copy-Item "$SrcDir\winpeshl.ini" "$Sys32\winpeshl.ini" -Force
    Copy-Item "$SrcDir\launcher.exe" "$Sys32\launcher.exe" -Force
}
catch {
    Write-Host "Copy failed, discarding changes..." -ForegroundColor Yellow
    dism /Unmount-Image /MountDir:"$MountDir" /Discard | Out-Null
    Fail $_.Exception.Message
}

# ---------- 4. Commit ----------
Step 4 "Committing image (takes a minute)..."
dism /Unmount-Image /MountDir:"$MountDir" /Commit
if ($LASTEXITCODE -ne 0) { Fail "Commit failed. Run 'dism /Get-MountedWimInfo' before retrying." }

# ---------- 5. ISO ----------
Step 5 "Building ISO..."
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
& cmd /c "`"$MakeMedia`" /ISO /F `"$WinPERoot`" `"$OutISO`""
if (-not (Test-Path $OutISO)) { Fail "ISO build failed." }

Write-Host "`nDone! ISO ready at $OutISO`n" -ForegroundColor Green