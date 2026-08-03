#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$SCRIPT_DIR/../lib/utils.sh"

log_info "Updating packages database and installed builds..."
sudo pacman -Syu --noconfirm

log_info "Installing packages from official repositories..."
sudo pacman -S --needed --noconfirm - <"$DOTFILES_DIR/packages/official.txt"

if command_exists yay; then
    log_success "Yay is already installed!"
else
    log_info "Installing yay..."
    TMP_DIR=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$TMP_DIR/yay"
    cd "$TMP_DIR/yay"
    makepkg -si --noconfirm
    rm -rf "$TMP_DIR"
    log_success "yay was installed successfully!"
fi

log_info "Installing AUR packages..."
yay -S --needed --noconfirm --removemake - <"$DOTFILES_DIR/packages/aur.txt"

log_info "Cleaning up build dependencies and orphan packages..."

ORPHANS=$(pacman -Qtdq 2>/dev/null || true)
if [[ -n "$ORPHANS" ]]; then
    sudo pacman -Rns $ORPHANS --noconfirm
fi

log_info "Cleaning yay build cache..."
yay -Sc --noconfirm

log_success "All packages were installed successfully!"
