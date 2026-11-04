{ ... }: {
  flake.nixosModules.niri = { pkgs, ... }: {
    # Niri — стоковая сессия; конфиг читается из ~/.config/niri/config.kdl (dotfiles)
    programs.niri = {
      enable = true;
      # Nautilus по умолчанию добавляется в D-Bus и обслуживает FileChooser.
      # Без него модуль Niri выбирает GTK-портал; папки открывает Thunar.
      useNautilus = false;
    };

    # Порталы: скриншоты/шаринг (niri работает с portal-gnome), gtk — общие диалоги
    xdg.portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gnome
        pkgs.xdg-desktop-portal-gtk
      ];
    };

    # Xwayland для X11-приложений (Steam и т.п.), поднимается по env DISPLAY=:0
    # + общие Wayland-инструменты (перенесены из hyprland-модуля):
    # grim — скриншоты (Noctalia/фолбэк), cliphist — история буфера обмена
    environment.systemPackages = with pkgs; [
      xwayland-satellite
      grim
      cliphist
    ];
  };
}
