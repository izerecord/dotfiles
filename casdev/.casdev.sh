#!/bin/bash

# Proxy settings
export http_proxy="http://webproxy.kvnbw.de:3128"
export https_proxy="http://webproxy.kvnbw.de:3128"
export no_proxy="localhost,.intinf.dvvbw.net,.kvnbw.net"


# fish
sudo add-apt-repository -y ppa:fish-shell/release-4
sudo apt-get update -y
sudo apt-get install -y fish

# rust
#curl -sSf https://sh.rustup.rs | sh -s -- -y
#export PATH="$HOME/.cargo/bin:$PATH"
#rustup update
#cargo install fd-find lsd tree-sitter-cli

# neovim
#curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
#sudo rm -rf /opt/nvim
#sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
#rm nvim-linux-x86_64.tar.gz

# go packages
#sudo apt-get remove shfmt -y
#go install mvdan.cc/sh/v3/cmd/shfmt@latest
