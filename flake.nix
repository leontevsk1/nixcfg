{
  inputs = {
    # nixpkgs пинован во flake.lock и НЕ обновляется автоматически: hyprland
    # обновляется только вместе с nixpkgs, а свежие версии могут отсутствовать
    # в кэше (lag hydra) — тогда nix молча собирает их из исходников, и на
    # 15.5ГБ ноутбуке без swap это кончилось 8-часовым зависанием (25.10.2026).
    # Обновлять осознанно: nix flake update nixpkgs, затем ПЕРЕД rebuild
    # проверять dry-run'ом, что тяжёлое появилось в кэше:
    #   nix build .#nixosConfigurations.tecno.config.system.build.toplevel --dry-run
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";

    # ai-usagebar — виджет Noctalia (использование AI-планов). Пинован и живёт
    # на СОБСТВЕННОМ nixpkgs апстрима (ветка 26.05-darwin): без follows наш
    # `nix flake update nixpkgs` его не трогает — Rust-сборка выполняется один
    # раз и лежит в /nix/store, а не на каждый апдейт. Бинарного кэша у флейка
    # нет, поэтому обновлять только осознанно:
    #   nix flake update ai-usagebar
    ai-usagebar.url = "github:akitaonrails/ai-usagebar";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
