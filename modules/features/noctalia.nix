{ ... }: {
  flake.nixosModules.noctalia = { pkgs, ... }: {
    # Noctalia shell — обычный пакет, настройка через его родной GUI
    environment.systemPackages = [ pkgs.noctalia-shell ];
  };
}
