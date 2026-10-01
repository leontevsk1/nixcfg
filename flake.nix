{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";

    ai-usagebar.url = "github:akitaonrails/ai-usagebar";
    # Один nixpkgs на весь флейк — без этого в lock живёт второй nixpkgs
    # (upstream-пин ветки nixpkgs-26.05-darwin)
    ai-usagebar.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
