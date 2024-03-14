FROM nixos/nix:latest AS builder
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
RUN direnv allow
CMD just run-demo
