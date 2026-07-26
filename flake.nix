{
  description = "Fonts packaged for Typst documents";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs =
    { self, nixpkgs }:
    let
      inherit (nixpkgs) lib;
      forAllSystems =
        f: lib.genAttrs lib.systems.flakeExposed (system: f nixpkgs.legacyPackages.${system});

      # One package per directory under ./fonts, named "<dir>-fonts".
      # Each directory holds the TTF/OTF files and a meta.nix (see th-sarabun-new).
      fontDirs = lib.attrNames (
        lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./fonts)
      );

      metaOf = dir: import (./fonts + "/${dir}/meta.nix") { inherit lib; };

      mkFont =
        pkgs: dir:
        let
          meta = metaOf dir;
        in
        pkgs.stdenvNoCC.mkDerivation {
          pname = "${dir}-fonts";
          inherit (meta) version;
          src = ./fonts + "/${dir}";

          dontUnpack = true;
          dontConfigure = true;
          dontBuild = true;

          installPhase = ''
            runHook preInstall
            install -Dm444 -t $out/share/fonts/truetype $src/*.ttf
            runHook postInstall
          '';

          meta = {
            inherit (meta) description homepage license;
            platforms = lib.platforms.all;
          };
        };

      fontPackages =
        pkgs: lib.genAttrs' fontDirs (dir: lib.nameValuePair "${dir}-fonts" (mkFont pkgs dir));
    in
    {
      packages = forAllSystems (
        pkgs:
        let
          fonts = fontPackages pkgs;
        in
        fonts
        // {
          default = pkgs.symlinkJoin {
            name = "my-typst-fonts";
            paths = lib.attrValues fonts;
          };
        }
      );

      checks = forAllSystems (
        pkgs:
        let
          fonts = fontPackages pkgs;
        in
        lib.genAttrs' fontDirs (
          dir:
          let
            meta = metaOf dir;
            pkg = fonts."${dir}-fonts";
          in
          lib.nameValuePair "${dir}-fonts" (
            pkgs.runCommandLocal "check-${dir}-fonts" { nativeBuildInputs = [ pkgs.typst ]; } ''
              typst fonts --ignore-system-fonts --font-path ${pkg}/share/fonts --variants > fonts.txt
              cat fonts.txt
              # Variants listed under the family, up to the next family name.
              awk -v fam=${lib.escapeShellArg meta.family} '
                $0 == fam { on = 1; next }
                on && /^- / { print; next }
                on { exit }
              ' fonts.txt > variants.txt
              ${lib.concatMapStrings (v: ''
                grep -qxF -- ${lib.escapeShellArg "- ${v}, Stretch: FontStretch(1000)"} variants.txt \
                  || { echo "missing variant: ${v}"; exit 1; }
              '') meta.variants}
              touch $out
            ''
          )
        )
      );

      formatter = forAllSystems (pkgs: pkgs.nixfmt);
    };
}
