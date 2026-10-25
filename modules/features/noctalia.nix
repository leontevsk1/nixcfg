{
  flake.nixosModules.noctalia =
    {
      config,
      pkgs,
      inputs,
      ...
    }:
    {
      # Noctalia (v5) — shell + CLI в одном пакете; настройка через его GUI
      # ai-usagebar — виджет usage-бара (см. комментарий в flake.nix: инпут
      # пинован и отвязан от нашего nixpkgs, обновлять только вручную —
      # у флейка нет бинарного кэша, апдейт = пересборка из исходников).
      environment.systemPackages = [
        pkgs.noctalia
        inputs.ai-usagebar.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };
}
