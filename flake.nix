{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };
    crane = {
      url = "github:ipetkov/crane";
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-parts,
    crane,
    fenix,
    rust-overlay,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      overlays = [
        (import rust-overlay)
        (import ./overlay.nix {inherit fenix system;})
      ];
    };
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [inputs.flake-parts.flakeModules.easyOverlay];
      systems = [system];
      perSystem = {
        config,
        system,
        ...
      }: let
        apps = {
          inherit (pkgs) neon;
          default = self.packages.${system}.neon;
        };
      in {
        formatter = pkgs.alejandra;

        overlayAttrs = apps;

        packages = apps;

        devShells = {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              neon
            ];
            shellHook = ''
              export NEON_BIN_DIR=${pkgs.neon}/bin
              export POSTGRES_DISTRIB_DIR=${pkgs.neon}/share
              export NEON_REPO_DIR="$(pwd)/.neon"
              export PG_VERSION="17"
              export DEFAULT_PG_VERSION="$PG_VERSION"
              export NEON_CONFIG="$NEON_REPO_DIR/config"
              export PGDATA="$NEON_REPO_DIR/storage_controller_db"
              export STORAGE_BROKER_PID_FILE="$NEON_REPO_DIR/storage_broker.pid"
              export STORAGE_BROKER_LOG_FILE="$NEON_REPO_DIR/storage_broker.log"
              export STORAGE_CONTROLLER_DB_PORT="1235"
              export STORAGE_CONTROLLER_DB_NAME="storage_controller"
              export STORAGE_CONTROLLER_DB_LOG_FILE="$NEON_REPO_DIR/storage_controller_db.log"
              export STORAGE_CONTROLLER_DB_PID_FILE="$NEON_REPO_DIR/storage_controller_db.pid"
              export STORAGE_CONTROLLER_HOST="127.0.0.1"
              export STORAGE_CONTROLLER_PORT="1234"
              export STORAGE_CONTROLLER_NAME="$STORAGE_CONTROLLER_DB_NAME"
              export STORAGE_CONTROLLER_LOG_FILE="$NEON_REPO_DIR/storage_controller.log"
              export STORAGE_CONTROLLER_PID_FILE="$NEON_REPO_DIR/storage_controller.pid"
              export POSTMASTER_LOG_FILE="$PGDATA/postgres.log"
              export POSTMASTER_PID_FILE="$PGDATA/postmaster.pid"
              export STORAGE_CONTROLLER_INITDB_LOG_FILE="$NEON_REPO_DIR/storage_controller_initdb.log"
              export STORAGE_CONTROLLER_MAX_UNAVAILABLE_SECONDS="10s"
              export STORAGE_CONTROLLER_LISTEN_ADDRESS="$STORAGE_CONTROLLER_HOST:$STORAGE_CONTROLLER_PORT"
              export STORAGE_CONTROLLER_DB_URL="postgresql://$STORAGE_CONTROLLER_HOST:$STORAGE_CONTROLLER_DB_PORT/$STORAGE_CONTROLLER_DB_NAME"
              export PAGESERVER_ID="1"
              export PAGESERVER_PG_PORT="64000"
              export PAGESERVER_HTTP_PORT="9898"
              export PAGESERVER_NAME="pageserver_$PAGESERVER_ID"
              export PAGESERVER_HOME="$NEON_REPO_DIR/$PAGESERVER_NAME"
              export PAGESERVER_PID_FILE="$PAGESERVER_HOME/pageserver.pid"
              export PAGESERVER_LOG_FILE="$PAGESERVER_HOME/pageserver.log"
              export PAGESERVER_METADATA="$PAGESERVER_HOME/metadata.json"
              export SAFEKEEPER_ID="1"
              export SAFEKEEPER_PG_PORT="5454"
              export SAFEKEEPER_HTTP_PORT="7676"
              export SAFEKEEPER_NAME="sk$SAFEKEEPER_ID"
              export SAFEKEEPER_HOME="$NEON_REPO_DIR/safekeepers/$SAFEKEEPER_NAME"
              export SAFEKEEPER_LOG_FILE="$SAFEKEEPER_HOME/safekeeper-$SAFEKEEPER_ID.log"
              export SAFEKEEPER_ID_FILE="$SAFEKEEPER_HOME/safekeeper.id"
              export SAFEKEEPER_PID_FILE="$SAFEKEEPER_HOME/safekeeper.pid"
              export COMPUTE_PORT="55432"
              export COMPUTE_HOST="127.0.0.1"
              export COMPUTE_USER="test"
              export COMPUTE_DB="neondb"
              export COMPUTE_URL="postgresql://$COMPUTE_USER@$COMPUTE_HOST:$COMPUTE_PORT/$COMPUTE_DB"
              export DEFAULT_ENDPOINT="main"
              export DEFAULT_BRANCH="$DEFAULT_ENDPOINT"
              export BRANCH="$DEFAULT_BRANCH"
            '';
          };
        };
      };
    };
}
