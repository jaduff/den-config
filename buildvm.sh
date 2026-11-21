#!/bin/sh
nixos-rebuild build-vm --file . -A flake.nixosConfigurations.vm
