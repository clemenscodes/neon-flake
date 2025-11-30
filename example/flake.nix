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
      overlays = [neon.overlays.default];
    };
  in {
    packages = {
      ${system} = {
        default = pkgs.neon;
      };
    };
    devShells = {
      ${system} = {
        default = pkgs.mkShell {
          buildInputs = [neon.packages.${system}.neon];
        };
      };
    };
  };
}
