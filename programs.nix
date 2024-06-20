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
      username = (lib.debug.traceVal user).name;
      email = user.email;
      aliases = {
        co = "checkout";
        st = "status";
      };
    };
  };
  toNestedAttrs = fromAttrSet: let
    # Function to split a string by a delimiter
    # Function to create a nested attribute set from a list of keys and a value
    setAttrPath = path: value:
      builtins.foldl' (acc: key: {${key} = acc;}) value (builtins.tail path) // {${builtins.head path} = value;};

    # Function to convert dot-notation keys to nested attributes
    deepMerge = attrSets:
      builtins.foldl' (acc: attrSet:
        builtins.foldl' (
          key: value:
            if builtins.isAttrs acc."${key}" && builtins.isAttrs value
            then acc // {"${key}" = deepMerge [acc."${key}" value];}
            else acc // {"${key}" = value;}
        )
        acc (builtins.attrNames attrSet)) {}
      (lib.debug.traceVal attrSets);
    convertSingle = k: v: setAttrPath (lib.splitString "." k) v;
  in
    deepMerge (lib.mapAttrsToList convertSingle (lib.debug.traceVal fromAttrSet));
in {
  runpod-ml =
    common
    // {
      # native nix stuff goes here, otherwise save it for friendly json
    }
    // toNestedAttrs (lib.importJSON ./programs/runpod-ml.json);
}
