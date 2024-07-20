{
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  inputs.aws-c-auth.url = "github:awslabs/aws-c-auth/v0.6.15";
  inputs.aws-c-cal.url = "github:awslabs/aws-c-cal/v0.5.18";
  inputs.aws-c-common.url = "github:awslabs/aws-c-common/v0.8.0";
  inputs.aws-c-compression.url = "github:awslabs/aws-c-compression/v0.2.14";
  inputs.aws-c-http.url = "github:awslabs/aws-c-http/v0.6.19";
  inputs.aws-c-io.url = "github:awslabs/aws-c-io/v0.11.0";
  inputs.aws-c-sdkutils.url = "github:awslabs/aws-c-sdkutils/v0.1.2";
  inputs.aws-lc.url = "github:aws/aws-lc/v1.12.0";
  inputs.aws-nitro-enclaves-nsm-api.url = "github:aws/aws-nitro-enclaves-nsm-api/v0.4.0";
  inputs.aws-nitro-enclaves-sdk-c.url = "github:aws/aws-nitro-enclaves-sdk-c/v0.4.1";
  inputs.json-c.url = "github:json-c/json-c/json-c-0.16-20220414";
  inputs.s2n-tls.url = "github:aws/s2n-tls/v1.3.46";

  inputs.aws-c-auth.flake = false;
  inputs.aws-c-cal.flake = false;
  inputs.aws-c-common.flake = false;
  inputs.aws-c-compression.flake = false;
  inputs.aws-c-http.flake = false;
  inputs.aws-c-io.flake = false;
  inputs.aws-c-sdkutils.flake = false;
  inputs.aws-lc.flake = false;
  inputs.aws-nitro-enclaves-nsm-api.flake = false;
  inputs.aws-nitro-enclaves-sdk-c.flake = false;
  inputs.json-c.flake = false;
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
              aws-c-cal =
                (p.aws-c-cal.override {
                  openssl = aws-lc;
                })
                .overrideAttrs {
                  src = inputs.aws-c-cal + /.;
                  version = "dummy";
                };
              aws-c-common = p.aws-c-common.overrideAttrs {
                src = inputs.aws-c-common + /.;
                version = "dummy";
              };
              aws-c-compression = p.aws-c-compression.overrideAttrs {
                src = inputs.aws-c-compression + /.;
                version = "dummy";
              };
              aws-c-sdkutils = p.aws-c-sdkutils.overrideAttrs {
                src = inputs.aws-c-sdkutils + /.;
                version = "dummy";
              };
              aws-c-io = p.aws-c-io.overrideAttrs {
                src = inputs.aws-c-io + /.;
                version = "dummy";
              };
              aws-c-http = p.aws-c-http.overrideAttrs {
                src = inputs.aws-c-http + /.;
                version = "dummy";
              };
              aws-c-auth = p.aws-c-auth.overrideAttrs {
                src = inputs.aws-c-auth + /.;
                version = "dummy";
              };
              json_c = p.json_c.overrideAttrs {
                src = inputs.json-c + /.;
                version = "dummy";
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
              nativeBuildInputs = [rustPlatform.bindgenHook];
              postInstall = ''
                install -Dm644 target/*/release/nsm.h -t $out/include
              '';
            };
            aws-nitro-enclaves-sdk-c = stdenv.mkDerivation {
              cmakeFlags = ["-GNinja" "-DBUILD_SHARED_LIBS=1"];
              name = "aws-nitro-enclaves-sdk-c";
              nativeBuildInputs = [cmake ninja];
              patches = [./aws-nitro-enclaves-sdk-c.patch];
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
