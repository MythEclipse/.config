<div align="center">

# 🌌 MythEclipse Dotfiles
### Personal Hyprland Configuration

![Hyprland](https://img.shields.io/badge/Hyprland-Config-00b4d8?style=for-the-badge&logo=archlinux&logoColor=white)
![Style](https://img.shields.io/badge/Style-Futuristic-7209b7?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-4361ee?style=for-the-badge)

</div>

## 🖼️ Preview
> *[Insert your screenshots here]*
>
> *Pro Tip: Add screenshots of your desktop to `assets/` folder and link them here to make your repo stand out!*

## 🛠️ The Stack

My personalized configuration for a high-performance, keyboard-driven workflow on Linux.

| Component | Tool | Description |
|-----------|------|-------------|
| **Window Manager** | [Hyprland](https://hyprland.org/) | The dynamic tiling Wayland compositor |
| **Status Bar** | [Waybar](https://github.com/Alexays/Waybar) | Highly customizable Wayland bar |
| **Terminal** | [Kitty](https://sw.kovidgoyal.net/kitty/) | GPU accelerated terminal emulator |
| **Launcher** | [Wofi](https://hg.sr.ht/~scoopta/wofi) | Application launcher / Menu |
| **Notifications** | [Dunst](https://dunst-project.org/) | Lightweight notification daemon |
| **Shell Prompt** | [Starship](https://starship.rs/) | Cross-shell prompt |
| **System Monitor** | [Btop](https://github.com/aristocratos/btop) | Resource monitor that shows usage and stats |
| **Logout** | [Wlogout](https://github.com/ArtsyMacaw/wlogout) | Wayland based logout menu |
| **Fetch** | [Fastfetch](https://github.com/fastfetch-cli/fastfetch) | Like neofetch, but faster |

## 📂 Structure

```sh
.config/
├── hypr/          # Hyprland main config
├── waybar/        # Status bar styling
├── kitty/         # Terminal colors & fonts
├── wofi/          # Launcher styling
├── dunst/         # Notification appearance
├── starship.toml  # Shell prompt config
└── ...
```

## 🚀 Installation

### ⚡ One-Liner (Recommended)
Install everything (Git, Base-devel, Dotfiles, Packages, Drivers, Shell) with a single command:

```bash
bash <(curl -s https://raw.githubusercontent.com/MythEclipse/hyprland-config/main/setup.sh)
```

This script will:
1. Install `git` and `base-devel` (Arch/Pacman).
2. Clone this repo to `~/.dotfiles` (or `~/.config`).
3. Detect your GPU (NVIDIA/AMD/Intel) and install correct drivers.
4. Install all packages (Hyprland, Waybar, etc.) using `yay`.
5. Setup Zsh, Oh-My-Zsh, and Themes.
6. Configure SDDM (Login Screen) if requested.

### Manual Installation
If you prefer to do it manually:

1. **Clone:**
   ```bash
   git clone git@github.com:MythEclipse/hyprland-config.git ~/.config/hypr-backup
   ```

2. **Run Installer:**
   ```bash
   cd ~/.config/hypr-backup
   chmod +x install.sh
   ./install.sh
   ```

## 🛠️ Recent Fixes
- Recorded fix: syntax errors in `install.sh` were corrected and audited to ensure the installer parses cleanly.

## ⌨️ Keybindings (Highlights)
| Key | Action |
|-----|--------|
| `SUPER + Q` | Open Terminal (Kitty) |
| `SUPER + C` | Kill Active Window |
| `SUPER + M` | Exit Hyprland |
| `SUPER + E` | File Manager |
| `SUPER + V` | Toggle Floating |
| `SUPER + R` | Application Launcher (Wofi) |

---
<div align="center">
Made with ❤️ by <a href="https://github.com/MythEclipse">MythEclipse</a>
</div>
