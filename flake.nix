{
  description = "A flake for wally, a package manager for Roblox";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    utils,
  }:
    utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
      in {
        packages.default = pkgs.rustPlatform.buildRustPackage {
          pname = "wally";
          version = "0.3.2";
          src = ./.;

          # You will need to update this hash when you run the build.
          # Nix will tell you the correct hash if this one is wrong.
          cargoLock = {
            lockFile = ./Cargo.lock;
            outputHashes = {
              "rocket-0.5.0-rc.3" = "sha256-V6Kusn5ZIClIG6Cd1GtVtuJYw2FsT2PNVVQG0vhRrsE=";
            };
          };

          nativeBuildInputs = [pkgs.pkg-config];

          buildInputs = [
            pkgs.openssl
            pkgs.zlib
          ];

          doCheck = false; # Skip tests if they require network/roblox environment
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = [self.packages.${system}.default];
          packages = [
            self.packages.${system}.default
            pkgs.rustc
            pkgs.cargo
          ];
          shellHook = "export RUST_BACKTRACE=1";
        };
      }
    );
}
