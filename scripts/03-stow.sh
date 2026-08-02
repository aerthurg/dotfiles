#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$SCRIPT_DIR/../lib/utils.sh"

log_info "Applying symlinks with GNU Stow..."

mkdir -p "$HOME/.config"

cd "$DOTFILES_DIR/stow"

for app in *; do
    if [ -d "$app" ]; then
        log_info "Creating symlinks for: $app"

        if [ -d "$HOME/.config/$app" ] && [ ! -L "$HOME/.config/$app" ]; then
            log_warning "Removing existing directory conflict at ~/.config/$app"
            rm -rf "$HOME/.config/$app"
        fi

        stow -R -v -t "$HOME" "$app"
    fi
done

log_success "Dotfiles applied successfully via Stow!"
