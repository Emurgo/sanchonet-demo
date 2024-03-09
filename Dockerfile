FROM ubuntu:22.04
RUN apt-get update -y \
    && apt-get install -y git jq curl wget gpg lsb-release xz-utils \
    && apt-get clean
RUN wget -qO - 'https://proget.makedeb.org/debian-feeds/prebuilt-mpr.pub' | gpg --dearmor | tee /usr/share/keyrings/prebuilt-mpr-archive-keyring.gpg 1> /dev/null
RUN echo "deb [arch=all,$(dpkg --print-architecture) signed-by=/usr/share/keyrings/prebuilt-mpr-archive-keyring.gpg] https://proget.makedeb.org prebuilt-mpr $(lsb_release -cs)" | tee /etc/apt/sources.list.d/prebuilt-mpr.list
RUN apt-get update -y \
    && apt-get install -y just \
    && apt-get clean
RUN curl -L https://nixos.org/nix/install | sh -s -- --daemon
RUN curl -sfL https://direnv.net/install.sh | bash
ENV PATH="/root/.cabal/bin:/root/.local/bin:/usr/local/sbin:$PATH"
COPY . .
RUN direnv allow
RUN just run-demo
