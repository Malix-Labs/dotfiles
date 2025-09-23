#!/bin/sh

cd /etc/nixos/ || return

nix flake update

nixos-rebuild switch
