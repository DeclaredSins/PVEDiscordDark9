# PVEDiscordDark for Proxmox VE 9

A Discord-inspired dark theme for the Proxmox VE 9 web UI. It is a port of
[Weilbyte/PVEDiscordDark](https://github.com/Weilbyte/PVEDiscordDark), which is unmaintained
and only supports PVE up to 7.3.

> **Status:** early. Built against the PVE 9.2 sources and checked by reviewing the CSS and by user
> screenshots, not by a systematic test of every dialog. Please open an issue with a screenshot if you
> find black text, black icons or odd graphs.

## Why this is a rewrite, not a patch

PVE 9 ships its own dark theme (`proxmox-dark` in
[proxmox-widget-toolkit](https://git.proxmox.com/?p=proxmox-widget-toolkit.git)). It styles graphs and
gauges through CSS variables (`--pwt-*`). The original project used positional `nth-child` selectors
and JavaScript patches of chart internals, which break on newer versions.

This port recompiles the native dark-theme SCSS with the Discord palette instead, so charts, gauges,
buttons and legends are styled by the same mechanisms Proxmox itself uses. **No JavaScript is injected.**

On top of the native theme it also:

- ships light copies of Proxmox's hard-coded black SVG icons (CPU, memory, CD, PCI, serial, RNG), instead of
  the `invert()` filter that also darkens neighbouring text;
- fixes the black lock badges shown on guests during backup, migrate, suspend and snapshot.

## Install

On the Proxmox node, as root:

```bash
git clone https://github.com/DeclaredSins/PVEDiscordDark9.git /root/pvediscorddark
bash /root/pvediscorddark/install.sh install
```

No Git on the node? Copy the folder over with `scp -r` instead. Then hard-refresh the browser
(Ctrl/Cmd+Shift+R).

- **Keep the folder.** An apt hook (`/etc/apt/apt.conf.d/99-pvediscorddark`) runs `install.sh` again
  after `pve-manager` upgrades overwrite the web UI template.
- **Clusters:** repeat on each node, since each node serves its own UI.
- **Status / removal:** `bash install.sh status`, `bash install.sh uninstall`.
- The theme is always on. It does not appear in the Proxmox theme selector.
- A one-time backup of the original template is saved as `/usr/share/pve-manager/index.html.tpl.bak`.

## What the installer changes

| Path | Change |
| --- | --- |
| `/usr/share/pve-manager/css/dd_style.css` | the theme |
| `/usr/share/pve-manager/images/dd_*.svg` | recoloured icons |
| `/usr/share/pve-manager/index.html.tpl` | one `<link>` line added before `</head>` |
| `/etc/apt/apt.conf.d/99-pvediscorddark` | re-applies the theme after upgrades |

## Customising

Colours are in [`src/scss/abstracts/_variables.scss`](src/scss/abstracts/_variables.scss). To rebuild you need
[Dart Sass](https://github.com/sass/dart-sass/releases):

```bash
./build.sh                      # or: SASS=/path/to/sass ./build.sh
```

This writes `dist/theme-discord-dark.css` and copies the icons to `dist/images/`. The compiled `dist/`
is committed, so people can install without a Sass toolchain.

To regenerate the icons from fresh Proxmox sources, see `scripts/recolor-icons.py`.

## Layout

```
src/scss/            theme source (palette, ExtJS components, Proxmox widgets, icons)
src/images/          recoloured SVG icons
dist/                compiled CSS and icons (what the installer uses)
scripts/             helper to regenerate icons
build.sh             compile SCSS -> dist/
install.sh           install / uninstall / status on a Proxmox node
```

## Credits

- **[Weilbyte](https://github.com/Weilbyte)** created the original
  [PVEDiscordDark](https://github.com/Weilbyte/PVEDiscordDark): the Discord colour palette and the idea.
  Its git history is preserved in this repository.
- **Proxmox Server Solutions GmbH** wrote the `proxmox-dark` theme this port is built on.

## Licence

Because the SCSS is derived from Proxmox's AGPL-3.0 dark theme, this project is licensed
**AGPL-3.0-or-later** (see [LICENSE](LICENSE)). The original PVEDiscordDark palette and idea are MIT,
Copyright 2021 Weilbyte (see [LICENSE-UPSTREAM-MIT](LICENSE-UPSTREAM-MIT)).
Not affiliated with Proxmox Server Solutions GmbH or Discord.
