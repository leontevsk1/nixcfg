{ ... }: {
  flake.nixosModules.hyprland = { pkgs, ... }: {
    # Hyprland — вторая сессия; конфиг читается из ~/.config/hypr/hyprland.lua (dotfiles hyprdev/config/hypr)
    programs.hyprland.enable = true;

    # Порталы: hyprland — скриншоты/шаринг/диалоги, gtk — общие диалоги
    xdg.portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-hyprland
        pkgs.xdg-desktop-portal-gtk
      ];
    };

    # Бинды из hyprland.lua ссылаются на эти пакеты
    environment.systemPackages = with pkgs; [
      hyprpicker # Mod+Shift+Alt+C — color picker
      hyprpolkitagent # polkit-агент, стартует из автостарта Hyprland
      grim # скриншоты (Noctalia/фолбэк)
      cliphist # история буфера: wl-paste --watch cliphist store
      ddcutil # Mod+яркость — внешка по DDC
    ];
  };
}
