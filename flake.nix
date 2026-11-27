{
  description = "hicklin.mt - Zola site development environment";

  inputs = {
    # UPDATING
    # `flake.lock` is the pin: `nix flake update nixpkgs` moves it, and the
    # lock file records the exact commit. The stable channel is used because
    # it is well covered by the binary cache, which keeps CI fast.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        nixpkgsDate =
          let d = nixpkgs.sourceInfo.lastModifiedDate or ""; in
          if d == "" then "unknown"
          else "${builtins.substring 0 4 d}-${builtins.substring 4 2 d}-${builtins.substring 6 2 d}";
      in
      {
        # mkShellNoCC: no C compiler/toolchain is needed to run Zola, which
        # keeps the shell (and every CI run) small.
        devShells.default = pkgs.mkShellNoCC {
          packages = [
            pkgs.git
            pkgs.zola
          ];

          shellHook = ''
            echo "📌 nixpkgs: ${nixpkgs.shortRev or "unknown"} (${nixpkgsDate}) · $(zola --version)"
          '';
        };
      }
    );
}
