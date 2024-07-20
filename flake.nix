{
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  inputs.aws-lc.url = "github:aws/aws-lc/v1.32.0";
  inputs.aws-nitro-enclaves-nsm-api.url = "github:aws/aws-nitro-enclaves-nsm-api/v0.4.0";
  inputs.aws-nitro-enclaves-sdk-c.url = "github:aws/aws-nitro-enclaves-sdk-c/v0.4.1";
  inputs.s2n-tls.url = "github:aws/s2n-tls/v1.4.17";

  inputs.aws-lc.flake = false;
  inputs.aws-nitro-enclaves-nsm-api.flake = false;
  inputs.aws-nitro-enclaves-sdk-c.flake = false;
  inputs.s2n-tls.flake = false;

  outputs = {
    flake-utils,
    self,
    nixpkgs,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (f: p: {
              inherit s2n-tls;
              aws-c-cal = p.aws-c-cal.override {
                openssl = aws-lc;
              };
            })
          ];
        };
        aws-lc = with pkgs;
          stdenv.mkDerivation {
            HOME = "$TMPDIR";
            NIX_CFLAGS_COMPILE = "-Wno-error";
            cmakeFlags = ["-GNinja" "-DBUILD_SHARED_LIBS=1"];
            name = "aws-lc";
            nativeBuildInputs = [cmake ninja go];
            src = inputs.aws-lc + /.;
          };
        s2n-tls = with pkgs;
          stdenv.mkDerivation {
            propagatedBuildInputs = [aws-lc];
            cmakeFlags = ["-GNinja" "-DBUILD_SHARED_LIBS=1"];
            name = "s2n-tls";
            nativeBuildInputs = [cmake ninja];
            src = inputs.s2n-tls + /.;
          };
      in
        with pkgs; {
          packages = rec {
            inherit aws-lc;
            inherit s2n-tls;
            aws-nitro-enclaves-nsm-api = rustPlatform.buildRustPackage {
              cargoBuildFlags = "-p nsm-lib";
              cargoHash = "sha256-Ulka2h8NMNsOpymBvrMuMSE+9e+rf86F/d1+dmNM9/I=";
              cargoPatches = [./cargo-lock.patch];
              pname = "aws-nitro-enclaves-nsm-api";
              src = inputs.aws-nitro-enclaves-nsm-api + /.;
              version = "1.0.0";
              postInstall = ''
                install -Dm644 target/*/release/nsm.h -t $out/include
              '';
            };
            aws-nitro-enclaves-sdk-c = stdenv.mkDerivation {
              cmakeFlags = ["-GNinja" "-DBUILD_SHARED_LIBS=1"];
              name = "aws-nitro-enclaves-sdk-c";
              nativeBuildInputs = [cmake ninja];
              src = inputs.aws-nitro-enclaves-sdk-c + /.;
              propagatedBuildInputs = [
                aws-c-auth
                aws-c-cal
                aws-c-common
                aws-c-compression
                aws-c-http
                aws-c-io
                aws-c-sdkutils
                aws-nitro-enclaves-nsm-api
                json_c
                s2n-tls
              ];
            };
            default = aws-nitro-enclaves-sdk-c;
          };
        }
    );
}
