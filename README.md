# 🧹 WinTempCleaner

> One-click desktop shortcut to silently delete all temporary files on Windows 11 — no windows, no flashing, just a clean notification when it's done.

![Windows 11](https://img.shields.io/badge/Windows-11-0078D4?style=flat-square&logo=windows11&logoColor=white)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-5391FE?style=flat-square&logo=powershell&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)

---

## ✨ What it does

Adds a **"Delete Temporary Files"** option to your Windows 11 desktop right-click context menu. One click silently cleans all temp folders in the background with admin privileges — no CMD window, no blue PowerShell flash — just a toast notification when finished.

Inspired by the same feature found in **Windows Ghost Spectre**.

---

## 🗂️ Files

| File | Description |
|------|-------------|
| `INSTALL.bat` | Installs the context menu entry (run as Administrator) |
| `UNINSTALL.bat` | Completely removes everything the installer added |
| `DeleteTemp.ps1` | PowerShell script that performs the actual cleanup |
| `Launcher.vbs` | Silent VBScript launcher — prevents any visible window from appearing |
| `UPDATE_SILENT.reg` | Patch for users upgrading from a previous version |

---

## 🚀 Installation

1. Download or clone this repository
2. Place all files in the **same folder**
3. Right-click `INSTALL.bat` → **Run as administrator**
4. Right-click your desktop and enjoy the new option

> ⚠️ Windows UAC will prompt for confirmation when you use the option. This is expected and cannot be bypassed — it's a Windows security feature required to delete system temp files.

---

## 🧽 What gets cleaned

| Folder | Description |
|--------|-------------|
| `%LOCALAPPDATA%\Temp` | User local temp files |
| `%TEMP%` / `%TMP%` | Standard temp environment paths |
| `C:\Windows\Temp` | System-wide temp folder |
| `C:\Windows\Prefetch` | Windows prefetch cache |

After cleanup, a **toast notification** shows how many items were removed and how many MB were freed.

---

## 🔧 How it works

```
Right-click Desktop → "Delete Temporary Files"
         ↓
   wscript.exe  (invisible, runs in background)
         ↓
   Launcher.vbs  (launches PowerShell with WindowStyle = 0)
         ↓
   UAC prompt  (Windows elevation confirmation)
         ↓
   DeleteTemp.ps1  (cleans all temp folders silently)
         ↓
   Toast notification  (done ✓)
```

---

## ❌ Uninstall

Right-click `UNINSTALL.bat` → **Run as administrator**

This removes:
- The registry key `HKCR\DesktopBackground\Shell\DeleteTemp`
- The folder `C:\ProgramData\DeleteTemp\` and all its contents

Your system will be left **exactly as it was** before installation.

---

## 📋 Requirements

- Windows 11 (also works on Windows 10)
- PowerShell 5.1 or later (included in Windows by default)
- Administrator rights for installation

---

## 📄 License

MIT — free to use, modify, and distribute.
