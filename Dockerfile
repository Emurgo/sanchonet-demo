FROM --platform=linux/amd64 debian:stable-slim as build
RUN apt-get update -y \
    && apt-get install -y git jq curl wget snapd core \
    && apt-get clean
RUN snap install just --edge --classic
RUN which just
RUN sh <(curl -L https://nixos.org/nix/install) --daemon
ENV PATH="/root/.cabal/bin:/root/.local/bin:$PATH"
RUN cd sanchonet-demo
RUN direnv allow
RUN just run-demo
