{ ... }: {
  flake.nixosModules.niri = {
    # Niri — стоковая сессия; конфиг читается из ~/.config/niri/config.kdl (dotfiles)
    programs.niri.enable = true;
  };
}
