FROM nixos/nix
ENV PATH="/root/.cabal/bin:/root/.ghcup/bin:/root/.local/bin:/root/.nix-profile/bin/direnv:/root/.nix-profile/bin:$PATH"
RUN nix-env -iA nixpkgs.direnv
RUN nix-env -iA nixpkgs.just
RUN nix-env -iA nixpkgs.jq
RUN touch /etc/nix/nix.conf
RUN mkdir -p /etc/nix
RUN echo "experimental-features = nix-command flakes" > /etc/nix/nix.conf && echo "allow-import-from-derivation = true" >> /etc/nix/nix.conf
RUN git clone https://github.com/intersectmbo/cardano-node && cd cardano-node && nix build .#cardano-node -o cardano-node-build && nix run .#cardano-cli -- version
RUN mkdir /root/sanchonet-demo
RUN which cardanoc-cli && which cardano-node
WORKDIR /root/sanchonet-demo
RUN cat /etc/nix/nix.conf
COPY . .
RUN nix flake update --extra-experimental-features nix-command --extra-experimental-features = flakes
RUN direnv allow
CMD  just run-demo
