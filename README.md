# my-typst-fonts

A small Nix flake that packages fonts for Typst documents.

## Packages

| Package | Contents |
|---|---|
| `th-sarabun-new-fonts` | TH Sarabun New (Regular, Bold, Italic, Bold Italic) |
| `default` | All of the above in one environment |

Fonts are installed under `$out/share/fonts/truetype/`. Supported systems are
the ones in `lib.systems.flakeExposed` (for example `x86_64-linux` and
`aarch64-linux`).

## Use

Add the flake as an input and make it share your nixpkgs:

```nix
inputs.fonts = {
  url = "github:songpola/my-typst-fonts";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

With [press](https://github.com/RossSmyth/press), pass the package to
`buildTypstDocument`:

```nix
buildTypstDocument {
  # ...
  fonts = [ inputs.fonts.packages.${system}.th-sarabun-new-fonts ];
}
```

Locally, for `typst compile`:

```sh
nix build github:songpola/my-typst-fonts#th-sarabun-new-fonts
typst compile --font-path result/share/fonts main.typ
```

## Adding a font

Create `fonts/<name>/` with the `.ttf` files and a `meta.nix` (copy the one in
`fonts/th-sarabun-new/`). The flake then exposes `<name>-fonts` and checks that
Typst finds the family and variants listed in `meta.nix`. Add a `NOTICE` or
`LICENSE` next to the files.

`nix flake check` builds every package and runs the Typst check; `nix fmt`
formats with nixfmt.

## Licenses

TH Sarabun New is one of the Thai national fonts by the Software Industry
Promotion Agency (SIPA), designed by Suppakit Chalermlarp. It is licensed under
GPL-2.0-or-later with a font exception: documents that embed the font are not
covered by the GPL. See [fonts/th-sarabun-new/NOTICE](fonts/th-sarabun-new/NOTICE).
The Nix code in this repository is not covered by that license.
