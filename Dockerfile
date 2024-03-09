FROM --platform=linux/amd64 debian:stable-slim as build
RUN apt-get install just
RUN sh <(curl -L https://nixos.org/nix/install) --daemon
ENV PATH="/root/.cabal/bin:/root/.local/bin:$PATH"
RUN cd sanchonet-demo
RUN just run-demo
