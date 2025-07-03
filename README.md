# Windows 7 Games Installer & Patcher for Linux (Ubuntu/Mint)

🎮 This script installs and patches the classic **Windows 7 Games** (Solitaire, Spider Solitaire, Mahjong, Chess, etc.)  
to run properly on Linux using Wine.  
It also fixes missing menus and UI text by patching `.mui` files into the game executables.

---

## ✨ Features
✅ Fully automated installer for Ubuntu/Mint  
✅ Installs Wine, Winetricks, required components  
✅ Downloads Windows 7 Games installer (.zip) if missing  
✅ Creates dedicated Wine prefix  
✅ Fixes UI & menus by patching `.mui → .res → .exe`  
✅ Backs up original `.exe` as `*-org.exe`  
✅ Clean removal script included (also cleans desktop/menu icons)  

---

## 📋 Requirements
- Ubuntu or Linux Mint (should also work on other Debian‑based distributions)
- Internet connection
- ~500–1000 MB free disk space

---

## 📦 Included scripts
| File | Description |
|------|-------------|
| `install-windows7games.sh` | Installs & patches Windows 7 Games |
| `remove-windows7games.sh` | Uninstalls, cleans up, removes menu shortcuts |
| `README.md` | This documentation |
| `DISCLAIMER` | Legal disclaimer |

---

## 🚀 Installation
```bash
chmod +x install-windows7games.sh
./install-windows7games.sh
```

This will:
- Create a Wine prefix: `~/.wine-windows7games`
- Download & extract the Windows 7 Games installer from [win7games.com](https://win7games.com/)
- Run the installer
- Patch the games
- Backup originals
- Games appear in your desktop/application menu

---

## 🧹 Uninstallation
```bash
chmod +x remove-windows7games.sh
./remove-windows7games.sh
```

Options:
- `--force` → Skip confirmation
- `--keep-prefix` → Keep the Wine prefix but restore `.exe` from backups and delete `.res`

Examples:
```bash
./remove-windows7games.sh --force
./remove-windows7games.sh --keep-prefix
```

This will also clean up Wine menu/desktop shortcuts.

---

## 🎨 Notes
- Tested on Ubuntu and Linux Mint.
- Uses [Resource Hacker](https://www.angusj.com/resourcehacker/) (freeware) to patch resources.
- The Windows 7 Games installer is downloaded from [win7games.com](https://win7games.com/).

---

## 📜 License
This repository is distributed under the MIT License.  
See `DISCLAIMER` for legal notes.

---

## ❤️ Credits
- Scripts written & tested with help of [ChatGPT](https://openai.com/)
- Windows 7 Games by Microsoft
- Resource Hacker by Angus Johnson
- Windows 7 Games installer by win7games.com
