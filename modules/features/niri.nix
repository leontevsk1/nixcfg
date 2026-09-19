{ ... }: {
  flake.nixosModules.niri = { pkgs, ... }: {
    # Niri — стоковая сессия; конфиг читается из ~/.config/niri/config.kdl (dotfiles)
    programs.niri.enable = true;

    # Порталы: скриншоты/шаринг (niri работает с portal-gnome), gtk — общие диалоги
    xdg.portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gnome
        pkgs.xdg-desktop-portal-gtk
      ];
    };

    # Xwayland для X11-приложений (Steam и т.п.), поднимается по env DISPLAY=:0
    environment.systemPackages = [ pkgs.xwayland-satellite ];
  };
}
