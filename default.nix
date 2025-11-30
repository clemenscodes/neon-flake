let
  pkgs = import <nixpkgs> {};
in
  pkgs.callPackage ./neon.nix {}
