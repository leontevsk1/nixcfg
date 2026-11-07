{
  flake.nixosModules.mdgreet =
    {
      pkgs,
      lib,
      inputs,
      ...
    }:

    let
      mdgreetPkg = inputs.mdgreet.packages.${pkgs.stdenv.hostPlatform.system}.default;

      mdgreetConfig = {
        appearance = {
          greeting = "Welcome back";
          theme = {
            name = "seed";
            mode = "dark";
            seed_color = "#89b4fa";
          };
        };
      };

      # Минимальный niri только для грейтера: без биндов, mdgreet на весь экран,
      # по завершении mdgreet niri выходит и greetd стартует пользовательскую сессию
      niriConfig = pkgs.writeText "niri-greet.kdl" ''
        hotkey-overlay { skip-at-startup; }

        window-rule {
          match at-startup=true
          open-fullscreen true
        }

        spawn-sh-at-startup "${lib.getExe mdgreetPkg} ; ${lib.getExe pkgs.niri} msg action quit --skip-confirmation"
      '';
    in
    {
      # Бинарный кэш автора: без него Rust-пакет собирается из исходников.
      # extra-* — дописывает к cache.nixos.org, а не заменяет
      nix.settings = {
        extra-substituters = [ "https://mois3y.cachix.org" ];
        extra-trusted-public-keys = [
          "mois3y.cachix.org-1:DdCvRmrGrXyR+lG9dPP9n+IQh7v6aa/mL2kJ22gFKII="
        ];
      };

      environment.etc."greetd/mdgreet.toml".source =
        (pkgs.formats.toml { }).generate "mdgreet.toml" mdgreetConfig;

      systemd.tmpfiles.settings."10-mdgreet" = {
        "/var/cache/mdgreet".d = {
          mode = "0755";
          user = "greeter";
          group = "greeter";
        };
        "/var/log/mdgreet".d = {
          mode = "0755";
          user = "greeter";
          group = "greeter";
        };
      };

      services.greetd = {
        enable = true;
        settings.default_session = {
          command = "${lib.getExe pkgs.niri} --config ${niriConfig}";
          user = "greeter";
        };
      };
    };
}
