#!/usr/bin/env bash
set -euo pipefail

# ── Resolve dotfiles directory ──────────────────────────────────────
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP="$(date +%Y%m%d%H%M%S)"

echo "Dotfiles installer"
echo "  source: $DOTFILES_DIR"
echo "  os:     $(uname -s)"
echo ""

# ── Helpers ─────────────────────────────────────────────────────────
backup_if_exists() {
  local target="$1"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    local backup="${target}.backup.${TIMESTAMP}"
    echo "  backup: $target -> $backup"
    mv "$target" "$backup"
  fi
}

create_symlink() {
  local source="$1"
  local target="$2"
  if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
    echo "  exists: $target -> $source"
    return
  fi
  backup_if_exists "$target"
  ln -sf "$source" "$target"
  echo "  link:   $target -> $source"
}

append_source_line() {
  local rc_file="$1"
  local source_line="source \"$DOTFILES_DIR/shell/aliases\""

  # Create the rc file if it doesn't exist
  [ -f "$rc_file" ] || touch "$rc_file"

  if grep -qF "$source_line" "$rc_file" 2>/dev/null; then
    echo "  exists: source line in $rc_file"
  else
    echo "" >> "$rc_file"
    echo "$source_line" >> "$rc_file"
    echo "  added:  source line to $rc_file"
  fi
}

# ── Create directories ──────────────────────────────────────────────
mkdir -p "$HOME/.config"

# ── Symlinks ────────────────────────────────────────────────────────
echo "Symlinks:"
create_symlink "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
create_symlink "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
create_symlink "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
if [ "$(uname -s)" = "Darwin" ]; then
  GHOSTTY_DIR="$HOME/Library/Application Support/com.mitchellh.ghostty"
  mkdir -p "$GHOSTTY_DIR"
  create_symlink "$DOTFILES_DIR/ghostty/config" "$GHOSTTY_DIR/config"
  mkdir -p "$HOME/.config/ghostty"
  create_symlink "$DOTFILES_DIR/ghostty/themes" "$HOME/.config/ghostty/themes"
fi
echo ""

# ── Shell source lines ─────────────────────────────────────────────
echo "Shell config:"
append_source_line "$HOME/.bashrc"
append_source_line "$HOME/.zshrc"
echo ""

echo "Done! Restart your shell or run: source ~/.$(basename "$SHELL")rc"
