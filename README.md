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
  - tecno-only: `niri`, `noctalia`, `noctalia-greeter`, `thunar`
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

## Greeter (tecno): история и уроки

Сейчас: штатный `services.displayManager.noctalia-greeter` из nixpkgs (`modules/features/noctalia-greeter.nix`).
Путь: tuigreet → noctalia-greeter → mdgreet → regreet → снова noctalia-greeter.
Из regreet вернулись на noctalia-greeter, потому что в regreet периодически не работал ввод
(мышь/клавиатура), а причину найти не удалось.

Что узнали:

- **Greeter — это стек, а не приложение**: greetd → компоновщик → GTK/Slint-приложение. Каждый слой
  может сломаться. У noctalia-greeter компоновщик свой и встроенный, у regreet/mdgreet мы сами
  собирали обвязку (niri-конфиг, `dbus-run-session`, `swaybg`, `systemd-cat`, `plymouth --retain-splash`)
  — лишние слои без выгоды.
- **Предпочитать штатный модуль nixpkgs** собственной обвязке. Всё, что мы дописывали вокруг
  greeter-а, — дополнительные точки отказа.
- **Прерывистый баг ввода не ловится постфактум.** В «хороших» и «плохих» загрузках логи niri и
  regreet совпадали построчно, ошибок ввода (libseat/libinput) не было. Если баг повторится у
  другого greeter-а, диагностику (`niri msg event-stream` в журнал, debug-логи) надо включать
  заранее, а не после сбоя. Не включать `WAYLAND_DEBUG` — в журнал попадут нажатия клавиш, в
  том числе пароль.
- **Проверять вид до перезагрузки**: `regreet --demo` с `XDG_CONFIG_HOME` на пустой каталог
  (иначе GTK подхватит `~/.config/gtk-4.0`) и скриншот через `grim`. Демо не проверяет ввод,
  автоматический вход и поведение при реальном старте — только внешний вид.
- **Greeter-пользователь не читает `$HOME`.** Всё нужное ему (обои, палитра) должно лежать в
  `/nix/store` или в `/var/lib/...`. Для «живых» файлов вне стора мы делали хук Noctalia +
  `tmpfiles`, но если greeter умеет синхронизацию сам (Noctalia Greeter: Settings → Security →
  Auto-Sync Greeter + `passwordlessSyncUsers`), этот хук не нужен.
- **Input на собственном nixpkgs автора** (так было с mdgreet) выбивает пакет из бинарного кэша
  и приводит к сборке Rust из исходников. Без кэша автора такие inputs не брать.
- **Страховка при смене greeter-а**: применять через `boot`, не `switch`; в загрузчике
  остаётся предыдущее поколение; на случай неработающего greeter-а — `Ctrl+Alt+F2` и вход с TTY.
- **Не заявлять «готово» по проверке в демо.** Greeter реально проверяется только перезагрузкой.
- **Если regreet когда-нибудь вернётся**: в `regreet --demo` верстка Material-стиля делается только
  CSS-ом поверх GTK (размытие фона на нескольких мониторах не работает, заранее размытые обои
  лежат в одном файле для `swaybg`); коммиты `ea61bdc`, `126a26a`, `750cdab` в истории.

## Связанные репозитории

- **hyprdev** (`~/hyprdev`) — дотфайлы (user-уровень, симлинки в ~/.config). WM-агностичная часть (nvim, zsh, yazi, starship, fastfetch, eza, kitty, opencode) общая для обоих хостов; niri/noctalia — только tecno. Репо-база знаний — `INSIGHTS.md`.
