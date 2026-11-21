#!/bin/sh
sudo nixos-rebuild boot --file . -A flake.nixosConfigurations.ignorant
