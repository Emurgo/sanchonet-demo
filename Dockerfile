FROM ubuntu:22.04
RUN apt-get update -y \
    && apt-get install -y git jq curl wget snapd \
    && apt-get clean
RUN echo "[boot] \
systemd=true" > /etc/wsl.conf
RUN ps -p 1 -o comm=
RUN systemctl start snapd.service
RUN snap install just --edge --classic
RUN which just
RUN sh <(curl -L https://nixos.org/nix/install) --daemon
ENV PATH="/root/.cabal/bin:/root/.local/bin:$PATH"
RUN cd sanchonet-demo
RUN direnv allow
RUN just run-demo
