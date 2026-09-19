{ ... }: {
  flake.nixosModules.cosmic = { pkgs, ... }: {
    # COSMIC DE — stacking Wayland сессия (запасной вариант вместе с XFCE)
    services.desktopManager.cosmic.enable = true;

    # Порталы для wayland-сессий (скриншоты, шаринг экрана)
    xdg.portal.enable = true;
    xdg.portal.extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
  };
}
