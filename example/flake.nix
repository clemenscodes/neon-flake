{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    neon = {
      url = "github:clemenscodes/neon-flake";
    };
  };

  outputs = {
    nixpkgs,
    neon,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      overlays = [(import neon.overlays.default)];
    };
  in {
    devShells = {
      ${system} = pkgs.mkShell {
        buildInputs = [neon.packages.${system}.neon];
      };
    };
  };
}
