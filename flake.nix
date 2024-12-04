{
  description = "YAL written in Zig";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }:
  let
    forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.platforms.unix;
    nixpkgsFor = forAllSystems (system: import nixpkgs {
      inherit system;
      config = { };
      overlays = [ ];
    });
  in
  {
    packages = forAllSystems (system:
    let
      pkgs = nixpkgsFor."${system}";
      zig-dev-derivation = (import ./default.nix {
        inherit pkgs;
      });
    in
    {
      zig-dev = zig-dev-derivation;
      default = self.packages.${system}.zig-dev;
    });

    devShells = forAllSystems (system:
    let
      pkgs = nixpkgsFor."${system}";
    in
    {
      default = (import ./shell.nix {
        inherit pkgs;
      });
    });
  };
}
