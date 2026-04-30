#!/usr/bin/env bash
# Post-Brewfile bootstrap for things not covered by Homebrew.
# Run from the chezmoi source dir: `bash setup.sh`.
set -euo pipefail

# Rust toolchain (needed for tree-sitter-cli, and useful in general).
if ! command -v cargo >/dev/null; then
    echo "Installing rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
    # shellcheck disable=SC1091
    source "$HOME/.cargo/env"
fi

# tree-sitter CLI: required by nvim-treesitter `main` branch to build parsers
# from source. Homebrew's `tree-sitter` formula only ships the C library, not
# the CLI, so cargo is the canonical install path.
if ! command -v tree-sitter >/dev/null; then
    echo "Installing tree-sitter-cli..."
    cargo install tree-sitter-cli
fi

echo "setup.sh: done"
