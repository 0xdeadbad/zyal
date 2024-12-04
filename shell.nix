{ pkgs ? import <nixpkgs> {} }:
with pkgs;
let
  zig-dev = callPackage ./default.nix { inherit pkgs; };
in
pkgs.mkShell.override { stdenv = pkgs.fastStdenv; } {
  packages = [
    zig-dev
    pkgs.zls
  ];
  shellHook = ''
    export PS1='\n\[\033[1;34m\][NIX-SHELL(${zig-dev.pname}):\w]\$\[\033[0m\] '
    echo '======================='
    echo "Zig $(zig version)"
    zig env
    echo '======================='
  '';
}
