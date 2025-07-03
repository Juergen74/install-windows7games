#!/bin/bash

# Install & patch Windows 7 Games on Ubuntu/Mint
# Wine 32-bit + en-US + Win7 + Winetricks + MUI → RES → EXE (with Resource Hacker CLI)

WINEPREFIX="$HOME/.wine-windows7games"
WINEARCH="win32"
INSTALLER="./Windows7Games_for_Windows_11_10_8.exe"
INSTALLER_ZIP_URL="https://win7games.com/download/Windows7Games_for_Windows_11_10_8.zip"
RESOURCE_HACKER_URL="https://www.angusj.com/resourcehacker/resource_hacker.zip"
TMP_DIR="/tmp/win7games_setup"
RH_WIN="C:\Program Files\Resource Hacker\ResourceHacker.exe"

GREEN="\e[32m"; RED="\e[31m"; RESET="\e[0m"

echo -e "${GREEN}🛠 Preparing Wine prefix and install environment...${RESET}"

if [ ! -f "$INSTALLER" ]; then
  echo -e "${RED}❌ Installer not found: $INSTALLER${RESET}"
  echo -e "${GREEN}⬇️  Attempting to download installer (.zip) from win7games.com...${RESET}"
  wget --referer=https://win7games.com/ --user-agent="Mozilla/5.0" -O win7games.zip "$INSTALLER_ZIP_URL" || {
    echo -e "${RED}❌ Failed to download installer from $INSTALLER_ZIP_URL.${RESET}"
    echo -e "${RED}   Please download it manually and place it as $INSTALLER.${RESET}"
    exit 1
  }
  unzip -j win7games.zip "*.exe" -d .
  rm win7games.zip
else
  echo -e "${GREEN}✅ Installer found: $INSTALLER${RESET}"
fi

export WINEPREFIX WINEARCH

sudo dpkg --add-architecture i386
sudo apt update
sudo apt install -y wine32 wine 2>/dev/null winetricks 2>/dev/null cabextract unzip wget

if [ ! -d "$WINEPREFIX" ]; then
  echo -e "${GREEN}📂 Creating 32-bit Wine prefix...${RESET}"
  WINEPREFIX="$WINEPREFIX" WINEARCH=win32 wineboot --init
fi

echo -e "${GREEN}🔧 Installing fonts & runtimes...${RESET}"
WINEPREFIX="$WINEPREFIX" winetricks 2>/dev/null -q corefonts tahoma
WINEPREFIX="$WINEPREFIX" winetricks 2>/dev/null -q vcrun6 vcrun2008 msxml6
WINEPREFIX="$WINEPREFIX" winetricks 2>/dev/null -q d3dx9 d3dx10 d3dx11
WINEPREFIX="$WINEPREFIX" winetricks 2>/dev/null -q wmp11

echo -e "${GREEN}📝 Setting Wine to Windows 7...${RESET}"
WINEPREFIX="$WINEPREFIX" wine 2>/dev/null reg add "HKCU\\Software\\Wine" /v Version /d win7 /f

echo -e "${GREEN}🇺🇸 Configuring en-US locale...${RESET}"
WINEPREFIX="$WINEPREFIX" wine 2>/dev/null reg add "HKCU\\Control Panel\\International" /v LocaleName /d en-US /f
WINEPREFIX="$WINEPREFIX" wine 2>/dev/null reg add "HKCU\\Control Panel\\Desktop" /v PreferredUILanguages /d en-US /f

echo -e "${GREEN}📁 Creating en-US folders...${RESET}"
mkdir -p "$WINEPREFIX/drive_c/windows/system32/en-US"
mkdir -p "$WINEPREFIX/drive_c/windows/syswow64/en-US"

echo -e "${GREEN}🚀 Running the installer...${RESET}"
WINEPREFIX="$WINEPREFIX" wine 2>/dev/null "$INSTALLER"

echo -e "${GREEN}📄 Copying .mui files to system folders...${RESET}"
find "$WINEPREFIX/drive_c/Program Files/Microsoft Games" -type f -name '*.mui' -exec cp -v {} "$WINEPREFIX/drive_c/windows/system32/en-US/" \;
find "$WINEPREFIX/drive_c/Program Files/Microsoft Games" -type f -name '*.mui' -exec cp -v {} "$WINEPREFIX/drive_c/windows/syswow64/en-US/" \;

echo -e "${GREEN}🔽 Installing Resource Hacker...${RESET}"
mkdir -p "$TMP_DIR"
cd "$TMP_DIR"
wget -O resource_hacker.zip "$RESOURCE_HACKER_URL"
unzip -o resource_hacker.zip

RH_DIR="$WINEPREFIX/drive_c/Program Files/Resource Hacker"
mkdir -p "$RH_DIR"
cp -r ResourceHacker.exe Language.ini *.lng "$RH_DIR/"

rm -rf "$TMP_DIR"

echo -e "${GREEN}✅ Resource Hacker installed at:${RESET} $RH_DIR"

echo -e "${GREEN}📝 Automatically extracting .mui → .res & embedding into .exe...${RESET}"

find "$WINEPREFIX/drive_c/Program Files/Microsoft Games" -maxdepth 2 -type f -iname "*.exe" | while read -r EXE; do
  GAME_DIR="$(dirname "$EXE")"
  GAME_NAME="$(basename "$EXE")"

  # skip the uninstaller
  if [[ "$GAME_NAME" == "unwin7games.exe" ]]; then
    continue
  fi

  MUI_FILE="$GAME_DIR/en-US/${GAME_NAME}.mui"

  if [ ! -f "$MUI_FILE" ]; then
    continue
  fi

  EXE_WIN=$(echo "$EXE" | sed 's|^.*/drive_c/|C:/|' | tr '/' '\\')
  MUI_WIN=$(echo "$MUI_FILE" | sed 's|^.*/drive_c/|C:/|' | tr '/' '\\')
  RES_WIN="${MUI_WIN%.mui}.res"
  PATCHED_WIN="${EXE_WIN%.exe}-patched.exe"

  echo -e "📄 Extracting .mui → .res for $GAME_NAME..."
  WINEPREFIX="$WINEPREFIX" wine 2>/dev/null "$RH_WIN" -open "$MUI_WIN" -save "$RES_WIN" -action extract -mask "*,*"

  echo -e "🚀 Embedding .res → patched .exe → $GAME_NAME-patched.exe..."
  WINEPREFIX="$WINEPREFIX" wine 2>/dev/null "$RH_WIN" -open "$EXE_WIN" -save "$PATCHED_WIN" -action addoverwrite -res "$RES_WIN" -mask "*,*"

  ORIG_WIN="${EXE_WIN%.exe}-org.exe"

  ORIG_PATH="${EXE%.exe}-org.exe"
  PATCHED_PATH="${EXE%.exe}-patched.exe"
  mv "$EXE" "$ORIG_PATH"
  mv "$PATCHED_PATH" "$EXE"
  mv "$PATCHED_PATH" "$EXE_PATH"

  echo -e "${GREEN}✅ Replaced: $GAME_NAME → patched & backed up as ${GAME_NAME%.exe}-org.exe${RESET}"

done


echo -e "${GREEN}🔄 Updating desktop database...${RESET}"
update-desktop-database ~/.local/share/applications

echo -e "\n${GREEN}🎉 Installation & patching complete!${RESET}"
echo -e "${GREEN}🎮 Games are patched & ready in the Ubuntu/Mint application menu.${RESET}"
echo -e "${GREEN}📝 Backups of originals saved as *-org.exe in each folder.${RESET}"