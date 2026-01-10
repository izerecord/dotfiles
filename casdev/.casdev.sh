#!/bin/bash

# Proxy settings
source $USER/.ssh/environment

# fish
sudo add-apt-repository -y ppa:fish-shell/release-4
sudo apt-get update -y
sudo apt-get install -y fish
