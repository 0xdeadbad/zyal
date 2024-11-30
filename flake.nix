{
  description = "YAL written in Zig";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    zig-src = {
      url = "git+https://github.com/ziglang/zig?ref=master";
      flake = false;
    };
    zls = {
      url = "github:zigtools/zls?ref=techatrix/dev";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    zig-src,
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
      zig-dev = (import ./default.nix {
        inherit pkgs;
        inherit zig-src;
      });
    in
    {
      default = zig-dev;
    });

    devShells = forAllSystems (system:
    let
      pkgs = nixpkgsFor."${system}";
      zig-dev = (import ./default.nix {
        inherit pkgs;
        inherit zig-src;
      });
    in
    {
      default = (import ./shell.nix {
        inherit pkgs;
        inherit zig-dev;
        inherit zls;
      });
    });
  };
}
