#!/usr/bin/env bash
# Обновляет обои и GTK-палитру greeter-а из текущих настроек Noctalia.
# После запуска: git add -N и nixos-rebuild boot.
set -euo pipefail
dir="$(cd "$(dirname "$0")" && pwd)"
wall="$(noctalia msg wallpaper-get | head -n1)"
cp -f "$wall" "$dir/wallpaper.jpg"
grep -v -e '^@import url("noctalia-extensions.css")' -e 'App-scoped CSS' \
  "$HOME/.config/gtk-4.0/noctalia.css" > "$dir/noctalia.css"
echo "ok: $dir/wallpaper.jpg, $dir/noctalia.css"
