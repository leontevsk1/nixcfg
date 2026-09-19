{ ... }: {
  flake.nixosModules.niri = {
    # Niri — scrollable-tiling Wayland композитор, регистрирует wayland-сессию
    programs.niri.enable = true;
  };
}
