#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DOTFILES_DIR/lib/utils.sh"

echo -e "${GREEN}"
echo "=========================================================="
echo "    Arch Linux + Hyprland Automated Post-installation     "
echo "=========================================================="
echo -e "${NC}"

chmod +x "$DOTFILES_DIR"/scripts/*.sh

"$DOTFILES_DIR/scripts/01-packages.sh"
"$DOTFILES_DIR/scripts/02-system-setup.sh"
"$DOTFILES_DIR/scripts/03-stow.sh"

log_info "Finishing development environment installation..."

echo 'eval "$(starship init bash)"'
echo 'eval "$(mise activate bash)"'
mise install

log_success "Development environment successfully installed!"

log_info "Setting dark theme preference..."

gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

log_success "Post-installation finished successfully!"
log_warning "Reboot your system!"
