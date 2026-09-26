{ self, inputs, ... }: {

  flake.nixosConfigurations.tecno = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = [
      self.nixosModules.tecnoConfiguration
    ];
  };

}
