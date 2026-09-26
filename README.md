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
- `modules/features/*.nix` — переиспользуемые фичи (niri, noctalia); фичи хоста=<desktop>
- `flake.nix` — inputs (nixpkgs-unstable, flake-parts, import-tree, wrapper-modules)

## Дисциплина

- Коммиты атомарные, **коммитить перед `nix eval`** (лениво кэширует последний коммит).
- Проверка без билда: `nix eval --raw .#nixosConfigurations.<host>.config.system.build.toplevel.drvPath`
- Применение: `sudo nixos-rebuild switch --flake ~/nixcfg#<host>`
- Поколения: configurationLimit = 5 + gc daily `--delete-generations +5`.
- Полные грабли — скилл `nixos-rebuild-guard` и `INSIGHTS.md` в репо дотфайлов hyprdev.

## Связанные репозитории

- **hyprdev** (`~/hyprdev`) — дотфайлы (user-уровень, симлинки в ~/.config). WM-агностичная часть (nvim, zsh, yazi, starship, fastfetch, eza, kitty, opencode) общая для обоих хостов; niri/noctalia — только tecno. Репо-база знаний — `INSIGHTS.md`.
