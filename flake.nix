{
  description = "A flake for the WASM4 tool";

  outputs = { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      wasm4pkgs = import ./default.nix {
        inherit pkgs;
        system = "x86_64-linux";
      };
    in {

      apps.x86_64-linux = {
        type = "app";
        program = "${self.packages.x86_64.w4}/bin/w4";
      };

      packages.x86_64-linux = {
        wasm4 = pkgs.symlinkJoin {
          name = "wasm4";
          paths = with wasm4pkgs; [ wasm4 graceful-fs ];
        };
        w4 = pkgs.runCommand "w4" { } ''
          mkdir -p $out/bin
          ln -s ${self.packages.x86_64-linux.wasm4}/lib/node_modules/wasm4/cli.js $out/bin/w4
        '';
        default = self.packages.x86_64-linux.w4;
      };

      devShells.x86_64-linux.default =
        pkgs.mkShell { packages = with pkgs; [ nodePackages.node2nix ]; };
    };
}
