# Neon with Nix

A Nixpkgs-compatible and flake-based build of the Neon database system.

This repository provides:

- a `neon` package (`pkgs.neon`)
- a flake overlay exposing `pkgs.neon`
- an optional Fenix-based Rust toolchain override
- a full development shell with Neon runtime environment
- `neon.nix`, which works with plain nixpkgs via `pkgs.callPackage`
- non-flake compatibility via `default.nix` and `shell.nix`

---

## Features

| Feature                                  | Supported |
| ---------------------------------------- | --------- |
| Works with flakes                        | ✔️        |
| Works with `nix-build`                   | ✔️        |
| Nixpkgs-compatible derivation            | ✔️        |
| Overlay (`neon.overlays.default`)        | ✔️        |
| DevShell with Neon environment           | ✔️        |
| Optional official Rust toolchain (Fenix) | ✔️        |

---

## Usage (flakes)

Add this repository as a flake input:

```nix

{
    inputs.neon.url = "github:clemenscodes/neon-flake";
    inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    outputs = { self, nixpkgs, neon, ... }: let
        system = "x86_64-linux";
        pkgs = import nixpkgs {
            inherit system;
            overlays = [ neon.overlays.default ];
        };
    in {
        packages.${system}.default = pkgs.neon;
        devShells.${system}.default = pkgs.mkShell {
            buildInputs = [ pkgs.neon ];
        };
    };
}
```

Build Neon:

```nix
nix build .#neon
```

Enter a Neon dev shell:

```nix
nix develop
```

---

## Usage (without flakes)

This repository includes nixpkgs-compatible entrypoints:

- default.nix
- shell.nix

Build via:

```nix
nix-build
```

Enter a dev shell:

```nix
nix-shell
```

Both resolve to:

```nix
pkgs.callPackage ./neon.nix {}
```

---

## Overriding the Rust toolchain

Enable the upstream Rust toolchain (from rust-toolchain.toml) using Fenix:

```nix
pkgs.neon.override {
    withCustomRustToolchain = true;
    rustToolchain = fenix.packages.${system}.fromToolchainFile {
        file = "${pkgs.neon.src}/rust-toolchain.toml";
        sha256 = "sha256-Qxt8XAuaUR2OMdKbN4u8dBJOhSHxS+uS06Wl9+flVEk=";
    };
}
```

This is automatically enabled inside the [overlay](./overlay.nix).

---

## Development Shell

`nix develop` provides a complete Neon runtime environment, exporting all required variables for running:

- pageserver
- safekeeper
- storage controller
- compute node
- postgres binaries

This allows running Neon locally with almost zero manual configuration.

---

## Example consumer flake

A minimal [example](./example/flake.nix) is included showing how to use this flake as a dependency and expose Neon in another project.

---

## License

This repository contains only Nix expressions.  
Neon itself is licensed under its upstream license.
