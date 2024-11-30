{ pkgs ? import <nixpkgs> {}, zig-dev, zls }:
pkgs.mkShell.override { stdenv = pkgs.fastStdenv; } {
  packages = [
    zig-dev
    zls
  ];
  inputsFrom = [];
  shellHook = ''
    echo '======================='
    echo "Zig $(zig version)"
    zig env
    echo '======================='
  '';
}
