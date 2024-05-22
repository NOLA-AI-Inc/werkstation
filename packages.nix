{pkgs}: let
  omniPackages = with pkgs; [
    cachix
    lorri
  ];
in {
  runpod-ml = import ./packages/runpod-ml.nix {
    inherit pkgs;
  };
}
