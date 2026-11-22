#!/bin/sh
sudo nixos-rebuild switch --file . -A flake.nixosConfigurations.ignorant
