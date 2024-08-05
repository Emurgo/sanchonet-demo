FROM nixos/nix:latest AS builder
RUN nix-env -iA nixpkgs.direnv
RUN nix-env -iA nixpkgs.just
RUN nix-env -iA nixpkgs.jq
RUN nix-env -iA nixpkgs.ps
RUN mkdir -p /etc/nix
RUN touch /etc/nix/nix.conf
RUN echo "donotUnpack = true" > /etc/nix/nix.conf && echo "experimental-features = nix-command flakes" > /etc/nix/nix.conf && echo "allow-import-from-derivation = true" >> /etc/nix/nix.conf && echo "extra-experimental-features = fetch-closure" >> /etc/nix/nix.conf 
RUN mkdir /root/test-node
RUN mkdir /root/ipc
RUN export TMPDIR="/tmp"
WORKDIR /root/test-node
RUN cat /etc/nix/nix.conf
COPY . .
RUN nix build .#cardano-cli-ng -o cardano-cli-ng-build
RUN nix build .#cardano-node-ng -o cardano-node-ng-build
RUN nix build .#cardano-cli -o cardano-cli-build
ENV PATH="/root/.nix-profile/bin:/nix/var/nix/profiles/default/bin:/nix/var/nix/profiles/default/sbin:/root/test-node/cardano-cli-ng-build/bin:/root/test-node/cardano-node-ng-build/bin:/root/test-node/cardano-cli-build/bin:$PATH"
RUN direnv allow
CMD nix develop .# --command just run-demo && nix run .#run-cardano-node
