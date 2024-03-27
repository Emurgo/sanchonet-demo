#!/usr/bin/env bash
nohup bash -c "nix run .#run-cardano-node" &
sleep 50
#nohup bash -c "nix develop .# --command just run-era"
