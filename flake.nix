{
  description = "cabang's personal NixOS setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, home-manager, nixpkgs, ...} @ inputs: 
  let
    inherit (self) outputs;
    system = "x86_64-linux";
    hostname = "canix";
    user = "cabang";
    nixOsVersion = "25.05";
  in
  {

    nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit hostname;  inherit user; };   

      modules = [
        home-manager.nixosModules.home-manager 
        ./main.nix

        ./modules/nushell/default.nix
        ./modules/yubikey.nix
        ./modules/socials.nix
        ./modules/nix-alien.nix
        ./modules/gpg.nix
        ./modules/git/default.nix

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
      ];
    };
  };
}
