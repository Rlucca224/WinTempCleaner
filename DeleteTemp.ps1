# ============================================================
#  DeleteTemp.ps1  –  Eliminar Archivos Temporales
#  Ejecutar SIEMPRE como Administrador (lo gestiona install.bat)
# ============================================================

$ErrorActionPreference = "SilentlyContinue"

$rutas = @(
    $env:TEMP,
    $env:TMP,
    "$env:LOCALAPPDATA\Temp",
    "$env:SystemRoot\Temp",
    "$env:SystemRoot\Prefetch"
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

    # Borrar archivos
    Get-ChildItem -Path $ruta -Force -ErrorAction SilentlyContinue | ForEach-Object {
        try {
            Remove-Item $_.FullName -Recurse -Force -ErrorAction Stop
            $totalEliminados++
        } catch { }
    }
}

# Calcular tamaño liberado en MB
$sizeMB = [math]::Round($totalSize / 1MB, 2)

# Mostrar resultado (balloon tip o mensaje simple)
Add-Type -AssemblyName System.Windows.Forms
$notify = New-Object System.Windows.Forms.NotifyIcon
$notify.Icon = [System.Drawing.SystemIcons]::Information
$notify.Visible = $true
$notify.ShowBalloonTip(
    4000,
    "Limpieza completada",
    "Se eliminaron $totalEliminados elementos y se liberaron $sizeMB MB.",
    [System.Windows.Forms.ToolTipIcon]::Info
)

Start-Sleep -Seconds 4
$notify.Dispose()
