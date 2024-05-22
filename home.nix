{
  homeDirectory,
  pkgs,
  stateVersion,
  system,
  username,
  machine,
  user,
}: let
  programProfiles = import ./programs.nix {
    inherit (pkgs) lib;
    inherit user;
  };
  packageProfiles = import ./packages.nix {inherit pkgs;};
  machinePackages = builtins.getAttr machine.profile packageProfiles;
in rec {
  programs = builtins.getAttr machine.profile programProfiles;

  home = {
    inherit homeDirectory stateVersion username;
    packages = machinePackages;
    shellAliases = {
      reload-home-manager-config = "home-manager switch --flake ${builtins.toString ./.}";
    };
  };

  nixpkgs = {
    config = {
      inherit system;
      allowUnfree = true;
      allowUnsupportedSystem = true;
      experimental-features = "nix-command flakes";
    };
  };
}
