FROM nixos/nix
ENV PATH="/root/.cabal/bin:/root/.ghcup/bin:/root/.local/bin:/root/.nix-profile/bin/direnv:/root/.nix-profile/bin:$PATH"
RUN nix-env -iA nixpkgs.direnv
RUN nix-env -iA nixpkgs.just
RUN nix-env -iA nixpkgs.jq
RUN touch /etc/nix/nix.conf
RUN mkdir -p /etc/nix
RUN cat << EOF | tee /etc/nix/nix.conf 
    experimental-features = nix-command flakes
    allow-import-from-derivation = true
    EOF
RUN git clone https://github.com/intersectmbo/cardano-node && cd cardano-node && nix build .#cardano-node -o cardano-node-build && nix run .#cardano-cli -- version
RUN mkdir /root/sanchonet-demo
WORKDIR /root/sanchonet-demo
RUN cat /etc/nix/nix.conf
COPY . .
RUN nix flake update --extra-experimental-features nix-command --extra-experimental-features = flakes
RUN direnv allow
CMD  just run-demo
