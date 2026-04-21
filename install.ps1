# ================================================================
#  WinTempCleaner - Installer
#  Usage: irm https://raw.githubusercontent.com/Rlucca224/WinTempCleaner/main/install.ps1 | iex
# ================================================================

$ErrorActionPreference = "Stop"

# ── Config ───────────────────────────────────────────────────────
$repoBase  = "https://raw.githubusercontent.com/Rlucca224/WinTempCleaner/main"
$destDir   = "C:\ProgramData\DeleteTemp"
$files     = @("DeleteTemp.ps1", "Launcher.vbs", "icon.ico")
$regKey    = "HKCR:\DesktopBackground\Shell\DeleteTemp"

# ── Banner ───────────────────────────────────────────────────────
Clear-Host
Write-Host ""
Write-Host "  =============================================" -ForegroundColor Cyan
Write-Host "         WinTempCleaner  -  Installer          " -ForegroundColor Cyan
Write-Host "  =============================================" -ForegroundColor Cyan
Write-Host ""

# ── Admin check ──────────────────────────────────────────────────
Write-Host "  [*] Checking administrator privileges..." -ForegroundColor Yellow
$isAdmin = ([Security.Principal.WindowsPrincipal] `
            [Security.Principal.WindowsIdentity]::GetCurrent() `
           ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host ""
    Write-Host "  [!] ERROR: This script must be run as Administrator." -ForegroundColor Red
    Write-Host "      Right-click PowerShell -> Run as administrator, then try again." -ForegroundColor Red
    Write-Host ""
    exit 1
}
Write-Host "  [+] Running as Administrator." -ForegroundColor Green

# ── Create destination folder ─────────────────────────────────────
Write-Host ""
Write-Host "  [*] Creating destination folder..." -ForegroundColor Yellow
if (-not (Test-Path $destDir)) {
    New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    Write-Host "  [+] Created: $destDir" -ForegroundColor Green
} else {
    Write-Host "  [+] Already exists: $destDir" -ForegroundColor Green
}

# ── Download files ────────────────────────────────────────────────
Write-Host ""
Write-Host "  [*] Downloading files from GitHub..." -ForegroundColor Yellow
foreach ($file in $files) {
    $url  = "$repoBase/$file"
    $dest = "$destDir\$file"
    try {
        Write-Host "      -> $file" -ForegroundColor Gray
        Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing
        Write-Host "  [+] Downloaded: $file" -ForegroundColor Green
    } catch {
        Write-Host "  [!] ERROR downloading $file : $_" -ForegroundColor Red
        exit 1
    }
}

# ── Registry entries ──────────────────────────────────────────────
Write-Host ""
Write-Host "  [*] Writing registry entries..." -ForegroundColor Yellow

try {
    # Create main key
    if (-not (Test-Path $regKey)) {
        New-Item -Path $regKey -Force | Out-Null
    }
    Set-ItemProperty -Path $regKey -Name "(Default)"    -Value "Delete Temporary Files"
    Set-ItemProperty -Path $regKey -Name "Icon"         -Value "C:\ProgramData\DeleteTemp\icon.ico"
    Set-ItemProperty -Path $regKey -Name "HasLUAShield" -Value ""

    # Remove Position if it exists from old installs
    Remove-ItemProperty -Path $regKey -Name "Position" -ErrorAction SilentlyContinue

    # Create command subkey
    $cmdKey = "$regKey\command"
    if (-not (Test-Path $cmdKey)) {
        New-Item -Path $cmdKey -Force | Out-Null
    }
    Set-ItemProperty -Path $cmdKey -Name "(Default)" `
        -Value "wscript.exe `"C:\ProgramData\DeleteTemp\Launcher.vbs`""

    Write-Host "  [+] Registry entries written successfully." -ForegroundColor Green
} catch {
    Write-Host "  [!] ERROR writing registry: $_" -ForegroundColor Red
    exit 1
}

# ── Verify ────────────────────────────────────────────────────────
Write-Host ""
Write-Host "  [*] Verifying installation..." -ForegroundColor Yellow
$allGood = $true

foreach ($file in $files) {
    $path = "$destDir\$file"
    if (Test-Path $path) {
        Write-Host "  [+] Found: $path" -ForegroundColor Green
    } else {
        Write-Host "  [!] Missing: $path" -ForegroundColor Red
        $allGood = $false
    }
}

if (Test-Path $regKey) {
    Write-Host "  [+] Registry key verified." -ForegroundColor Green
} else {
    Write-Host "  [!] Registry key missing." -ForegroundColor Red
    $allGood = $false
}

# ── Result ────────────────────────────────────────────────────────
Write-Host ""
Write-Host "  =============================================" -ForegroundColor Cyan
if ($allGood) {
    Write-Host "   Installation complete!" -ForegroundColor Green
    Write-Host "   Right-click your Desktop to use the new option." -ForegroundColor Green
} else {
    Write-Host "   Installation finished with errors." -ForegroundColor Red
    Write-Host "   Check the messages above for details." -ForegroundColor Red
}
Write-Host "  =============================================" -ForegroundColor Cyan
Write-Host ""
