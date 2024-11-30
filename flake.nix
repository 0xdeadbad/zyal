{
  description = "YAL written in Zig";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    zls = {
      url = "github:zigtools/zls?ref=techatrix/dev";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    zls,
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
      default = pkgs.zig-dev;
      zig-dev = zig-dev-derivation;
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
