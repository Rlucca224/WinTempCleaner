# ============================================================
#  DeleteTemp.ps1  -  WinTempCleaner
#  Always run as Administrator (managed by Launcher.vbs)
# ============================================================

$ErrorActionPreference = "SilentlyContinue"

$paths = @(
    $env:TEMP,
    $env:TMP,
    "$env:LOCALAPPDATA\Temp",
    "$env:LOCALAPPDATA\Microsoft\Windows\INetCache",
    "$env:LOCALAPPDATA\Microsoft\Windows\Temporary Internet Files",
    "$env:LOCALAPPDATA\CrashDumps",
    "$env:SystemRoot\Temp",
    "$env:SystemRoot\Logs\CBS",
    "$env:SystemRoot\Minidump",
    "$env:SystemRoot\SoftwareDistribution\Download"
)

$totalRemoved = 0
$totalSize    = 0

foreach ($path in $paths) {
    if (-not (Test-Path $path)) { continue }

    # Calculate size before deleting
    $items = Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue
    foreach ($item in $items) {
        if (-not $item.PSIsContainer) {
            $totalSize += $item.Length
        }
    }

    # Delete contents
    Get-ChildItem -Path $path -Force -ErrorAction SilentlyContinue | ForEach-Object {
        try {
            Remove-Item $_.FullName -Recurse -Force -ErrorAction Stop
            $totalRemoved++
        } catch { }
    }
}

# Calculate freed space in MB
$sizeMB = [math]::Round($totalSize / 1MB, 2)

# Show toast notification
Add-Type -AssemblyName System.Windows.Forms
$notify = New-Object System.Windows.Forms.NotifyIcon
$notify.Icon = [System.Drawing.SystemIcons]::Information
$notify.Visible = $true
$notify.ShowBalloonTip(
    4000,
    "WinTempCleaner",
    "Removed $totalRemoved items - freed $sizeMB MB.",
    [System.Windows.Forms.ToolTipIcon]::Info
)

Start-Sleep -Seconds 4
$notify.Dispose()
