' ============================================================
'  Launcher.vbs  -  Silent elevated launcher
'  Runs DeleteTemp.ps1 as Administrator with NO visible window
' ============================================================
Set oShell = CreateObject("Shell.Application")
oShell.ShellExecute "powershell.exe", _
    "-ExecutionPolicy Bypass -WindowStyle Hidden -NonInteractive -File ""C:\ProgramData\DeleteTemp\DeleteTemp.ps1""", _
    "", "runas", 0
