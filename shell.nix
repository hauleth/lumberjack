{ pkgs ? import <nixpkgs> {} }:

with pkgs;
with pkgs.beam.packages.erlang;

mkShell {
  buildInputs = [
    elixir
    erlang
    gitMinimal
  ] ++ stdenv.lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.CoreFoundation
    darwin.apple_sdk.frameworks.CoreServices
  ];
}
