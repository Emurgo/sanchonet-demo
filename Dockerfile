FROM nixos/nix
ENV PATH="/root/.cabal/bin:/root/.ghcup/bin:/root/.local/bin:/root/.nix-profile/bin/direnv:/root/.nix-profile/bin:$PATH"
RUN nix-env -iA nixpkgs.direnv
RUN nix-env -iA nixpkgs.just
RUN nix-env -iA nixpkgs.jq
RUN touch /etc/nix/nix.conf
RUN echo  'build-users-group = nixbld \n \
 experimental-features = nix-command \n \
 extra-experimental-features = flakes \n \
 extra-experimental-features = fetch-closure'  >> /etc/nix/nix.conf
RUN mkdir /root/sanchonet-demo
WORKDIR /root/sanchonet-demo
RUN mkdir ipc
COPY . .
RUN direnv allow
CMD  just run-demo
