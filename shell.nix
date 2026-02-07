{ pkgs ? import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/master.tar.gz";
  }) {}
}:

let
  smtml = pkgs.ocamlPackages.smtml.overrideAttrs (old: {
    src = pkgs.fetchFromGitHub {
      owner = "formalsec";
      repo = "smtml";
      rev = "00590beec9b8b1751857869ebfe515ac7340de78";
      hash = "sha256-ZS+SVmpmvUP2V3DTQ5+QNjFWgj3O3vFIST5c7CifIos=";
    };
  });
  owiSubShell = import ./vendor/owi/shell.nix { inherit pkgs; };
in

pkgs.mkShell {
  name = "ono-dev-shell";
  dontDetectOcamlConflicts = true;
  inputsFrom = [ owiSubShell ];
  nativeBuildInputs = with pkgs.ocamlPackages; [
    bisect_ppx
    dune_3
    findlib
    menhir
    merlin
    ocaml
    ocamlformat
    ocp-browser
    odig
    odoc
    sedlex
  ];
  buildInputs = with pkgs.ocamlPackages; [
    bos
    cmdliner
    fpath
    menhirLib
    smtml
    pkgs.owi
  ];
}
