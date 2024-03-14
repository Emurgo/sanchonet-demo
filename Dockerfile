FROM nixos/nix
ENV PATH="/root/.cabal/bin:/root/.ghcup/bin:/root/.local/bin:/root/.nix-profile/bin/direnv:/root/.nix-profile/bin:$PATH"
RUN nix-env -iA nixpkgs.direnv
RUN nix-env -iA nixpkgs.just
RUN nix-env -iA nixpkgs.jq
RUN touch /etc/nix/nix.conf
RUN mkdir -p /etc/nix
RUN echo "experimental-features = nix-command flakes" > /etc/nix/nix.conf && echo "allow-import-from-derivation = true" >> /etc/nix/nix.conf && echo "extra-experimental-features = fetch-closure" >> /etc/nix/nix.conf 
RUN mkdir /root/sanchonet-demo
WORKDIR /root/sanchonet-demo
RUN cat /etc/nix/nix.conf
COPY . .
RUN nix build 
RUN direnv allow
CMD just run-demo
