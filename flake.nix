{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flakelight = {
      url = "github:nix-community/flakelight";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { flakelight, ... }@inputs:
    flakelight ./. (
      { lib, ... }:
      {
        inherit inputs;

        packages = {
          th-sarabun-new-fonts =
            { runCommandLocal }:
            runCommandLocal "th-sarabun-new-fonts" { } ''
              mkdir -p $out/share/fonts
              cp -r ${./fonts/th-sarabun-new}/. $out/share/fonts/truetype/
            '';
        };
      }
    );
}
