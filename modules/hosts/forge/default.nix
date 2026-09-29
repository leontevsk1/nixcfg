{ self, inputs, ... }: {

  flake.nixosConfigurations.forge = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = [
      self.nixosModules.forgeConfiguration
    ];
  };

}
