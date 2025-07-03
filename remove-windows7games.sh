#!/bin/bash

WINEPREFIX="$HOME/.wine-windows7games"
INSTALLER="./Windows7Games_for_Windows_11_10_8.exe"

GREEN="\e[32m"; RED="\e[31m"; RESET="\e[0m"

FORCE=0
KEEP_PREFIX=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force)
      FORCE=1
      shift
      ;;
    --keep-prefix)
      KEEP_PREFIX=1
      shift
      ;;
    *)
      echo -e "${RED}❌ Unknown option: $1${RESET}"
      echo "Usage: $0 [--force] [--keep-prefix]"
      exit 1
      ;;
  esac
done

if [[ $FORCE -eq 0 ]]; then
  echo -e "${GREEN}🧹 This will permanently delete:${RESET}"
  if [[ $KEEP_PREFIX -eq 0 ]]; then
    echo -e "  🗑 Wine prefix: $WINEPREFIX"
  else
    echo -e "  🗑 Cleaning .res & restoring .org.exe in: $WINEPREFIX"
  fi
  echo -e "  🗑 Installer: $INSTALLER"
  echo -e "  🗑 Wine menu shortcuts"
  read -p "Are you sure? (y/N) " confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo -e "${RED}❌ Aborted by user.${RESET}"
    exit 1
  fi
fi

if [[ $KEEP_PREFIX -eq 0 ]]; then
  if [ -d "$WINEPREFIX" ]; then
    echo -e "🗑 Removing Wine prefix at $WINEPREFIX..."
    rm -rf "$WINEPREFIX"
  else
    echo -e "${RED}⚠️  Wine prefix $WINEPREFIX not found.${RESET}"
  fi
else
  echo -e "${GREEN}📝 Keeping Wine prefix. Cleaning patched files...${RESET}"
  find "$WINEPREFIX/drive_c/Program Files/Microsoft Games" -type f \( -iname "*.res" -o -iname "*-patched.exe" \) -exec rm -v {} \;
  find "$WINEPREFIX/drive_c/Program Files/Microsoft Games" -type f -iname "*-org.exe" | while read -r ORIG; do
    ORIG_NAME="${ORIG%-org.exe}.exe"
    echo -e "🔄 Restoring $(basename "$ORIG_NAME") ← $(basename "$ORIG")"
    mv -f "$ORIG" "$ORIG_NAME"
  done
fi

if [ -f "$INSTALLER" ]; then
  echo -e "🗑 Removing installer $INSTALLER..."
  rm -f "$INSTALLER"
else
  echo -e "${RED}⚠️  Installer $INSTALLER not found.${RESET}"
fi

echo -e "🧽 Removing desktop/menu shortcuts..."
rm -rf ~/.local/share/applications/wine

echo -e "\n${GREEN}✅ Removal complete.${RESET}"
echo -e "${GREEN}🎮 To reinstall, just run the install script again.${RESET}"