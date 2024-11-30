{
  pkgs,
  zig-src,
}:
let
  stdenv = pkgs.fastStdenv;
  lib = pkgs.lib;
  coreutils = pkgs.coreutils;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "zig-dev";
  version = "0.14.0";
  src = zig-src;

  nativeBuildInputs = with pkgs; [
    cmake
  ] ++ (with llvmPackages_19; [
    (pkgs.lib.getDev llvm)
  ]);

  buildInputs = with pkgs; [
    libxml2
    zlib
    zstd
  ] ++ ( with llvmPackages_19; [
    libclang
    lld
    llvm
  ]);

  cmakeFlags = [
    # file RPATH_CHANGE could not write new RPATH
    (lib.cmakeBool "CMAKE_SKIP_BUILD_RPATH" true)
    # ensure determinism in the compiler build
    (lib.cmakeFeature "ZIG_TARGET_MCPU" "baseline")
    # always link against static build of LLVM
    (lib.cmakeBool "ZIG_STATIC_LLVM" true)

    (lib.cmakeBool "ZIG_STATIC_ZSTD" true)

    (lib.cmakeBool "ZIG_STATIC_ZLIB" true)
  ];

  env.ZIG_GLOBAL_CACHE_DIR = "global-zig-cache";
  env.ZIG_LOCAL_CACHE_DIR = "local-zig-cache";

  doInstallCheck = true;

  strictDeps = !stdenv.cc.isClang;

  preConfigure = ''
    cmakeFlagsArray+=(
    "-DCMAKE_INSTALL_PREFIX=$out"
    )
  '';

  buildPhase = ''
    make -j $NIX_BUILD_CORES
  '';

  postBuild = ''
    $PWD/stage3/bin/zig build langref --zig-lib-dir $PWD/stage3/lib/zig/
  '';

  installPhase = ''
    make install
  '';

  postPatch = ''
    substituteInPlace lib/std/zig/system.zig \
    --replace "/usr/bin/env" "${lib.getExe' coreutils "env"}"
  '';

  postInstall = ''
    install -Dm444 $PWD/../zig-out/doc/langref.html -t $doc/share/doc/zig-${finalAttrs.version}/html
  '';

  installCheckPhase = ''
    $PWD/stage3/bin/zig test --cache-dir "${finalAttrs.env.ZIG_LOCAL_CACHE_DIR}" --global-cache-dir "${finalAttrs.env.ZIG_GLOBAL_CACHE_DIR}" -I $src/test $src/test/behavior.zig
  '';

  meta = {
    description = "Zig ${finalAttrs.version} master branch";
    #  changelog = "https://ziglang.org/download/${finalAttrs.version}/release-notes.html";
    homepage = "https://github.com/ziglang/zig";
    license = lib.licenses.mit;
    mainProgram = "zig";
    platforms = lib.platforms.unix;
  };

})
