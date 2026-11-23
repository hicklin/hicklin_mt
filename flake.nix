{
  description = "rs-matter development and integration-test environments";

  inputs = {
    # UPDATING
    # `flake.lock` is the pin: `nix flake update nixpkgs` moves it, and the
    # lock file records the exact commit. The stable channel is used because
    # it is well covered by the binary cache, which keeps CI fast.
    # Note: `pkgsCross` is not cached for the stable channel - if it is ever
    #       needed here, switch to a `nixpkgs-unstable` commit from a highly
    #       successful hydra run: https://hydra.nixos.org/jobset/nixpkgs/trunk/evals
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, rust-overlay, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # Rust toolchain - pinned. To bump, edit rustVersion below and commit.
        # For nightly: set rustChannel = "nightly" and use a date string,
        #   e.g. rustVersion = "2026-08-01".
        # Available versions: https://rust-lang.github.io/rustup-components-history/
        rustChannel = "stable";
        rustVersion = "1.100.0";

        pkgs = import nixpkgs {
          inherit system;
          overlays = [ rust-overlay.overlays.default ];
        };

        nixpkgsDate =
          let d = nixpkgs.sourceInfo.lastModifiedDate or ""; in
          if d == "" then "unknown"
          else "${builtins.substring 0 4 d}-${builtins.substring 4 2 d}-${builtins.substring 6 2 d}";

        rustToolchain = pkgs.rust-bin.${rustChannel}.${rustVersion}.default.override {
          extensions = [ "rust-src" "rustfmt" "clippy" "rust-analyzer" ];
        };
      in
      {
        devShells.default = pkgs.mkShell{
          buildInputs = [
            rustToolchain

            pkgs.cargo-expand
            pkgs.git
            pkgs.zola
          ];

          shellHook = ''
            echo ""
            echo "═══════════════════════════════════════════════════════════"
            echo "📌 nixpkgs: ${nixpkgs.shortRev or "unknown"} (${nixpkgsDate})"
            echo "🦀 Rust: ${rustChannel} ${rustVersion}"
            echo "═══════════════════════════════════════════════════════════"
            echo ""
          '';

        };
      }
    );
}
