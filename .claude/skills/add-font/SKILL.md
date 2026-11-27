---
name: add-font
description: Add a new font to this flake as fonts/<name>/ with meta.nix, NOTICE and a Typst check. Use when asked to add, package or vendor a font (e.g. Noto Sans JP).
argument-hint: <font name or source URL>
---

# Add a font

Each `fonts/<name>/` directory becomes the package `<name>-fonts` and a check
of the same name; `flake.nix` needs no edit. Follow the layout of
`fonts/th-sarabun-new/`.

## Steps

1. **Pick the name.** Lowercase kebab-case directory (`noto-sans-jp`). The
   package will be `<name>-fonts`.
2. **Get the files.** Put the `.ttf` files directly in `fonts/<name>/` (the
   install phase globs `*.ttf`; if the font is OTF, change the glob in
   `flake.nix` to also cover `*.otf`). Name files without spaces, e.g.
   `Family-Bold.ttf`. Download into a fresh directory first and inspect there;
   treat downloads as untrusted.
3. **Read the real metadata from the files**, don't guess:
   - `nix shell nixpkgs#lcdf-typetools -c otfinfo -i <file>` for family,
     version, copyright and embedded license.
   - `nix shell nixpkgs#typst -c typst fonts --font-path fonts/<name> --variants`
     for the exact family string and the `Style:`/`Weight:` lines Typst sees.
4. **Find the license** from the font's embedded text and the official source.
   If you cannot confirm the terms, stop and ask the user; never pick one.
   If it is non-free, tell the user: packaging it as unfree would break
   consumers that don't set `allowUnfree`.
5. **Write `fonts/<name>/meta.nix`** (same shape as the TH Sarabun one):
   ```nix
   { lib }:
   {
     version = "<from the font>";
     description = "<one line>";
     homepage = "<official source>";
     license = lib.licenses.<id>;
     family = "<exact family name Typst reports>";
     variants = [
       "Style: Normal, Weight: 400"
       # one entry per file, as printed by `typst fonts --variants`
     ];
   }
   ```
6. **Write `fonts/<name>/NOTICE`** (or `LICENSE`) with copyright, license
   text or exception, and source URL.
7. **Update `README.md`**: add a row to the Packages table and, if needed, a
   line in the Licenses section.
8. **Format and verify:**
   ```
   nix fmt -- flake.nix fonts/<name>/meta.nix
   nix flake check
   nix build .#<name>-fonts --no-link
   nix eval .#packages.aarch64-linux.<name>-fonts.outPath
   ```
   `nix flake check` must pass, including the new Typst check. A new
   untracked dir is invisible to flakes in a plain git tree; with jj the
   working copy is snapshotted automatically, so run `jj st` once first.

## Rules

- Keep the `nixpkgs` input name; don't add other inputs.
- Don't mark packages unfree.
- Commit with the `jj-commit` skill. Don't push unless the user asks.
