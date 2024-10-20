{
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    supportedSystems = ["x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin"];

    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    nixpkgsFor = forAllSystems (system: import nixpkgs {inherit system;});
  in {
    packages = forAllSystems (system: let
      pkgs = nixpkgsFor.${system};

      inherit (pkgs) ocamlPackages ocaml lib;
    in {
      nixgrep = ocamlPackages.buildDunePackage rec {
        pname = "nixgrep";
        version = "unstable";

        src = builtins.path {
          name = "${pname}-source";
          path = ./.;
        };

        propagatedBuildInputs = [ocamlPackages.result];
        doCheck = lib.versionAtLeast ocaml.version "5.0.0";
      };
    });

    defaultPackage = forAllSystems (system: self.packages.${system}.nixgrep);
  };
}
