#!/usr/bin/env bash
# Хук Noctalia (wallpaper_changed, colors_changed): копирует текущие обои и
# GTK-палитру в каталог, который читает greeter. Пересборка не нужна.
# Запуск вручную: ./sync.sh
set -euo pipefail
dest="${REGREET_THEME_DIR:-/var/lib/regreet-theme}"
wall="$(noctalia msg wallpaper-get | head -n1)"
css="$HOME/.config/gtk-4.0/noctalia.css"

put() {
  cmp -s "$1" "$dest/$2" && return 0
  install -m 0644 "$1" "$dest/.$2.tmp"
  mv -f "$dest/.$2.tmp" "$dest/$2"
}

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
magick "$wall" -resize '1920x1920>' -gaussian-blur 0x14 -quality 90 "$tmp/wallpaper.jpg"
put "$tmp/wallpaper.jpg" wallpaper
filtered="$tmp/noctalia.css"
grep -v -e '^@import url("noctalia-extensions.css")' -e 'App-scoped CSS' "$css" > "$filtered"
put "$filtered" noctalia.css
