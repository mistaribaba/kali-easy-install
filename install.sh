#!/bin/bash

# ============================================================
# Kali App Manager - Installer (Python 3.13+ only)
# Author: Kunal Mistari
# GitHub: https://github.com/mistaribaba
# ============================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

clear
echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}${BOLD}║         Kali App Manager - Installation          ║${NC}"
echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════════╝${NC}"
echo ""

# 1. Check for Python3
echo -e "${YELLOW}[1/5] Checking for Python3...${NC}"
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}✗ Python3 is not installed. Please install Python 3.13 or higher.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Python3 found: $(python3 --version)${NC}"

# 2. Check Python version (requires exactly 3.13 or higher)
echo -e "${YELLOW}[2/5] Checking Python version (requires ≥ 3.13)...${NC}"
REQUIRED_PYTHON="3.13"
PYTHON_VERSION=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')

if [ "$(printf '%s\n' "$REQUIRED_PYTHON" "$PYTHON_VERSION" | sort -V | head -n1)" != "$REQUIRED_PYTHON" ]; then
    echo -e "${RED}✗ Error: Python 3.13 or higher is required. You have $PYTHON_VERSION.${NC}"
    echo -e "${YELLOW}Please upgrade Python or install Python 3.13+ from source.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Python $PYTHON_VERSION meets requirement${NC}"

# 3. Create virtual environment (to avoid externally-managed error)
VENV_DIR="kali-app-env"
if [ -d "$VENV_DIR" ]; then
    echo -e "${YELLOW}Virtual environment already exists. Using existing.${NC}"
else
    echo -e "${YELLOW}[3/5] Creating virtual environment...${NC}"
    python3 -m venv "$VENV_DIR"
    echo -e "${GREEN}✓ Virtual environment created in ./$VENV_DIR${NC}"
fi

# 4. Activate and install customtkinter
echo -e "${YELLOW}[4/5] Installing customtkinter inside virtual environment...${NC}"
source "$VENV_DIR/bin/activate"
pip install --upgrade pip
pip install customtkinter
deactivate
echo -e "${GREEN}✓ customtkinter installed${NC}"

# 5. Create launcher script
echo -e "${YELLOW}[5/5] Creating launcher script...${NC}"
cat > run_app.sh << EOF
#!/bin/bash
source "$(pwd)/$VENV_DIR/bin/activate"
python3 "$(pwd)/app.py"
deactivate
EOF
chmod +x run_app.sh
echo -e "${GREEN}✓ Launcher created: ./run_app.sh${NC}"

# Optional desktop shortcut
read -p "Create a desktop shortcut? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    DESKTOP_DIR="$HOME/.local/share/applications"
    mkdir -p "$DESKTOP_DIR"
    DESKTOP_FILE="$DESKTOP_DIR/kali-app-manager.desktop"
    cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Kali App Manager
Comment=Install/uninstall .deb packages easily
Exec=$(pwd)/run_app.sh
Icon=system-software-install
Terminal=false
Categories=System;
StartupNotify=true
EOF
    echo -e "${GREEN}✓ Desktop shortcut created at $DESKTOP_FILE${NC}"
fi

echo ""
echo -e "${GREEN}${BOLD}══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}✓ Installation successful!${NC}"
echo -e "${GREEN}Run the app with: ./run_app.sh${NC}"
echo -e "${GREEN}${BOLD}══════════════════════════════════════════════════${NC}"
