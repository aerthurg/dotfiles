# Arch Linux + Hyprland Dotfiles & Installation Guide

![Arch Linux](https://img.shields.io/badge/OS-Arch_Linux-blue?logo=arch-linux)
![Hyprland](https://img.shields.io/badge/WM-Hyprland-blueviolet?logo=hyprland)
![Wayland](https://img.shields.io/badge/Display-Wayland-red)
![GNU Stow](https://img.shields.io/badge/Dotfiles-GNU_Stow-informational)

This repository contains a complete guide for a manual base Arch Linux installation, as well as modular post-installation scripts and dotfiles managed with **GNU Stow** to fully replicate my Hyprland desktop environment on any fresh Arch installation.

---

## 📦 Software Stack Summary

* **Window Manager / Compositor:** Hyprland
* **Display Manager / Login:** Ly
* **Status Bar:** Waybar
* **Application Launcher:** Rofi (Wayland)
* **Terminal:** Ghostty
* **Shell & Prompt:** Starship, Mise
* **Text Editor:** Neovim (LazyVim)
* **File Manager:** Nemo
* **Theme & Appearance:** GTK-3.0, GTK-4.0, nwg-look, qt6ct
* **Audio:** Pipewire, Wireplumber, Pavucontrol
* **Notifications & Lock:** Mako, Hyprlock, Hypridle

---

## 🚀 Part 1: Base Arch Linux Installation (Live ISO)

Follow these steps while booted into the **Arch Linux Live ISO environment**.

### 1. Boot into the ISO
Select the **Arch Linux install medium (x86_64, UEFI)**. You will be greeted by the root prompt: `root@archiso:~#`.

### 2. Connect to Wi-Fi (iwctl)
If you are on Wi-Fi, establish an internet connection using `iwctl`:

```bash
iwctl
device list
station wlan0 scan
station wlan0 get-networks
station wlan0 connect <YOUR_WIFI_NAME>
exit
```
*(Replace `wlan0` with your actual wireless interface name if different).*

### 3. Set ISO Root Password
Set a temporary root password for the live environment session:

```bash
passwd
```

### 4. Disk Partitioning (cfdisk)
Identify your disk name (e.g., `/dev/nvme0n1` or `/dev/sda`):

```bash
fdisk -l
cfdisk /dev/nvme0n1
```

Delete existing partitions if needed, then create the following partition scheme:
* **EFI Boot:** `1G` (Type: `EFI System`)
* **Root (`/`):** `32G` minimum (Type: `Linux filesystem`)
* **Swap:** `4G` (Type: `Linux swap`)
* **Home (`/home`):** Remaining space (Type: `Linux filesystem`)

Select **Write** and type `yes` to save changes to disk.

### 5. Format Partitions
Format the newly created partitions:

```bash
# Format Root partition
mkfs.ext4 /dev/nvme0n1p2

# Format Swap partition
mkswap /dev/nvme0n1p3

# Format EFI Boot partition
mkfs.fat -F 32 /dev/nvme0n1p1

# Format Home partition
mkfs.ext4 /dev/nvme0n1p4
```

### 6. Mount Partitions
Mount the formatted partitions into `/mnt`:

```bash
# Mount Root
mount /dev/nvme0n1p2 /mnt

# Mount Home
mkdir -p /mnt/home && mount /dev/nvme0n1p4 /mnt/home

# Mount Boot
mkdir -p /mnt/boot && mount /dev/nvme0n1p1 /mnt/boot

# Enable Swap
swapon /dev/nvme0n1p3

# Verify mounting setup
lsblk
```

### 7. Configure Package Mirrors
Select the fastest 5 mirrors using Reflector:

```bash
reflector --latest 5 --country US --protocol http,https --sort rate --save /etc/pacman.d/mirrorlist
```

### 8. Install Base System (pacstrap)
Install essential Arch Linux base packages to `/mnt`:

```bash
pacstrap -K /mnt base linux linux-firmware networkmanager neovim base-devel amd-ucode git man-db man-pages reflector
```

> **Note:** If your computer uses an Intel processor, replace `amd-ucode` with `intel-ucode`.

### 9. Generate fstab
Generate the system `/etc/fstab` using UUIDs:

```bash
genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab # Verify generated entries
```

### 10. Chroot & System Configuration
Enter the newly installed system environment:

```bash
arch-chroot /mnt
```

Set Timezone and Hardware Clock:

```bash
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc
```

### 11. Localization Setup
Edit `/etc/locale.gen` to uncomment your preferred locales (e.g., `en_US.UTF-8` and `pt_BR.UTF-8`):

```bash
nvim /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
```

### 12. Set Hostname
Assign a hostname to your system:

```bash
echo "your-hostname" > /etc/hostname
```

### 13. User Creation & Privileges
Set the system root password and create a new non-root user:

```bash
# Set Root Password
passwd

# Create user with wheel privileges
useradd -m -G wheel,users <YOUR_USERNAME>
passwd <YOUR_USERNAME>

# Enable sudo privileges for wheel group
EDITOR=nvim visudo
```
*In `visudo`, locate `%wheel ALL=(ALL:ALL) ALL` and uncomment the line.*

### 14. Install Bootloader (GRUB)
Install GRUB for UEFI systems:

```bash
pacman -S grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
```

### 15. Exit Chroot & Reboot
Exit the environment, unmount all partitions, and reboot into your fresh installation:

```bash
exit
umount -R /mnt
reboot
```

---

## ⚡ Part 2: Automated Post-Installation & Dotfiles Setup

After rebooting and logging into your user account, you can run the automated installation scripts to install all applications, configure services, and apply dotfiles.

### 1. Connect to Internet
Establish Wi-Fi connection using NetworkManager CLI:

```bash
systemctl enable --now NetworkManager
nmcli device wifi connect <YOUR_WIFI_NAME> password <YOUR_WIFI_PASSWORD>
```

### 2. Clone Repository & Run Installer
Clone this repository to your `~/Codes` directory and execute `install.sh`:

```bash
# Clone repo and change directory
git clone https://github.com/aerthurg/dotfiles.git ~/Codes/dotfiles && cd ~/Codes/dotfiles

# Make scripts executable and run
chmod +x install.sh
./install.sh
```

### What `install.sh` handles automatically:
1. **`01-packages.sh`**: Updates system databases, installs all official packages defined in `packages/official.txt`, compiles `yay` (AUR helper) in `/tmp` if not installed, and installs AUR packages from `packages/aur.txt`.
2. **`02-system-setup.sh`**: Enables core Systemd services (`NetworkManager.service`, `bluetooth.service`, `ly@tty2.service`, `fstrim.timer`).
3. **`03-stow.sh`**: Uses **GNU Stow** to cleanly map configuration modules from `stow/` directly into your `$HOME` directory (`~/.config/`).

---

## 🧰 Part 3: Dotfiles Management with GNU Stow

All configuration files are organized into isolated modules under the `stow/` directory.

### Re-applying Dotfiles
If you modify or add configurations to the repository, apply updates using GNU Stow:

```bash
cd ~/.dotfiles/stow
stow -R -v --target="$HOME" <module-name>

# Example for Hyprland:
stow -R -v --target="$HOME" hypr
```

### Adding New Configurations
1. Create a directory inside `stow/` matching your app name (e.g., `stow/appname/.config/appname`).
2. Move your configuration directory inside.
3. Run `stow -R -v --target="$HOME" appname`.


