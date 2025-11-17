{
  description = "cabang's personal NixOS setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-alien.url = "github:thiagokokada/nix-alien";

    dagger.url = "github:dagger/nix";
    dagger.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    # chorbar = {
    #   type = "github";
    #   owner = "c0dk";
    #   repo = "chorbar";
    #   ref = "feat/observability";
    # };
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
        };

        modules = [

          sops-nix.nixosModules.sops
          ({
            nixpkgs.overlays = [
              inputs.nix-alien.overlays.default
              inputs.dagger.overlays.default
            ];
          })
          home-manager.nixosModules.home-manager

          ./main.nix

          ./modules/hardware-configuration.nix
          ./modules/sops.nix
          ./modules/postgres.nix
          ./modules/configuration.nix
          ./modules/identity.nix
          ./modules/alacritty.nix
          ./modules/ghostty.nix
          ./modules/tmux.nix
          ./modules/nushell/default.nix
          ./modules/yubikey.nix
          ./modules/socials.nix
          ./modules/nix-alien.nix
          ./modules/gpg.nix
          ./modules/git/default.nix
          ./modules/television.nix
          ./modules/opencode.nix

          ./modules/firefox.nix

          ./modules/hyprland/main.nix

          ./modules/bluetooth.nix
          ./modules/audio.nix

          ./modules/coding/core.nix
          ./modules/coding/dotnet.nix
          ./modules/coding/js.nix
          ./modules/coding/python.nix
          ./modules/coding/rust.nix
          ./modules/coding/hugo.nix
          ./modules/coding/go.nix
          ./modules/coding/helix.nix

          ./modules/tailscale.nix
        ];
      };
    };
}
