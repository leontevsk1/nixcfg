{ self, inputs, ... }: {
  flake.nixosModules.tecnoConfiguration =
    {
      config,
      pkgs,
      lib,
      ...
    }:

    {
      imports = [
        # Include the results of the hardware scan.
        self.nixosModules.commonConfiguration
        self.nixosModules.browsers
        self.nixosModules.cliTools
        self.nixosModules.fonts
        self.nixosModules.proxy
        self.nixosModules.tecnoHardware
        self.nixosModules.niri
        self.nixosModules.thunar
        self.nixosModules.noctalia
        self.nixosModules.noctaliaGreeter
      ];

      networking.hostName = "tecno"; # Define your hostname.
      # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

      # Configure network proxy if necessary
      # networking.proxy.default = "http://user:password@proxy:port/";
      # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

      # Set your time zone.
      time.timeZone = "Asia/Krasnoyarsk";

      # Enable i2c bus
      hardware.i2c.enable = true;
      boot.kernelModules = [ "i2c-dev" ];
      hardware.amdgpu.initrd.enable = true;

      # Группа i2c — для ddcutil (доступ к /dev/i2c-* только членам группы)
      users.users.leont.extraGroups = [
        "i2c"
        "wheel"
        "adbuser"
      ];

      # Сенсоры для Noctalia: батарея, bluetooth, режимы питания
      services.upower.enable = true;
      services.power-profiles-daemon.enable = true;
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
      };

      # Монтирование дисков через Thunar/gvfs (sda1 и т.д.)
      services.udisks2.enable = true;

      # Дискового swap нет (см. hardware-configuration) — zram вместо него.
      # Без любого swap нехватка RAM валит систему в thrashing: 25.10.2026 ребилд
      # (hyprland+rustdesk параллельно) завис на 8 часов, ноут ушёл в перегрев.
      # 50% от 15.5G = ~8G сжатого zram — буфер, при котором oomd/ядро успевают
      # убить виновника вместо смерти всей машины.
      zramSwap = {
        enable = true;
        algorithm = "zstd";
        memoryPercent = 50;
      };

      boot.kernel.sysctl = {
        "vm.swappiness" = 150;
      };

      programs.java = {
        enable = true;
        package = pkgs.jdk; # Defaults to the latest LTS version of OpenJDK
      };
      # programs.adb.enable = true; - no needed more in nixOs

      # List packages installed in system profile.
      # You can use https://search.nixos.org/ to find more packages (and options).
      environment.systemPackages = with pkgs; [
        (python3.withPackages (
          ps: with ps; [
            psutil
          ]
        ))
        # breeze-hacked-cursor-theme # курсорная тема (иконки через pathsToLink)
        kdePackages.breeze # курсоры breeze_cursors (стоковый Breeze)
        kdePackages.qt6ct # Qt6-приложения: тема через QT_QPA_PLATFORMTHEME (стиль Fusion, схема noctalia)
        polkit_gnome # polkit-агент: диалоги авторизации (монтирование, systemd), стартует из niri
        telegram-desktop # мессенджер (Qt6)
        # rustdesk удалён: при каждом обновлении норовил собираться из исходников
        # (Rust-сборка съедает всю RAM) и перегревал ноут. Нужен разово —
        # `nix run nixpkgs#rustdesk` при рабочей сети ставится из кэша.
        bleachbit # очистка системы
        transmission_4-gtk # торрент-клиент (заодно — чистый Qt6-тест тем)
        loupe # просмотрщик изображений (GNOME)
        zathura # просмотрщик PDF/ps/djvu (pdf-mupdf включён по умолчанию)
        wl-clipboard # wl-copy/wl-paste: без них opencode не может вставить изображение из буфера (Ctrl+V)
        nil # LSP-сервер для Nix (nil_ls)
        nixfmt # форматтер Nix, подключается через nil
        nixd # LSP-сервер для Nix: Serena MCP требует именно nixd (nil остаётся за nvim)
        lua-language-server # LSP Lua: Serena (fallback к авто-качаемому)
        gopls # LSP Go: Serena требует установленный gopls
        rustup # Rust: после ребилда один раз `rustup default stable` (gcc выше — линкер)
        gh # GitHub CLI: для агентов (GitHub-MCP отвергнут в пользу CLI — у моделей лучше данные на gh)
        brightnessctl # биндинги XF86MonBrightness в niri ссылаются на него
        wev # Wayland event viewer: отладка Fn-клавиш
        tree-sitter # nvim-treesitter (branch main): компиляция парсеров
        gcc # tree-sitter: сборка C-расширений парсеров
        nodejs # некоторые плагины nvim хотят node
        fcitx5 # im-switch.nvim: авто-раскладка в nvim (fcitx5-remote)
        # opencode # бинарник в ~/.local/bin (v2.2.5), nixpkgs отстаёт — держим ручной
        adw-gtk3 # GTK тема (тёмная, синхронизирована с noctalia)
        papirus-icon-theme # иконки (Papirus-Dark)
        typst
        ddcutil
        zed-editor
        libreoffice
        uv
        nmap
        (mpv.override { scripts = [ mpvScripts.mpris ]; }) # playback + MPRIS (mpv-mpris)
        netcat-openbsd # nc -U unix-socket IPC with mpv (traditional/busybox nc won't work)
        universal-android-debloater
        android-tools
        go
        pandoc
        obsidian
        nwg-look
        nwg-displays
        plantuml # UML-компилятор (jar + обёртка `plantuml`, использует programs.java)
        graphviz # dot: нужен PlantUML для части диаграмм (class/component и др.)
        imagemagick # `magick`: image.nvim (процессор magick_cli) для инлайн-диаграмм в kitty
        herdr
        planner
      ];

      # GTK/QT — синхронизация с Noctalia (adw-gtk3-dark + Papirus-Dark + Inter, breeze_cursors курсор)
      # NixOS-модулей типа gtk.gtk3 нет (это опции home-manager), поэтому
      # settings.ini GTK3/GTK4 генерируем сами — их читают все GTK-приложения.
      environment.etc."xdg/gtk-3.0/settings.ini".text = ''
        [Settings]
        gtk-theme-name=adw-gtk3-dark
        gtk-icon-theme-name=Papirus-Dark
        gtk-font-name=Inter 11
        gtk-cursor-theme-name=breeze_cursors
        gtk-cursor-theme-size=16
        gtk-application-prefer-dark-theme=1
        gtk-xft-antialias=1
        gtk-xft-hinting=1
        gtk-xft-hintstyle=hintslight
        gtk-xft-rgba=rgb
      '';
      environment.etc."xdg/gtk-4.0/settings.ini".text = ''
        [Settings]
        gtk-theme-name=adw-gtk3-dark
        gtk-icon-theme-name=Papirus-Dark
        gtk-font-name=Inter 11
        gtk-cursor-theme-name=breeze_cursors
        gtk-cursor-theme-size=16
      '';
      environment.variables.GTK_THEME = "adw-gtk3-dark";
      # ВАЖНО: Qt 6.11 НЕ парсит "qt5ct;qt6ct" через ';' — вся строка не матчится
      # с ключами плагина и платформенная тема молча не загружается (светлые окна).
      # Все Qt-приложения в системе Qt6 → единое значение "qt6ct".
      environment.variables.QT_QPA_PLATFORMTHEME = "qt6ct";

      # Cursor theme (system-wide: niri sessions, X11 apps)
      environment.variables.XCURSOR_THEME = "breeze_cursors";
      environment.variables.XCURSOR_SIZE = "16";
      # pathsToLink ограничивает, какие поддиректории share/lib попадают в профиль:
      # /share/themes публикует adw-gtk3 в /run/current-system/sw/share/themes;
      # ссылки ~/.config/gtk-4.0 должны вести туда, а не в /usr/share/themes.
      # без /lib/qt-6/plugins не загружается libqt6ct (темы Qt), без /share/glib-2.0
      # не видно gsettings-схем
      environment.pathsToLink = [
        "/share/icons"
        "/share/themes"
        "/share/qt6ct"
        "/share/glib-2.0"
        "/lib/qt-6/plugins"
        "/libexec" # polkit-gnome-агент
      ];
      # Путь к плагинам Qt вне профиля Qt-приложения (libqt6ct: platformthemes).
      # Список, чтобы не конфликтовать с определением из модуля fcitx5 — NixOS смёржит.
      environment.variables.QT_PLUGIN_PATH = [
        "/run/current-system/sw/lib/qt-6/plugins"
      ];

      # Шрифты Fira Code / Droid Sans Mono — только tecno; общие — в features/fonts.nix
      fonts.packages = with pkgs; [
        nerd-fonts.fira-code
        nerd-fonts.droid-sans-mono
      ];

      # Fcitx5 — ЕДИНЫЙ механизм раскладок во всей системе.
      # Win+Space = переключение (TriggerKeys), us/ru в profile.
      # niri xkb-раскладки отключены (пустая секция в dotfiles config.kdl).
      i18n.inputMethod = {
        enable = true;
        type = "fcitx5";
        fcitx5.addons = [ pkgs.qt6Packages.fcitx5-configtool ];
        fcitx5.waylandFrontend = true;
        fcitx5.settings = {
          # ~/.config/fcitx5/profile: раскладки
          inputMethod = {
            "Groups/0" = {
              Name = "Default";
              "Default Layout" = "us";
              "DefaultIM" = "keyboard-ru";
            };
            "Groups/0/Items/0".Name = "keyboard-us";
            "Groups/0/Items/1".Name = "keyboard-ru";
            GroupOrder = {
              "0" = "Default";
            };
          };
          # ~/.config/fcitx5/config: глобальные хоткеи
          globalOptions = {
            Hotkey = {
              # Win+Space — переключение раскладки
              TriggerKeys = "Super+space";
              EnumerateWithTriggerKeys = "True";
              EnumerateSkipFirst = "False";
            };
            "Hotkey/PrevPage" = { };
            "Hotkey/NextPage" = { };
          };
        };
      };

      # Tell uv to install user-level binaries onto $PATH.
      environment.localBinInPath = true;

      # Let unpatched binaries (uv-managed Python, pip wheels with C deps)
      # find a dynamic linker and the shared libraries they expect.
      programs.nix-ld = {
        enable = true;
        libraries = with pkgs; [
          stdenv.cc.cc.lib # libstdc++.so.6 for most wheels
          zlib # CPython, many compiled extensions
          openssl
          libffi
          glibc
          wayland # OpenTUI Wayland clipboard backend
          libpulseaudio # OpenTUI audio support
          alsa-lib # OpenTUI audio support
        ];
      };

      # Some programs need SUID wrappers, can be configured further or are
      # started in user sessions.
      # programs.mtr.enable = true;
      # programs.gnupg.agent = {
      #   enable = true;
      #   enableSSHSupport = true;
      # };

      # List services that you want to enable:

      # Or disable the firewall altogether.
      # networking.firewall.enable = false;

      # Copy the NixOS configuration file and link it from the resulting system
      # (/run/current-system/configuration.nix). This is useful in case you
      # accidentally delete configuration.nix.
      # system.copySystemConfiguration = true;

      # НЕ менять после установки — см. https://nixos.org/manual/nixos/stable/#sec-upgrading
      system.stateVersion = "26.05";

    };
}
