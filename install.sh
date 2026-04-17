#!/bin/bash

# Define colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🌌 MythEclipse Hyprland Installer${NC}"
echo "-------------------------------------"

# --- 1. Helper Check (Yay/Paru) ---
AUR_HELPER=""
if command -v yay &> /dev/null; then
    AUR_HELPER="yay"
elif command -v paru &> /dev/null; then
    AUR_HELPER="paru"
else
    echo -e "${YELLOW}AUR helper (yay/paru) not found.${NC}"
    read -p "Install yay-bin now? (y/n): " INSTALL_YAY
    if [[ "$INSTALL_YAY" =~ ^[Yy]$ ]]; then
        echo "Installing yay..."
        git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
        cd /tmp/yay-bin || exit
        makepkg -si --noconfirm
        cd - || exit
        AUR_HELPER="yay"
    else
        echo -e "${RED}Cannot proceed without an AUR helper.${NC}"
        exit 1
    fi
fi

# --- 2. Hardware Detection & Driver Install ---
echo -e "\n${YELLOW}🔍 Detecting Hardware...${NC}"

# Detect GPU
GPU_VENDOR=""
if lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq "nvidia"; then
    GPU_VENDOR="nvidia"
    echo -e "Detected GPU: ${GREEN}NVIDIA${NC}"
elif lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq "amd"; then
    GPU_VENDOR="amd"
    echo -e "Detected GPU: ${GREEN}AMD${NC}"
elif lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq "intel"; then
    GPU_VENDOR="intel"
    echo -e "Detected GPU: ${GREEN}INTEL${NC}"
else
    GPU_VENDOR="unknown"
    echo -e "Detected GPU: ${RED}Unknown${NC} (Defaulting to generic)"
fi

# Detect Virtual Machine
IS_VM=false
if hostnamectl status | grep -qi "virtualization"; then
    echo -e "System Type: ${YELLOW}Virtual Machine${NC}"
    IS_VM=true
else
    echo -e "System Type: ${GREEN}Physical Machine${NC}"
fi

# Detect Laptop (Battery check)
IS_LAPTOP=false
if [ -d "/sys/class/power_supply" ] && ls /sys/class/power_supply/BAT* 1> /dev/null 2>&1; then
    echo -e "Form Factor: ${YELLOW}Laptop${NC}"
    IS_LAPTOP=true
else
    echo -e "Form Factor: ${GREEN}Desktop${NC}"
fi

