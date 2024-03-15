FROM nixos/nix:latest AS builder
RUN nix-env -iA nixpkgs.direnv
RUN nix-env -iA nixpkgs.just
RUN nix-env -iA nixpkgs.jq
RUN nix-env -iA nixpkgs.ps
RUN mkdir -p /etc/nix
RUN touch /etc/nix/nix.conf
RUN echo "experimental-features = nix-command flakes" > /etc/nix/nix.conf && echo "allow-import-from-derivation = true" >> /etc/nix/nix.conf && echo "extra-experimental-features = fetch-closure" >> /etc/nix/nix.conf 
RUN mkdir /root/sanchonet-demo
WORKDIR /root/sanchonet-demo
RUN mkdir ipc
RUN cat /etc/nix/nix.conf
COPY . .
RUN nix build .#cardano-cli-ng -o cardano-cli-ng-build
RUN nix build .#cardano-node-ng -o cardano-node-ng-build
RUN nix build .#cardano-cli -o cardano-cli-build
ENV PATH="/root/.nix-profile/bin:/nix/var/nix/profiles/default/bin:/nix/var/nix/profiles/default/sbin:/root/sanchonet-demo/cardano-cli-ng-build/bin:/root/sanchonet-demo/cardano-node-ng-build/bin:/root/sanchonet-demo/cardano-cli-build/bin$PATH"
RUN direnv allow
RUN just run-demo
RUN cardano-cli-ng address build --testnet-magic 42 --payment-verification-key-file state-demo/envs/custom/utxo-keys/rich-utxo.vkey
RUN sleep 30
ENTRYPOINT ["nix", "run" ,".#run-cardano-node" ,"&" ,"echo", "$!" ,">" ,"cardano.pid"] 
