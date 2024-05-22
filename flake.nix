{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
  }: let
    instanceConfig = nixpkgs.lib.importJSON ./config.json;
    machine = instanceConfig.machine;

    # Values you should modify
    username = instanceConfig.machine.username;
    system = instanceConfig.machine.system; #"aarch64-darwin"; # x86_64-linux, aarch64-multiplatform, etc.
    stateVersion = "22.11"; # See https://nixos.org/manual/nixpkgs/stable for most recent

    pkgs = import nixpkgs {
      inherit system;

      config = {
        allowUnfree = true;
      };
    };

    homeDirPrefix =
      if pkgs.stdenv.hostPlatform.isDarwin
      then "/Users"
      else "/home";
    homeDirectory =
      if username == "root"
      then "/root"
      else "/${homeDirPrefix}/${username}";
    home = import ./home.nix {
      inherit homeDirectory pkgs stateVersion system username machine;
      inherit (instanceConfig) user;
    };
  in {
    homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;

      modules = [
        home
      ];
    };
  };
}
