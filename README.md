## since the world is marmelade

- Sasha created this repo because she was tired of setting up runpods over and over again and wanted a single command to set everything up

```
curl -s "https://raw.githubusercontent.com/NOLA-AI-Inc/werkstation/main/scripts/0-setupinit" | PROFILE=runpod-ml bash



```

## Adding profiles

### packages/[profile].nix

- List of packages to be installed in this profile. Check [home manager options](https://nix-community.github.io/home-manager/options.xhtml) to ensure that a programs entry doesn't exist before adding a bare package. Search for packages [here](https://search.nixos.org/packages)
- I attempted to at least make the programs configuration use standard JSON, but sometimes you'll need access to the nix scope to reference custom packages etc... use `programs.nix` for that. Otherwise edit the JSON file at will
  See:
- programs.nix

## In-house packages

packages/askemon [RUST]

- Consumes a JSON Schema and uses the metadata to prompt the user for a subset of data.
- Dumps the user-entered/validated data into a JSON file
- supports nested objects/arrays
