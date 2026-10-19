#!/bin/bash
# Compile the SCSS to dist/theme-discord-dark.css (readable, expanded output).
# Needs Dart Sass (https://github.com/sass/dart-sass/releases) on PATH, or set SASS=/path/to/sass.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
SASS="${SASS:-sass}"
command -v "$SASS" >/dev/null || { echo "Dart Sass not found. Install it or set SASS=/path/to/sass" >&2; exit 1; }

mkdir -p dist/images
"$SASS" --quiet --no-source-map --style=expanded src/scss/PVEDiscordDark.scss dist/theme-discord-dark.css
cp src/images/dd_*.svg dist/images/
echo "Built dist/theme-discord-dark.css and dist/images/"
