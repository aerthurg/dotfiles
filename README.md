# Arch Installation Steps

1: Select Arch Linux install medium (x86_64, UEFI)
- It will lead you to the terminal under root@archiso

2: Connect to the WiFi via iwct
- Run: iwct
- Run: device list

Check you wireless device name on the list (mine was wlan0), then:
- Run: station wlan0 scan
- Run: station wlan0 get-networks
- Run: station wlan0 connect <YOUR_WIFI_NAME>

And then you enter your WiFi password when asked.

3: Set a password to the root user (on the live ISO)
- Run: passwd

Enter the new password when asked.

4: Disk partition with cfdisk
- Run: fdisk -l (to identify your disk - mine was /dev/nvme0n1)
- Run: cfdisk /dev/nvme0n1

Use cfdisk to delete all the existing partitions from any previous installation, then:
- Create a new 1G EFI partition for the boot
- Create a new 32GB (minimum recommended for Arch) Linux filesystem partition for the root
- Create a new 4G Linux swap partition
- Create a new Linux filesystem with the remaining space for the home.

Then write everything to the disk to properly create the partitions.

5: Formatting the newly created partitions with mkfs
- Run: mkfs.ext4 /dev/nvme0n1p2 (to format the partition created for the root folder)
- Run: mkswap /dev/nvme0n1p3 (to format the swap partition)
- Run: mkfs.fat -F 32 /dev/nvme0n1p1 (to format the EFI partition)
- Run: mkfs.ext4 /dev/nvme0n1p4 (to format the partition created for the home folder)

5: Mounting the newly formatted partitions
- Run: mount /dev/nvme0n1p2 /mnt (for mounting the root partition)
- Run: mkdir /mnt/home && mount /dev/nvme0n1p4 /mnt/home (for mounting /home within /mnt)
- Run: mkdir /mnt/boot && mount /dev/nvme0n1p1 /mnt/boot (for mounting /boot within /mnt)
- Run: swapon /dev/nvme0n1p3 (for turning on the swap partition)

Then you can run lsblk to check the newly mounted partitions.

6: Setting up arch package mirrors
- Run: reflector --latest 5 --country US --protocol http,https --sort rate --save /etc/pacman.d/mirrorlist
- Run: cat /etc/pacman.d/mirrorlist (to check the updated list of 5 best mirrors)

The reflector will save the best 5 servers from the US to download your packages from.

7: Installing base packages from the live ISO on the new system build
- Run: pacstrap -K /mnt base linux linux-firmware networkmanager neovim base-devel amd-ucode git man-db man-pages reflector

The only thing brought from the live ISO is the mirrorlist. Before executing pacstrap, no package was installed in the newly mounted partitions. The pacstrap command installs the most basic set of packages we gonna need to first interact with our new system build.

OBS.: In case you computer has an Intel CPU, install intel-ucode instead of amd-ucode.

8: Generating the fstab
- Run: genfstab -U /mnt >>> /mnt/etc/fstab
- Run: cat /mnt/etc/fstab (for checking the newly generated UUIDs)

The genfstab command inspects all the mounted partitions and issues a valid /etc/fstab configuration list using standard storage identifiers like UUIDs or labels for the system to automatically identify and mount them whenever it is started.

9: System configuration (migrating from live ISO to system boot)
- Run: arch-chroot /mnt (to enter the system boot)
- Run: ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime (for setting up the timezone)
- Run: hwclock --systohc (recommended by arch wiki)

10: Setting up localization
- Run: nvim /etc/locale.gen
- Run: locale-gen

Uncomment the locale you gonne use (in my case I uncommented en_US.UTF8 and pt_BR.UTF8). Then add to the /etc/locale.conf file the following: LANG=en_US.UTF-8.

11: Adding a name to the system (hostname)
- Run: nvim /etc/hostname

And simply add your desired hostname.

12: Enabling network manager as a system service (to start on every boot)
- Run: systemctl enable NetworkManager

13: Set password to the root user and create a new user account (on the system boot)
- Run: passwd (and assign a new password)
- Run: useradd -m -G wheel,users <YOUR_USERNAME>
- Run: passwd <YOUR_USERNAME>

Then we need to enable users on the wheel group to be able to execute sudo commands.
- Run: EDITOR=nvim visudo

Look for the line starting with '%wheel' and uncomment it.

14: Setting up the bootloader
- Run: pacman -S grub efibootmgr
- Run: grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
- Run: grub-mkconfig -o /boot/grub/grub.cfg

15: Unmounting all partitions and rebooting (finish installation)
- Run: umount -R /mnt
Run: reboot

16: After the first reboot:
- Run: nmcli device wifi connect <YOUR_WIFI_NAME> password <YOUR_WIFI_PASSWORD>
- Run: sudo timedatectl set-ntp true (for synchronizing the system clock)
- Run: sudo pacman -Syu (S for sync, Y for db refreshing, U for updating all packages)
- Run: sudo pacman -S bluez bluez-utils bluez-deprecated-tools && sudo systemctl enable --now bluetooth

17: Installing yay for enabling the AUR on our system
- Run: git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si

# All Packages Manually Installed by Me (Output of command 'pacman -Qe')
1password 8.12.30-21
amd-ucode 20260622-1
base 3-3
base-devel 1-2
bluetui 0.8.1-2
bluez-deprecated-tools 5.87-2
bluez-utils 5.87-2
brightnessctl 0.5.1-3
btop 1.4.7-1
chromium 150.0.7871.186-1
cryptomator 1.19.3-1
efibootmgr 18-4
ghostty 1.3.1-2
git 2.55.0-1
gnome-themes-extra 1:3.28-1
grub 2:2.14-1
htop 3.5.2-1
hypridle 0.1.8-1
hyprland 0.56.1-2
hyprlock 0.9.6-1
hyprpaper 0.8.4-5
hyprpolkitagent 0.1.3-8
hyprshot 1.3.0-4
imv 5.0.1-2
inotify-tools 4.25.9.0-1
insync 3.9.11.60043-1
kanshi 1.9.0-1
kitty 0.48.1-1
linux 7.1.5.arch1-2
linux-firmware 20260622-1
ly 1.4.1-1
mako 1.11.0-1
man-db 2.13.1-2
man-pages 6.18-1
mise 2026.7.17-1
mpv 1:0.41.0-3
nemo 6.6.4-1
neovim 0.12.4-1
networkmanager 1.58.0-1
nmrs 1.6.0-1
noto-fonts 1:2026.07.01-1
noto-fonts-cjk 20240730-1
noto-fonts-emoji 1:2.051-1
nwg-look 1.1.1-3
pavucontrol 1:6.2-1
pipewire 1:1.6.8-1
pipewire-alsa 1:1.6.8-1
pipewire-jack 1:1.6.8-1
pipewire-pulse 1:1.6.8-1
qt5-wayland 5.15.19+kde+r55-1
qt6-wayland 6.11.1-1
qt6ct 0.11-7
reflector 2023-5
rofi 2.0.0-1
starship 1.26.0-1
ttf-jetbrains-mono-nerd 3.4.0-2
unzip 6.0-23
waybar 0.15.0-2
wireplumber 0.5.15-1
xdg-desktop-portal 1.22.1-2
xdg-desktop-portal-hyprland 1.4.1-1
yay 13.0.1-1
yay-debug 13.0.1-1
