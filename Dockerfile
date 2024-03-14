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
RUN PATH=$PATH:/root/cardano-cli-ng-build/bin:/root/cardano-node-ng-build/bin
RUN direnv allow
ENTRYPOINT just run-demo
