#!/usr/bin/env bash
/root/.nix-profile/bin/nohup bash -c "/root/.nix-profile/bin/nix run .#run-cardano-node 2>&1 &" && sleep 6
sleep 100
#nohup bash -c "nix develop .# --command just run-era"
