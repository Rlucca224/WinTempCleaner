# ================================================================
#  WinTempCleaner - Uninstaller
#  Usage: irm https://raw.githubusercontent.com/Rlucca224/WinTempCleaner/main/uninstall.ps1 | iex
# ================================================================

$ErrorActionPreference = "Stop"

$destDir = "C:\ProgramData\DeleteTemp"
$regKey  = "HKCR:\DesktopBackground\Shell\DeleteTemp"

# ── Banner ───────────────────────────────────────────────────────
Clear-Host
Write-Host ""
Write-Host "  =============================================" -ForegroundColor Cyan
Write-Host "         WinTempCleaner  -  Uninstaller        " -ForegroundColor Cyan
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

# ── Check if installed ────────────────────────────────────────────
Write-Host ""
Write-Host "  [*] Checking if WinTempCleaner is installed..." -ForegroundColor Yellow
$regExists  = Test-Path $regKey
$dirExists  = Test-Path $destDir

if (-not $regExists -and -not $dirExists) {
    Write-Host "  [!] WinTempCleaner does not appear to be installed." -ForegroundColor Red
    Write-Host "      Nothing to remove." -ForegroundColor Red
    Write-Host ""
    exit 0
}
Write-Host "  [+] Installation found." -ForegroundColor Green

# ── Remove registry key ───────────────────────────────────────────
Write-Host ""
Write-Host "  [*] Removing registry entries..." -ForegroundColor Yellow
try {
    if (Test-Path $regKey) {
        Remove-Item -Path $regKey -Recurse -Force
        Write-Host "  [+] Registry key removed." -ForegroundColor Green
    } else {
        Write-Host "  [~] Registry key not found, skipping." -ForegroundColor Gray
    }
} catch {
    Write-Host "  [!] ERROR removing registry key: $_" -ForegroundColor Red
    exit 1
}

# ── Remove files ──────────────────────────────────────────────────
Write-Host ""
Write-Host "  [*] Removing files..." -ForegroundColor Yellow
try {
    if (Test-Path $destDir) {
        Remove-Item -Path $destDir -Recurse -Force
        Write-Host "  [+] Removed: $destDir" -ForegroundColor Green
    } else {
        Write-Host "  [~] Folder not found, skipping." -ForegroundColor Gray
    }
} catch {
    Write-Host "  [!] ERROR removing files: $_" -ForegroundColor Red
    exit 1
}

# ── Verify clean ──────────────────────────────────────────────────
Write-Host ""
Write-Host "  [*] Verifying removal..." -ForegroundColor Yellow
$allGone = $true

if (Test-Path $regKey) {
    Write-Host "  [!] Registry key still exists." -ForegroundColor Red
    $allGone = $false
} else {
    Write-Host "  [+] Registry key: removed." -ForegroundColor Green
}

if (Test-Path $destDir) {
    Write-Host "  [!] Folder still exists." -ForegroundColor Red
    $allGone = $false
} else {
    Write-Host "  [+] Folder: removed." -ForegroundColor Green
}

# ── Result ────────────────────────────────────────────────────────
Write-Host ""
Write-Host "  =============================================" -ForegroundColor Cyan
if ($allGone) {
    Write-Host "   Uninstall complete!" -ForegroundColor Green
    Write-Host "   Your system is exactly as it was before." -ForegroundColor Green
} else {
    Write-Host "   Uninstall finished with errors." -ForegroundColor Red
    Write-Host "   Check the messages above for details." -ForegroundColor Red
}
Write-Host "  =============================================" -ForegroundColor Cyan
Write-Host ""