# --- 3. Install Core Packages ---
echo -e "\n${YELLOW}📦 Installing Core Packages...${NC}"
if [ -f "pkglist.txt" ]; then
    echo "Processing pkglist.txt..."
    
    # 1. Fetch available packages from official repositories (core, extra, multilib)
    echo -e "${BLUE}🔍 Fetching official repository package list...${NC}"
    REPO_PKGS=$(mktemp)
    if ! pacman -Sql core extra multilib > "$REPO_PKGS" 2>/dev/null; then
        # Fallback if specific repos are not enabled or pacman -Sql fails
        pacman -Sl | awk '{print $2}' | sort -u > "$REPO_PKGS"
    fi

    if [[ ! -s "$REPO_PKGS" ]]; then
        echo -e "${RED}❌ Error: Repository package list is empty.${NC}"
        echo -e "${RED}This usually indicates a problem with your pacman database.${NC}"
        rm -f "$REPO_PKGS"
        exit 1
    fi

    # 2. Sanitize pkglist.txt
    # - Using awk to handle comments and whitespace robustly
    CLEAN_PKGLIST=$(mktemp)
    awk '{gsub(/#.*/,""); if($1!="") print $1}' pkglist.txt | sort -u > "$CLEAN_PKGLIST"

    # 3. Split pkglist into Native and AUR
    NATIVE_PKGS=$(mktemp)
    AUR_PKGS=$(mktemp)

    # Use grep -Fxf for exact fixed string matching against repo list
    grep -Fxf "$REPO_PKGS" "$CLEAN_PKGLIST" | sort -u > "$NATIVE_PKGS"
    # Use grep -Fxvf to find what's NOT in repo list (AUR)
    grep -Fxvf "$REPO_PKGS" "$CLEAN_PKGLIST" | sort -u > "$AUR_PKGS"

    # 4. Validation step (Set equality check)
    COMBINED_SPLIT=$(mktemp)
    cat "$NATIVE_PKGS" "$AUR_PKGS" | sort -u > "$COMBINED_SPLIT"

    if ! diff "$CLEAN_PKGLIST" "$COMBINED_SPLIT" >/dev/null; then
        echo -e "${RED}⚠️ Warning: Package classification mismatch!${NC}"
        echo "The set of split packages does not match the sanitized input list."
        echo "Missing/Extra packages:"
        diff "$CLEAN_PKGLIST" "$COMBINED_SPLIT" | grep '^[-+><]'
        echo "Proceeding with caution..."
    else
        echo -e "${GREEN}✅ Package list successfully verified (Set Equality Pass).${NC}"
    fi
    rm -f "$COMBINED_SPLIT"

    # 5. Review Lists
    if [ -s "$NATIVE_PKGS" ]; then
        echo -e "\n${BLUE}📋 Native packages to install:${NC}"
        sed 's/^/  /' "$NATIVE_PKGS"
    fi
    if [ -s "$AUR_PKGS" ]; then
        echo -e "\n${BLUE}📋 AUR packages to install:${NC}"
        sed 's/^/  /' "$AUR_PKGS"
    fi

    # 6. Install Native Packages
    if [ -s "$NATIVE_PKGS" ]; then
        echo -e "\n${BLUE}⬇️ Installing Native Packages from Official Repositories...${NC}"
        # Using --needed and --noconfirm for smooth installation
        if ! sudo pacman -S --needed --noconfirm - < "$NATIVE_PKGS"; then
            echo -e "${RED}❌ Error: Failed to install some native packages!${NC}"
            echo "Please check the output above for details."
            # We exit here because core packages are usually required
            rm -f "$REPO_PKGS" "$CLEAN_PKGLIST" "$NATIVE_PKGS" "$AUR_PKGS"
            exit 1
        fi
    else
        echo -e "${YELLOW}No native packages found to install.${NC}"
    fi

    # 7. Install AUR Packages
    if [ -s "$AUR_PKGS" ]; then
        echo -e "\n${BLUE}⬇️ Installing AUR Packages via $AUR_HELPER...${NC}"
        if ! $AUR_HELPER -S --needed --noconfirm - < "$AUR_PKGS"; then
            echo -e "${RED}❌ Warning: Failed to install some AUR packages!${NC}"
            echo "You may need to install them manually later."
        fi
    else
        echo -e "${YELLOW}No AUR packages found to install.${NC}"
    fi

    # Cleanup temp files
    rm -f "$REPO_PKGS" "$CLEAN_PKGLIST" "$NATIVE_PKGS" "$AUR_PKGS"
else
    echo -e "${RED}❌ Error: pkglist.txt not found! Cannot proceed with package installation.${NC}"
    exit 1
fi

# --- 4. Install Specific Drivers ---
echo -e "\n${YELLOW}🔧 Installing Drivers & Tools...${NC}"

# GPU Drivers
case $GPU_VENDOR in
    "nvidia")
        echo "Installing NVIDIA Drivers..."
        sudo pacman -S --needed --noconfirm nvidia-dkms nvidia-utils lib32-nvidia-utils nvidia-settings
        ;;
    "amd")
        echo "Installing AMD Drivers..."
        sudo pacman -S --needed --noconfirm mesa lib32-mesa xf86-video-amdgpu vulkan-radeon lib32-vulkan-radeon
        ;;
    "intel")
        echo "Installing Intel Drivers..."
        sudo pacman -S --needed --noconfirm mesa lib32-mesa vulkan-intel lib32-vulkan-intel intel-media-driver
        ;;
esac

# Laptop Tools
if [ "$IS_LAPTOP" = true ]; then
    echo "Installing Laptop Tools (Brightness, Power)..."
    sudo pacman -S --needed --noconfirm brightnessctl tlp
    sudo systemctl enable --now tlp.service
fi

# VM Tools
if [ "$IS_VM" = true ]; then
    echo "Installing VM Tools (Spice, Clipboard)..."
    sudo pacman -S --needed --noconfirm spice-vdagent
fi


# --- 5. Shell Setup (Zsh + Oh My Zsh) ---
echo -e "\n${YELLOW}🐚 Setting up Zsh...${NC}"
if [ "$SHELL" != "/bin/zsh" ] && [ "$SHELL" != "/usr/bin/zsh" ]; then
    echo "Changing default shell to zsh..."
    chsh -s $(which zsh)
fi

# Install Oh My Zsh if not present
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    
    # Install Plugins
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
else
    echo "Oh My Zsh is already installed."
fi

# --- 6. Backup & Link Configs ---
BACKUP_DIR="$HOME/.config/backup_$(date +%Y%m%d_%H%M%S)"
echo -e "\n${YELLOW}hk️ Backing up existing configs to $BACKUP_DIR...${NC}"
mkdir -p "$BACKUP_DIR"

