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
      # ai-usagebar удалён: у флейка нет бинарного кэша, при каждом обновлении
      # nixpkgs (follows) он пересобирался из исходников (Rust) и перегревал ноут.
      environment.systemPackages = [
        pkgs.noctalia
      ];
    };
}
