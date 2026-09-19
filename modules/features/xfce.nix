{ ... }: {
  flake.nixosModules.xfce = {
    # Enable the X11 windowing system.
    services.xserver.enable = true;

    # Enable the XFCE Desktop Environment.
    services.xserver.displayManager.lightdm.enable = true;
    services.xserver.desktopManager.xfce.enable = true;

    # Configure keymap in X11
    services.xserver.xkb = {
      layout = "us,ru";
      options = "grp:win_space_toggle";
    };
  };
}
