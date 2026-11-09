{
  flake.nixosModules.regreet =
    {
      pkgs,
      lib,
      config,
      ...
    }:

    let
      # Живые обои и GTK-палитра Noctalia: хук Noctalia (см. ./regreet/sync.sh)
      # кладёт их сюда без пересборки (greeter-пользователь не читает $HOME).
      # Копии в репозитории — запасные: tmpfiles копирует их, только если файла нет
      themeDir = "/var/lib/regreet-theme";
      # Обои заранее размыты (sync.sh делает то же самое): один и тот же файл
      # показывает и regreet, и swaybg на остальных мониторах
      fallbackWallpaper =
        pkgs.runCommand "wallpaper-blur.jpg" { nativeBuildInputs = [ pkgs.imagemagick ]; }
          "magick ${./regreet/wallpaper.jpg} -resize '1920x1920>' -gaussian-blur 0x14 -quality 90 $out";
      fallbackCss = ./regreet/noctalia.css;
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

        // regreet рисует фон только на одном мониторе; на остальных — те же обои
        spawn-at-startup "${lib.getExe pkgs.swaybg}" "-i" "${themeDir}/wallpaper" "-m" "fill"

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
        # палитра Noctalia подключается из живого файла, поверх — правки вида
        extraCss = ''
          @import url("file://${themeDir}/noctalia.css");
          ${builtins.readFile ./regreet/tweaks.css}
        '';
        settings = {
          skip_selection = true;
          background = {
            path = "${themeDir}/wallpaper";
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

      systemd.tmpfiles.settings."10-regreet-theme" =
        let
          common = {
            user = "leont";
            group = "users";
            mode = "0644";
          };
        in
        {
          ${themeDir}.d = common // {
            mode = "0755";
          };
          "${themeDir}/wallpaper".C = common // {
            argument = "${fallbackWallpaper}";
          };
          "${themeDir}/noctalia.css".C = common // {
            argument = "${fallbackCss}";
          };
        };

      # Plymouth оставляет последний кадр на экране до захвата DRM niri,
      # вместо сброса в консоль (fbcon) между сплэшем и грейтером
      systemd.services.plymouth-quit.serviceConfig.ExecStart = [
        ""
        "-${pkgs.plymouth}/bin/plymouth quit --retain-splash"
      ];

      services.greetd.settings.default_session = {
        # niri пишет логи в stdout, а greetd отдаёт грейтеру tty1 — без systemd-cat
        # они мелькают на экране при старте
        command = "${pkgs.systemd}/bin/systemd-cat -t niri-greeter ${lib.getExe pkgs.niri} --config ${niriConfig}";
        user = "greeter";
      };
    };
}
