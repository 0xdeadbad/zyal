{ pkgs ? import <nixpkgs> {}, zig-dev }:
pkgs.mkShell.override { stdenv = pkgs.fastStdenv; } {
  packages = [
    zig-dev
  ];
  inputsFrom = [];
  shellHook = ''
    echo "Zig $(zig version)"
    zig env
  '';
}