# Folders to link
CONFIGS=(
    "hypr"
    "waybar"
    "kitty"
    "wofi"
    "dunst"
    "fastfetch"
    "btop"
    "wlogout"
    "thunar"
    "nwg-look"
    "nwg-displays"
    "micro"
)

# Files to link
FILES=(
    "starship.toml"
)

# Process Directories
for DIR in "${CONFIGS[@]}"; do
    TARGET="$HOME/.config/$DIR"
    SOURCE="$(pwd)/$DIR"

    if [ -d "$SOURCE" ]; then
        if [ -d "$TARGET" ] || [ -L "$TARGET" ]; then
            mv "$TARGET" "$BACKUP_DIR/"
        fi
        ln -s "$SOURCE" "$TARGET"
        echo -e "Linked ${GREEN}$DIR${NC}"
    fi
done

# Process Files
for FILE in "${FILES[@]}"; do
    TARGET="$HOME/.config/$FILE"
    SOURCE="$(pwd)/$FILE"

    if [ -f "$SOURCE" ]; then
        if [ -f "$TARGET" ] || [ -L "$TARGET" ]; then
            mv "$TARGET" "$BACKUP_DIR/"
        fi
        ln -s "$SOURCE" "$TARGET"
        echo -e "Linked ${GREEN}$FILE${NC}"
    fi
done

# --- 7. Configure GPU Config Symlink ---
echo -e "\n${YELLOW}🔗 Linking GPU Configuration...${NC}"
CONF_DIR="$HOME/.config/hypr/conf"
GPU_CONF="$CONF_DIR/gpu.conf"

# Remove existing symlink if it exists
[ -L "$GPU_CONF" ] && rm "$GPU_CONF"

case $GPU_VENDOR in
    "nvidia")
        ln -s "$CONF_DIR/nvidia.conf" "$GPU_CONF"
        echo -e "Linked ${GREEN}nvidia.conf${NC}"
        ;;
    "amd")
        ln -s "$CONF_DIR/amd.conf" "$GPU_CONF"
        echo -e "Linked ${GREEN}amd.conf${NC}"
        ;;
    "intel")
        ln -s "$CONF_DIR/intel.conf" "$GPU_CONF"
        echo -e "Linked ${GREEN}intel.conf${NC}"
        ;;
    *)
        echo -e "${RED}No specific GPU config found for '$GPU_VENDOR'. Creating empty default.${NC}"
        touch "$GPU_CONF"
        ;;
esac


# --- 8. System Services & Settings ---
echo -e "\n${YELLOW}⚙️  Configuring system settings...${NC}"

# Enable Services
sudo systemctl enable --now bluetooth.service
sudo systemctl enable NetworkManager.service 

# Font Cache
echo "Refreshing font cache..."
fc-cache -f

# Apply GTK Theme
echo "Applying GTK Theme..."
gsettings set org.gnome.desktop.interface gtk-theme 'Tokyonight-Dark'
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Ice'
gsettings set org.gnome.desktop.interface font-name 'JetBrains Mono Nerd Font 10'

# --- 9. SDDM & Display Manager ---
read -p "Install & Configure SDDM (Login Screen)? (y/n): " INSTALL_SDDM
if [[ "$INSTALL_SDDM" =~ ^[Yy]$ ]]; then
    echo "Installing SDDM..."
    $AUR_HELPER -S --needed --noconfirm sddm
    sudo systemctl enable sddm.service

    read -p "Install 'Astronaut' SDDM Theme? (y/n): " INSTALL_THEME
    if [[ "$INSTALL_THEME" =~ ^[Yy]$ ]]; then
        echo "Cloning SDDM Astronaut Theme..."
        git clone https://github.com/Keyitdev/sddm-astronaut-theme.git /tmp/sddm-astronaut
        sudo cp -r /tmp/sddm-astronaut /usr/share/sddm/themes/sddm-astronaut-theme
        echo "[Theme]"
        echo "Current=sddm-astronaut-theme" | sudo tee /etc/sddm.conf.d/theme.conf.user
    fi
fi

# --- 10. Wallpaper ---
echo -e "\n${YELLOW}🖼️  Setting up Wallpaper...${NC}"
mkdir -p ~/Pictures/Wallpapers
echo "Note: Please check ~/.config/hypr/hyprpaper.conf to ensure the wallpaper path is correct."

echo -e "\n${GREEN}✅ Installation Complete!${NC}"
echo -e "Please ${BLUE}logout${NC} and log back in (or restart) to see changes."