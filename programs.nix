{
  lib,
  user,
}: let
  common = {
    home-manager = {
      enable = true;
    };
    git = {
      enable = true;
      lfs.enable = true;
      username = user.name;
      email = user.email;
      aliases = {
        co = "checkout";
        st = "status";
      };
    };
  };
in {
  runpod-ml =
    common
    // {
      # native nix stuff goes here, otherwise save it for friendly json
    }
    // lib.importJSON ./programs/runpod-ml.json;
}
