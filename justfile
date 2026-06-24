@build:
  rm -rf dist && gleam run -m build/pipeline

@update:
  nix flake update --extra-experimental-features flakes --extra-experimental-features nix-command --show-trace

@server:
  http-server -p 8080 dist
