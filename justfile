# build site
@build:
  zola build && pagefind --site public

@update:
  # Let flake update
  nix flake update --extra-experimental-features flakes --extra-experimental-features nix-command --show-trace
