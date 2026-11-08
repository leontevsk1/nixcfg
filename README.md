# nixcfg

Декларативное описание NixOS-машин. Flakе-parts + import-tree: `modules/` собирается автоматически.

## Хосты

| Хост | Железо | Стек |
|---|---|---|
| `tecno` | ноутбук | niri (Wayland) + Noctalia/matugen, kitty |
| `forge` | Xeon E3-1231v3 / GTX 970 (Maxwell) | план: zen-ядро + nvidia legacy_580 (closed) + X11 + XFCE + podman rootless; полный план — `INSIGHTS.md` в дотфайлах (`~/hyprdev`) |

## Структура

- `modules/hosts/<host>/default.nix` — запись `flake.nixosConfigurations.<host>` (nixosSystem)
- `modules/hosts/<host>/configuration.nix` — конфиг хоста
- `modules/hosts/<host>/hardware-configuration.nix` — сгенерирован `nixos-generate-config`
- `modules/features/*.nix` — переиспользуемые фичи:
  - общие для обоих хостов: `browsers` (Firefox-политики + Chromium), `proxy` (Throne + gsettings для System Proxy),
    `cli-tools` (терминальный стек, neovim, kitty), `fonts`; база системы — `common`
  - tecno-only: `niri`, `noctalia`, `regreet`, `thunar`
- `flake.nix` — inputs (nixpkgs-unstable, flake-parts, import-tree, wrapper-modules)

## Дисциплина

- Коммиты атомарные, **коммитить перед `nix eval`** (лениво кэширует последний коммит).
- Проверка без билда: `nix eval --raw .#nixosConfigurations.<host>.config.system.build.toplevel.drvPath`
- Применение: `sudo nixos-rebuild switch --flake ~/nixcfg#<host>`
- Поколения: configurationLimit = 5 + gc daily `--delete-generations +5`.
- Полные грабли — скилл `nixos-rebuild-guard` и `INSIGHTS.md` в репо дотфайлов hyprdev.

## Firefox и прокси

- В `browsers.nix` только приватность и прокси; расширения, профиль, UI и группы вкладок настраиваются в самом браузере.
- Прокси системный (`network.proxy.type = 5`): активен, только пока в Throne включён System Proxy
  (пишет в gsettings `org.gnome.system.proxy`, поэтому модуль `proxy` ставит glib и схемы).

## Файловый менеджер и диалоги файлов (tecno)

- Папки открываются в Thunar (`inode/directory`). `programs.niri.useNautilus = false`
  отключает D-Bus-интеграцию Nautilus и переключает FileChooser на GTK-портал;
  GNOME-портал остаётся для демонстрации экрана.
- Для Qt-приложений, включая Telegram, в `~/.config/qt6ct/qt6ct.conf` нужно
  `standard_dialogs=xdgdesktopportal` в секции `[Appearance]`. Это пользовательский
  файл, не управляемый NixOS: настройка сохраняет тему qt6ct/Noctalia, но отдаёт
  выбор файлов порталу. После изменения полностью перезапустить Telegram.
- После применения NixOS-конфига выйти из сессии и войти снова, чтобы старый
  процесс Nautilus освободил `org.freedesktop.FileManager1` и порталы перечитали
  настройки. Thunar не предоставляет диалоги «Открыть/Сохранить»: их рисует GTK.

## Связанные репозитории

- **hyprdev** (`~/hyprdev`) — дотфайлы (user-уровень, симлинки в ~/.config). WM-агностичная часть (nvim, zsh, yazi, starship, fastfetch, eza, kitty, opencode) общая для обоих хостов; niri/noctalia — только tecno. Репо-база знаний — `INSIGHTS.md`.
