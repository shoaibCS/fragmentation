#!/usr/bin/env bash
set -euo pipefail

# where you want Rust to live
export RUSTUP_HOME="$HOME/rustup"
export CARGO_HOME="$HOME/cargo"

curl -fsSL https://sh.rustup.rs -o /tmp/rustup.sh
sh /tmp/rustup.sh -y --no-modify-path --profile minimal --default-toolchain stable
rm /tmp/rustup.sh

# expose it to every shell
echo 'export PATH=/$HOME/cargo/bin:$PATH' | sudo tee /etc/profile.d/rust.sh >/dev/null


echo "✅ Rust installed to $HOME/cargo/bin"

