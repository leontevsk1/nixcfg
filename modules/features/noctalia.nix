{
  flake.nixosModules.noctalia = {
    config,
    pkgs,
    inputs,
    ...
  }: {
    # Noctalia (v5) — shell + CLI в одном пакете; настройка через его GUI
    environment.systemPackages = [
      pkgs.noctalia
      inputs.ai-usagebar.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
