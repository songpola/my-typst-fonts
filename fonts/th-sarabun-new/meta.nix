{ lib }:
{
  # Read from the name table of the TTFs ("Version 1.35 2011").
  version = "1.35";
  description = "TH Sarabun New, a Thai national font by SIPA/DIP";
  homepage = "https://www.f0nt.com/release/th-sarabun-new/";
  license = lib.licenses.gpl2Plus;
  # Used by the flake check: Typst must find this family in all these variants.
  family = "TH Sarabun New";
  variants = [
    "Style: Normal, Weight: 400"
    "Style: Normal, Weight: 700"
    "Style: Italic, Weight: 400"
    "Style: Italic, Weight: 700"
  ];
}
