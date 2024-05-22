  {pkgs}:
  with pkgs; [
    cargo # install rust packages
    procs # like ps
    netcat # verify a port listening
    lsof # inspect open files
    micromamba # asssume mamba environment
    git-credential-manager
  ]
