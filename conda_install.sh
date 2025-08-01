#!/usr/bin/env bash
# install_conda.sh  — unattended Miniconda install

set -euo pipefail        # stop on error
INSTALL_DIR="$HOME/miniconda3" # or "$HOME/miniconda3" for per-user installs
CONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"

tmpdir=$(mktemp -d)
curl -fsSL "$CONDA_URL" -o "$tmpdir/miniconda.sh"
bash "$tmpdir/miniconda.sh" -b -p "$INSTALL_DIR"      # <— silent install
rm -rf "$tmpdir"


# Optional: make Conda available system-wide
echo "export PATH=$INSTALL_DIR/bin:\$PATH" | sudo tee /etc/profile.d/conda.sh >/dev/null
"$INSTALL_DIR/bin/conda" init bash zsh  # adds shell hook lines
source ~/.bashrc 
"$HOME/miniconda3/bin/conda" config --system --set plugins.auto_accept_tos yes 
echo "✅ Miniconda installed to $INSTALL_DIR"

