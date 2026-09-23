{ self, inputs, ... }: {

  flake.nixosConfigurations.tecno = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.tecnoConfiguration
    ];
  };

}
