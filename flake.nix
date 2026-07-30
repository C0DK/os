{
  description = "cabang's personal NixOS setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-alien.url = "github:thiagokokada/nix-alien";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    self.lfs = true;
  };

  outputs =
    {
      self,
      home-manager,
      nixpkgs,
      nix-alien,
      sops-nix,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      hostname = "cwbfw";
      user = "cwb";
      email = "c@cwb.dk";
      fullName = "Casper Weiss Bang";
      nixOsVersion = "25.11";
      repoPath = "/home/${user}/Documents/os";
    in
    {
      nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
          inherit hostname;
          inherit user;
          inherit nixOsVersion;
          inherit fullName;
          inherit email;
          inherit repoPath;
        };

        modules = [
          sops-nix.nixosModules.sops
          {
            nixpkgs.config.allowUnfree = true;
            nixpkgs.overlays = [
              inputs.nix-alien.overlays.default
            ];
          }
          home-manager.nixosModules.home-manager

          ./system.nix
          ./tools.nix
          ./modules
        ];
      };
    };
}
