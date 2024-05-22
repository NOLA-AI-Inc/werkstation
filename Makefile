SHELL := /bin/bash
nix_install:
	# only run if `which nix` returns nnzero
	curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm


configure_path: nix_install
	# only run if ".cargo/bin" is not in PATH
	echo 'export PATH="$$PATH:$$HOME/.cargo/bin:/nix/var/nix/profiles/default/bin"' >> "${HOME}/.bashrc"
	echo $(tail -1 "${HOME}/.bashrc")

home_manager_install: configure_path
	# only run if which home-manager fails
	@apt update -y
	@nix-channel --add https://github.com/nix-community/home-manager/archive/release-23.11.tar.gz home-manager 
	@nix-channel --update
	@nix-shell '<home-manager>' -A install


cargo_env: home_manager_install
	apt install -y cargo pkg-config libssl-dev
	cd packages/askemon	&& make && make install
	@cd /workspace/werkstation
	@cargo install --git https://github.com/asciinema/asciinema
	

runpod-ml: cargo_env
	@echo "Assembling workstation environment"
	@askemon config.schema.json /workspace/config.json
	@home-manager switch --flake "/workspace/werkstation"
