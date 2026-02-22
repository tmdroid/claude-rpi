#!/usr/bin/env bash
set -euo pipefail

# RPI Plugin — Codex CLI Installer
# Symlinks skills into ~/.agents/skills/ and merges agent roles into Codex config.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_DIR="${HOME}/.agents/skills"
CODEX_CONFIG="${HOME}/.codex/config.toml"

SKILL_NAMES=("rpi" "rpi-research" "rpi-plan" "rpi-implement")

usage() {
  echo "Usage: $0 [--uninstall]"
  echo ""
  echo "  Install:    $0"
  echo "  Uninstall:  $0 --uninstall"
}

install() {
  echo "Installing RPI skills for Codex CLI..."

  # Create skills directory if needed
  mkdir -p "$SKILLS_DIR"

  # Symlink each skill
  local installed=0
  for skill in "${SKILL_NAMES[@]}"; do
    local target="$SKILLS_DIR/$skill"
    local source="$PLUGIN_DIR/skills/$skill"

    if [ -L "$target" ]; then
      local existing
      existing="$(readlink "$target")"
      if [ "$existing" = "$source" ]; then
        echo "  ✓ $skill (already installed)"
        installed=$((installed + 1))
        continue
      else
        echo "  ⚠ $skill symlink exists but points elsewhere ($existing)"
        echo "    Updating to point to: $source"
        rm "$target"
      fi
    elif [ -e "$target" ]; then
      echo "  ⚠ $skill exists but is not a symlink — skipping (remove manually to reinstall)"
      continue
    fi

    ln -s "$source" "$target"
    echo "  ✓ $skill → $source"
    installed=$((installed + 1))
  done

  echo ""
  echo "Skills installed: $installed/${#SKILL_NAMES[@]}"

  # Merge config.toml
  echo ""
  echo "Checking Codex config..."
  mkdir -p "$(dirname "$CODEX_CONFIG")"

  if [ -f "$CODEX_CONFIG" ]; then
    # Check if RPI agents are already configured
    if grep -q '\[agents\.rpi-researcher\]' "$CODEX_CONFIG" 2>/dev/null; then
      echo "  ✓ RPI agent roles already present in $CODEX_CONFIG"
    else
      echo "  Adding RPI agent roles to $CODEX_CONFIG"
      echo "" >> "$CODEX_CONFIG"
      echo "# --- RPI Plugin agent roles (added by codex/install.sh) ---" >> "$CODEX_CONFIG"
      cat "$SCRIPT_DIR/config.toml" >> "$CODEX_CONFIG"
      echo "# --- End RPI Plugin ---" >> "$CODEX_CONFIG"
      echo "  ✓ Agent roles added"
    fi
  else
    echo "  Creating $CODEX_CONFIG with RPI agent roles"
    echo "# --- RPI Plugin agent roles (added by codex/install.sh) ---" > "$CODEX_CONFIG"
    cat "$SCRIPT_DIR/config.toml" >> "$CODEX_CONFIG"
    echo "# --- End RPI Plugin ---" >> "$CODEX_CONFIG"
    echo "  ✓ Config created"
  fi

  echo ""
  echo "Done! RPI skills are now available in Codex CLI."
  echo "Use /rpi, /rpi-research, /rpi-plan, or /rpi-implement to get started."
}

uninstall() {
  echo "Uninstalling RPI skills from Codex CLI..."

  local removed=0
  for skill in "${SKILL_NAMES[@]}"; do
    local target="$SKILLS_DIR/$skill"

    if [ -L "$target" ]; then
      rm "$target"
      echo "  ✓ Removed $skill symlink"
      removed=$((removed + 1))
    elif [ -e "$target" ]; then
      echo "  ⚠ $skill exists but is not a symlink — skipping"
    else
      echo "  - $skill not found (already removed)"
    fi
  done

  echo ""
  echo "Skills removed: $removed/${#SKILL_NAMES[@]}"

  # Remove config entries
  if [ -f "$CODEX_CONFIG" ]; then
    if grep -q 'RPI Plugin agent roles' "$CODEX_CONFIG" 2>/dev/null; then
      # Remove the RPI block from config
      sed -i.bak '/# --- RPI Plugin agent roles/,/# --- End RPI Plugin ---/d' "$CODEX_CONFIG"
      rm -f "$CODEX_CONFIG.bak"
      echo "  ✓ Removed RPI agent roles from $CODEX_CONFIG"
    fi
  fi

  echo ""
  echo "Done! RPI skills have been removed from Codex CLI."
}

# Main
case "${1:-}" in
  --uninstall)
    uninstall
    ;;
  --help|-h)
    usage
    ;;
  "")
    install
    ;;
  *)
    echo "Unknown option: $1"
    usage
    exit 1
    ;;
esac
