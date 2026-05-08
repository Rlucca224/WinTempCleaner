# ============================================================
#  DeleteTemp.ps1  -  Eliminar Archivos Temporales
#  Ejecutar SIEMPRE como Administrador (lo gestiona Launcher.vbs)
# ============================================================

$ErrorActionPreference = "SilentlyContinue"

$rutas = @(
    $env:TEMP,
    $env:TMP,
    "$env:LOCALAPPDATA\Temp",
    "$env:LOCALAPPDATA\Microsoft\Windows\INetCache",
    "$env:LOCALAPPDATA\Microsoft\Windows\Temporary Internet Files",
    "$env:LOCALAPPDATA\CrashDumps",
    "$env:SystemRoot\Temp",
    "$env:SystemRoot\Prefetch",
    "$env:SystemRoot\Logs\CBS",
    "$env:SystemRoot\Minidump",
    "$env:SystemRoot\SoftwareDistribution\Download"
)

$totalEliminados = 0
$totalSize       = 0

foreach ($ruta in $rutas) {
    if (-not (Test-Path $ruta)) { continue }

    # Tamaño antes de borrar
    $items = Get-ChildItem -Path $ruta -Recurse -Force -ErrorAction SilentlyContinue
    foreach ($item in $items) {
        if (-not $item.PSIsContainer) {
            $totalSize += $item.Length
        }
    }

    # Borrar contenido
    Get-ChildItem -Path $ruta -Force -ErrorAction SilentlyContinue | ForEach-Object {
        try {
            Remove-Item $_.FullName -Recurse -Force -ErrorAction Stop
            $totalEliminados++
        } catch { }
    }
}

# Calcular tamaño liberado en MB
$sizeMB = [math]::Round($totalSize / 1MB, 2)

# Mostrar notificación
Add-Type -AssemblyName System.Windows.Forms
$notify = New-Object System.Windows.Forms.NotifyIcon
$notify.Icon = [System.Drawing.SystemIcons]::Information
$notify.Visible = $true
$notify.ShowBalloonTip(
    4000,
    "WinTempCleaner",
    "Removed $totalEliminados items — freed $sizeMB MB.",
    [System.Windows.Forms.ToolTipIcon]::Info
)

Start-Sleep -Seconds 4
$notify.Dispose()