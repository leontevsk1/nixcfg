{
  flake.nixosModules.regreet =
    {
      pkgs,
      lib,
      config,
      ...
    }:

    let
      # Обои и GTK-палитра Noctalia лежат в репозитории (greeter-пользователь не
      # читает $HOME); обновляются скриптом ./regreet/sync.sh
      wallpaper = ./regreet/wallpaper.jpg;
      bg = "#131314";

      # Минимальный niri только для грейтера: без биндов, regreet на весь экран,
      # по завершении regreet niri выходит и greetd стартует пользовательскую сессию
      niriConfig = pkgs.writeText "niri-greet.kdl" ''
        hotkey-overlay { skip-at-startup; }

        // Цвет фона = фон темы: без серой вспышки до первого кадра regreet
        layout { background-color "${bg}"; }
        animations { off; }
        prefer-no-csd
        cursor {
          xcursor-theme "breeze_cursors"
          xcursor-size 16
          hide-after-inactive-ms 1000
        }

        output "eDP-1" { position x=0 y=0; }
        output "HDMI-A-1" { position x=1920 y=0; }

        window-rule {
          match at-startup=true
          open-fullscreen true
        }

        spawn-sh-at-startup "${pkgs.dbus}/bin/dbus-run-session ${lib.getExe config.services.displayManager.regreet.package} ; ${lib.getExe pkgs.niri} msg action quit --skip-confirmation"
      '';
    in
    {
      services.displayManager.regreet = {
        enable = true;
        # Тема/иконки/шрифт/курсор — те же, что в сессии (см. tecno/configuration.nix)
        theme = {
          package = pkgs.adw-gtk3;
          name = "adw-gtk3-dark";
        };
        iconTheme = {
          package = pkgs.papirus-icon-theme;
          name = "Papirus-Dark";
        };
        cursorTheme = {
          package = pkgs.kdePackages.breeze;
          name = "breeze_cursors";
        };
        font = {
          package = pkgs.inter;
          name = "Inter";
          size = 11;
        };
        extraCss = builtins.readFile ./regreet/noctalia.css;
        settings = {
          background = {
            path = "${wallpaper}";
            fit = "Cover";
          };
          GTK.application_prefer_dark_theme = true;
          appearance.greeting_msg = "Welcome back";
          widget.clock = {
            format = "%H:%M";
            resolution = "500ms";
          };
        };
      };

      # Plymouth оставляет последний кадр на экране до захвата DRM niri,
      # вместо сброса в консоль (fbcon) между сплэшем и грейтером
      systemd.services.plymouth-quit.serviceConfig.ExecStart = [
        ""
        "-${pkgs.plymouth}/bin/plymouth quit --retain-splash"
      ];

      services.greetd.settings.default_session = {
        command = "${lib.getExe pkgs.niri} --config ${niriConfig}";
        user = "greeter";
      };
    };
}
