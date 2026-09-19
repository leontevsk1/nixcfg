{ ... }: {
  flake.nixosModules.noctalia = { pkgs, ... }: {
    # Noctalia (v5) — shell + CLI в одном пакете; настройка через его GUI
    environment.systemPackages = [ pkgs.noctalia ];
  };
}
