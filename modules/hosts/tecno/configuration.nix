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
        self.nixosModules.tecnoHardware
        self.nixosModules.niri
        self.nixosModules.noctalia
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

      # Группа i2c — для ddcutil (доступ к /dev/i2c-* только членам группы)
      users.users.leont.extraGroups = [ "i2c" ];

      # Сенсоры для Noctalia: батарея, bluetooth, режимы питания
      services.upower.enable = true;
      services.power-profiles-daemon.enable = true;
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
      };

      # Монтирование дисков через Nautilus (sda1 и т.д.)
      services.udisks2.enable = true;

      # Enable noctalia-greeter
      services.displayManager.noctalia-greeter = {
        enable = true;
        settings = {
          cursor.size = 16;
          keyboard.layout = "us";
        };
        cursorTheme = {
          package = pkgs.kdePackages.breeze;
          name = "breeze_cursors";
        };
      };

      # Firefox: декларативная приватность (Enterprise Policies, applied at each start).
      # Философия: без урезания функционала — cookies НЕ чистятся, звонки/загрузки работают.
      # Ключи с точками — ОБЯЗАТЕЛЬНО в кавычках (иначе Nix строит вложенные attrsets).
      programs.firefox = {
        enable = true;
        preferencesStatus = "user";
        preferences = {
          # --- Телеметрия и отправка данных ---
          "toolkits.telemetry.unified" = false;
          "toolkits.telemetry.enabled" = false;
          "datareporting.policy.dataSubmissionEnabled" = false;
          "datareporting.healthreport.uploadEnabled" = false;
          "browser.ping-centre.telemetry" = false;
          "browser.newtabpage.activity-stream.feeds.telemetry" = false;
          "browser.newtabpage.activity-stream.telemetry" = false;
          "browser.newtabpage.activity-stream.healthreport.uploadEnabled" = false;
          "app.shield.optoutstudies.enabled" = false;
          "app.normandy.enabled" = false;
          "app.normandy.api_url" = "";
          "browser.discovery.enabled" = false;
          "extensions.htmlaboutaddons.recommendations.enabled" = false;
          "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
          "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;

          # --- Спонсорский контент и рекомендации ---
          "browser.newtabpage.activity-stream.showSponsored" = false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
          "browser.urlbar.quicksuggest.dataCollection.enabled" = false;
          "browser.urlbar.suggest.quicksuggest.sponsored" = false;
          "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;

          # --- Преждевременные соединения (утечки keystrokes/URL) ---
          "browser.urlbar.speculativeConnect.enabled" = false;
          "browser.urlbar.suggest.searches" = false; # подсказки поиска в адресной строке
          "browser.search.suggest.enabled" = false;
          "network.prefetch-next" = false;
          "network.dns.disablePrefetch" = true;
          "network.predictor.enabled" = false;
          "network.http.speculative-parallel-limit" = 0;
          "network.connectivity-service.enabled" = false;
          "network.captive-portal-service.enabled" = false; # авто-детект captive wifi выключен
          "browser.region.update.enabled" = false;

          # --- SafeBrowsing: локальная защита остаётся, отправка URL/files в Google — нет ---
          "browser.safebrowsing.downloads.remote.enabled" = false;
          "browser.safebrowsing.downloads.remote.url" = "";
          "browser.safebrowsing.provider.google4.dataSharing.enabled" = false;
          "browser.safebrowsing.provider.google4.dataSharingURL" = "";
          "browser.safebrowsing.provider.google.dataSharing.enabled" = false;

          # --- HTTPS-Only ---
          "dom.security.https_only_mode" = true;
          "dom.security.https_only_mode_send_http_background_request" = false;

          # --- OCSP off: запросы к CA палят browsing; отзыв через CRLite ---
          "security.OCSP.enabled" = 0;
          "security.OCSP.require" = false;

          # --- WebRTC: звонки работают, локальные IP не светятся ---
          "media.peerconnection.ice.no_host" = true;
          "media.peerconnection.ice.default_address_only" = true;

          # --- Прочие утечки ---
          "geo.enabled" = false; # нужен гео на сайте — вернуть true
          "dom.battery.enabled" = false;
          "browser.uitour.enabled" = false;
          "browser.uitour.url" = "";
          "browser.sessionstore.privacy_level" = 2; # формы в session restore не пишутся
          "privacy.globalprivacycontrol.enabled" = true; # GPC-сигнал
          "privacy.globalprivacycontrol.webexposed" = true;
          "network.auth.subresource-http-auth-allow" = 1;
          "extensions.pocket.enabled" = false;

          # --- ETP Strict (трекеры, браузерная антифингерпринт-защита) ---
          "browser.contentblocking.category" = "strict";
        };
      };
      programs.throne.enable = true;
      # yazi: БЕЗ programs.yazi модуля — он всегда экспортирует YAZI_CONFIG_HOME
      # в /nix/store, из-за чего ~/.config/yazi (дотфайлы hyprdev) игнорируется.
      # Чистый пакет читает ~/.config/yazi как обычно.

      # List packages installed in system profile.
      # You can use https://search.nixos.org/ to find more packages (and options).
      environment.systemPackages = with pkgs; [
        (python3.withPackages (
          ps: with ps; [
            psutil
          ]
        ))
        yazi # файловый менеджер (TOML-конфиг из ~/.config/yazi, flavors в дотфайлах)
        # breeze-hacked-cursor-theme # курсорная тема (иконки через pathsToLink)
        kdePackages.breeze # курсоры breeze_cursors (стоковый Breeze)
        kdePackages.qt6ct # Qt6-приложения: тема через QT_QPA_PLATFORMTHEME (стиль Fusion, схема noctalia)
        yadm # менеджер дотфайлов (XDG: ~/.config/yadm)
        glib # gsettings CLI: Throne пишет системный прокси через gsettings (org.gnome.system.proxy), Firefox его читает
        gvfs # монтирование дисков/сетки в Nautilus (бэкенд udisks2)
        polkit_gnome # polkit-агент: диалоги авторизации (монтирование, systemd), стартует из niri
        gsettings-desktop-schemas # схемы org.gnome.*: без них gsettings падает с "No schemas installed"
        telegram-desktop # мессенджер (Qt6)
        bleachbit # очистка системы
        transmission_4-gtk # торрент-клиент (заодно — чистый Qt6-тест тем)
        psmisc # killall/pstree — раньше killall отсутствовал и ломал диагностику процессов
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
        wget
        kitty
        eza
        tree-sitter # nvim-treesitter (branch main): компиляция парсеров
        gcc # tree-sitter: сборка C-расширений парсеров
        nodejs # некоторые плагины nvim хотят node
        ripgrep
        fzf
        fd
        bat
        zoxide # zsh: smart cd
        starship # zsh: prompt
        fcitx5 # im-switch.nvim: авто-раскладка в nvim (fcitx5-remote)
        opencode # coding agent (nixpkgs 1.18.31; dan-online/opencode-nix мёртв с мая 2026 и вечный 1.14.33)
        git
        nautilus
        adw-gtk3 # GTK тема (тёмная, синхронизирована с noctalia)
        papirus-icon-theme # иконки (Papirus-Dark)
        fastfetch
        lazygit
        btop
        super-productivity
        chromium
        typst
        ddcutil
        zed-editor
        libreoffice
        uv
        dnsutils
        nmap
        code2prompt
        mpv
      ];

      programs.neovim.enable = true;
      programs.neovim.defaultEditor = true;
      environment.variables.TERMINAL = "kitty";

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
        gtk-application-prefer-dark-theme=1
      '';
      programs.dconf.enable = true;
      environment.variables.GTK_THEME = "adw-gtk3-dark";
      # ВАЖНО: Qt 6.11 НЕ парсит "qt5ct;qt6ct" через ';' — вся строка не матчится
      # с ключами плагина и платформенная тема молча не загружается (светлые окна).
      # Все Qt-приложения в системе Qt6 → единое значение "qt6ct".
      environment.variables.QT_QPA_PLATFORMTHEME = "qt6ct";

      # Cursor theme (system-wide: niri sessions, X11 apps)
      environment.variables.XCURSOR_THEME = "breeze_cursors";
      environment.variables.XCURSOR_SIZE = "16";
      # pathsToLink ограничивает, какие поддиректории share/lib попадают в профиль:
      # без /share/themes adw-gtk3 недоступен (битые симлинки в ~/.config/gtk-4.0),
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

      fonts.fontconfig.enable = true;

      fonts.packages = with pkgs; [
        nerd-fonts.fira-code
        nerd-fonts.droid-sans-mono
        nerd-fonts.jetbrains-mono
        inter
        # Глифы для статус-баров/интерфейсов (Noctalia, nvim, starship):
        nerd-fonts.symbols-only # Nerd Icons (символьный шрифт)
        material-symbols # Material Symbols
        material-design-icons # Material Design Icons (MDI)
        font-awesome # Font Awesome 7
        corefonts
      ];

      fonts.fontconfig.defaultFonts.sansSerif = [ "Inter" ];
      fonts.fontconfig.defaultFonts.monospace = [ "JetBrainsMono Nerd Font" ];

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

      # Open ports in the firewall.
      # networking.firewall.allowedTCPPorts = [ ... ];
      # networking.firewall.allowedUDPPorts = [ ... ];
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
