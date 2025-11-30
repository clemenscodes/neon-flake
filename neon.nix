{
  rustPlatform,
  fetchFromGitHub,
  bash,
  bison,
  coreutils,
  readline,
  zlib,
  icu,
  openssl,
  libseccomp,
  curl,
  protobuf,
  flex,
  perl,
  pkg-config,
  makeWrapper,
  withCustomRustToolchain ? false,
  rustToolchain ? {},
}:
rustPlatform.buildRustPackage rec {
  pname = "neon";

  version = "release-9129";

  src = fetchFromGitHub {
    owner = "neondatabase";
    repo = pname;
    rev = version;
    hash = "sha256-qgU+dfdukO0V3LOOOmuIFFtyDYXYRxU4X/7doCez8ZY=";
    fetchSubmodules = true;
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    hash = "sha256-C9EatnwZr+QjIzGa44bZPjMJptKLrpjCL2ZXJ+jpAeU=";
  };

  postPatch = ''
    # Remove trailing slash in ROOT_PROJECT_DIR
    substituteInPlace Makefile \
      --replace-fail \
        'ROOT_PROJECT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))' \
        'ROOT_PROJECT_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))'

    # Avoid git calls to determine postgres fork commit hash revision
    # hardcode neon tag instead to find out fork revisions in <neon-src>/vendor/revisions.json
    substituteInPlace ./postgres.mk \
      --replace-fail "&& git rev-parse HEAD" "&& echo ${version}"

    substituteInPlace ./scripts/ninstall.sh \
      --replace-fail /bin/bash ${bash}/bin/bash

    substituteInPlace ./vendor/postgres-v14/configure \
      --replace-fail /bin/pwd ${coreutils}/bin/pwd

    substituteInPlace ./vendor/postgres-v15/configure \
      --replace-fail /bin/pwd ${coreutils}/bin/pwd

    substituteInPlace ./vendor/postgres-v16/configure \
      --replace-fail /bin/pwd ${coreutils}/bin/pwd

    substituteInPlace ./vendor/postgres-v14/configure.ac \
      --replace-fail /bin/pwd ${coreutils}/bin/pwd

    substituteInPlace ./vendor/postgres-v15/configure.ac \
      --replace-fail /bin/pwd ${coreutils}/bin/pwd

    substituteInPlace ./vendor/postgres-v16/configure.ac \
      --replace-fail /bin/pwd ${coreutils}/bin/pwd

    substituteInPlace ./vendor/postgres-v17/configure \
      --replace-fail /bin/pwd ${coreutils}/bin/pwd

    substituteInPlace ./vendor/postgres-v17/configure.ac \
      --replace-fail /bin/pwd ${coreutils}/bin/pwd
  '';

  buildInputs = [
    bash
    coreutils
    curl
    icu
    openssl
    libseccomp
    readline
    zlib
  ];

  nativeBuildInputs =
    [
      pkg-config
      bison
      flex
      perl
      protobuf
      makeWrapper
      rustPlatform.bindgenHook
    ]
    ++ (
      # Compiling with the default nixpkgs rust toolchain works but will produce warnings
      # however using the supported toolchain requires using IFD (with fenix)
      # which makes it incompatible with nixpkgs
      if withCustomRustToolchain
      then [rustToolchain]
      else []
    );

  BUILD_TYPE = "release";

  CARGO_BUILD_FLAGS = "--features=testing";

  doCheck = false;

  dontFixup = true;

  buildPhase = ''
    make -j`nproc` -s
  '';

  installPhase = ''
    mkdir -p $out/{bin,share}
    cp -r pg_install/* $out/share
    ln -s $out/share/v17/lib $out/lib
    ln -s $out/share/v17/bin/* $out/bin
    for bin in target/release/{compaction-simulator,compute_ctl,endpoint_storage,fast_import,local_proxy,neon_local,pagebench,pagectl,pageserver,pg_sni_router,proxy,safekeeper,storage_broker,storage_scrubber,storcon_cli,test_helper_slow_client_reads,vm-monitor,wal_craft}; do
      binfile=$(basename $bin)
      cp "$bin" "$out/bin/.unwrapped-$binfile"
      makeWrapper "$out/bin/.unwrapped-$binfile" "$out/bin/$binfile" \
        --set POSTGRES_INSTALL_DIR "$out/share" \
        --set POSTGRES_DISTRIB_DIR "$out/share" \
        --set PG_VERSION "v17" \
        --set DEFAULT_PG_VERSION "v17" \
        --set PQ_LIB_DIR "$out/lib" \
        --set LD_LIBRARY_PATH "$out/lib" \
        --prefix PATH : "$out/share/v17/bin"
    done
  '';
}
