FROM --platform=linux/amd64 debian:stable-slim as build
RUN apt-get update -y \
    && apt-get install -y git jq curl makedeb \
    && apt-get clean
RUN git clone https://mpr.makedeb.org/just
RUN cd just
RUN makedeb -si
RUN which just
RUN sh <(curl -L https://nixos.org/nix/install) --daemon
ENV PATH="/root/.cabal/bin:/root/.local/bin:$PATH"
RUN cd sanchonet-demo
RUN direnv allow
RUN just run-demo
