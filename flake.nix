{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    instance-config-file.url = "file+file:///Users/tastycode/workspace/nola-ai/config.json";
    instance-config-file.flake = false;
    #nixpkgs.lib.importJSON /workspace/config.json;
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    instance-config-file,
  }: let
    instance-config = nixpkgs.lib.importJSON (nixpkgs.lib.debug.traceVal instance-config-file.outPath);
    machine = (nixpkgs.lib.debug.traceVal instance-config).machine;

    # Values you should modify
    username = machine.username;
    system = machine.system; #"aarch64-darwin"; # x86_64-linux, aarch64-multiplatform, etc.
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
      inherit (instance-config) user;
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
