#!/bin/bash
# PVEDiscordDark for Proxmox VE 9 - installer
#
# Usage (as root, on the Proxmox node):
#   bash install.sh install | uninstall | status
#
# Works offline: it only needs the dist/ folder that ships next to this script.
# Keep this folder in place after installing; the apt hook below runs this script
# again after Proxmox upgrades overwrite the web UI template.
set -euo pipefail
umask 022

# ---- Paths ------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_PATH="$SCRIPT_DIR/$(basename "${BASH_SOURCE[0]}")"
DIST_DIR="$SCRIPT_DIR/dist"

PVE_DIR="/usr/share/pve-manager"
TEMPLATE="$PVE_DIR/index.html.tpl"
CSS_TARGET="$PVE_DIR/css/dd_style.css"
IMAGES_TARGET="$PVE_DIR/images"
APT_HOOK="/etc/apt/apt.conf.d/99-pvediscorddark"

LINK_TAG="<link rel='stylesheet' type='text/css' href='/pve2/css/dd_style.css'>"

# ---- Checks -----------------------------------------------------------------
if [[ $EUID -ne 0 ]]; then
    echo "Run this script as root." >&2
    exit 1
fi
command -v pveversion >/dev/null || { echo "Proxmox VE not found on this machine." >&2; exit 1; }

is_installed() {
    [[ -f "$CSS_TARGET" ]] && grep -Fq "$LINK_TAG" "$TEMPLATE"
}

# ---- Commands ---------------------------------------------------------------
install_theme() {
    [[ -f "$DIST_DIR/theme-discord-dark.css" ]] || { echo "Missing $DIST_DIR/theme-discord-dark.css" >&2; exit 1; }

    install -m 0644 "$DIST_DIR/theme-discord-dark.css" "$CSS_TARGET"
    install -m 0644 "$DIST_DIR"/images/dd_*.svg "$IMAGES_TARGET/"

    if ! grep -Fq "$LINK_TAG" "$TEMPLATE"; then
        [[ -f "$TEMPLATE.bak" ]] || cp "$TEMPLATE" "$TEMPLATE.bak"
        # Insert before </head> so our sheet loads after Proxmox's own theme sheets.
        sed -i "s#</head>#    $LINK_TAG\n  </head>#" "$TEMPLATE"
    fi

    # Re-apply after apt upgrades (pve-manager replaces the template).
    cat > "$APT_HOOK" <<EOF
DPkg::Post-Invoke { "if [ -x '$SCRIPT_PATH' ] && ! grep -Fq 'dd_style.css' '$TEMPLATE'; then '$SCRIPT_PATH' install >/dev/null 2>&1 || true; fi"; };
EOF
    echo "Installed. Hard-refresh your browser (Ctrl/Cmd+Shift+R)."
}

uninstall_theme() {
    sed -i "\#dd_style.css#d" "$TEMPLATE"
    rm -f "$CSS_TARGET" "$APT_HOOK"
    for icon in "$DIST_DIR"/images/dd_*.svg; do
        rm -f "$IMAGES_TARGET/$(basename "$icon")"
    done
    echo "Uninstalled. Hard-refresh your browser."
}

show_status() {
    if is_installed; then
        echo "Theme: present"
    else
        echo "Theme: not present"
    fi
    pveversion
    is_installed
}

case "${1:-}" in
    install)   install_theme ;;
    uninstall) uninstall_theme ;;
    status)    show_status ;;
    *)         echo "Usage: $0 {install|uninstall|status}" >&2; exit 1 ;;
esac
