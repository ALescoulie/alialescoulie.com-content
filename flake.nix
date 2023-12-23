{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    systems.url = "github:nix-systems/default";
    sitegen.url = "github:ALescoulie/sitegen";
  };

  outputs = {
    systems,
    nixpkgs,
    sitegen,
    ...
  } @ inputs: let
    eachSystem = f:
      nixpkgs.lib.genAttrs (import systems) (
        system:
          f nixpkgs.legacyPackages.${system}
      );
  in {
    packages = eachSystem (pkgs: {
      hello = pkgs.hello;
    });

    devShells = eachSystem (pkgs: {
      default = pkgs.mkShell {
        buildInputs = with pkgs; [
          sitegen.packages.${pkgs.system}.sitegen
        ];
      };
    });
  };
}
