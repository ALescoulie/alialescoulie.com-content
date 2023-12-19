{
  description = "Application packaged using poetry2nix";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sitegen.url = "github:ALescoulie/sitegen";
  };

  outputs = { self, nixpkgs, flake-utils, poetry2nix, sitegen }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # see https://github.com/nix-community/poetry2nix/tree/master#api for more functions and examples.
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (poetry2nix.lib.mkPoetry2Nix { inherit pkgs; }) mkPoetryApplication;

        customOverrides = final: prev: {
          pandoc = prev.pandoc.overrideAttrs (oldAttrs: {
            buildInputs = [ prev.setuptools ];
            runtimeInputs = [ prev.setuptools ];
          });
        };

        pandoc = pkgs.legacyPackages.${system}.pandoc;

      in
      {
        packages = {
          myapp = mkPoetryApplication { projectDir = self; };
          default = self.packages.${system}.myapp;
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = [ self.packages.${system}.myapp ];
          packages = [ pkgs.poetry pandoc ];
        };
      });
}
