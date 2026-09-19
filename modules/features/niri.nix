{ self, inputs, ... }: {
  flake.nixosModules.niri = { pkgs, lib, config, ... }: {
    # Niri — scrollable-tiling Wayland композитор, регистрирует wayland-сессию
    programs.niri.enable = true;

    # Врапнутый niri с настройками (config.kdl генерируется из settings)
    environment.systemPackages = [
      (inputs.wrapper-modules.wrappers.niri.wrap {
        pkgs = pkgs;

        settings = {
          input.keyboard = {
            xkb.layout = "us,ru";
          };

          layout.gaps = 5;

          spawn-at-startup = [ "noctalia-shell" ];

          binds = {
            "Mod+T".spawn-sh = lib.getExe pkgs.kitty;
            "Mod+Q".close-window = {};
            "Mod+Y".spawn-sh = lib.getExe pkgs.kitty + " -e " + lib.getExe pkgs.yazi;
            "Mod+B".spawn-sh = lib.getExe pkgs.firefox;
          };
        };
      })
    ];
  };
}
