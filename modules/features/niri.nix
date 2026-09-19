{ self, inputs, ... }: {
  perSystem = { pkgs, lib, ... }: {
    packages.myNiri = inputs.wrapper-modules.wrappers.niri.wrap {
      # Передаем pkgs явно, чтобы wrapper-modules мог использовать callPackage
      pkgs = pkgs; 

      settings = {
        input.keyboard = {
          xkb.layout = "us,ru";
        };

        layout.gaps = 5;

        binds = {
          "Mod+T".spawn-sh = lib.getExe pkgs.kitty;
          "Mod+Q".close-window = {};
          "Mod+Y".spawn-sh = lib.getExe pkgs.kitty + " " + pkgs.yazi;
          "Mod+B".spawn-sh = lib.getExe pkgs.firefox;
        };
      };
    };
  };
}

