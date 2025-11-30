{
  fenix,
  system,
}: (final: prev: {
  neon = let
    neon = prev.callPackage ./neon.nix {};
  in
    neon.override {
      withCustomRustToolchain = true;
      rustToolchain = fenix.packages.${system}.fromToolchainFile {
        file = "${neon.src}/rust-toolchain.toml";
        sha256 = "sha256-Qxt8XAuaUR2OMdKbN4u8dBJOhSHxS+uS06Wl9+flVEk=";
      };
    };
})
