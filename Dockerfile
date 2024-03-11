FROM ubuntu:latest


RUN apt-get update -y \
    && apt-get install -y git jq curl wget gpg lsb-release xz-utils automake build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++ tmux git jq wget libncursesw5 libtool autoconf libsqlite3-dev m4 ca-certificates gcc libc6-dev curl python3 htop nload pkg-config liblmdb-dev && mkdir -p /usr/local/lib/pkgconfig/ \
    && apt-get clean
RUN curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | BOOTSTRAP_HASKELL_NONINTERACTIVE=1 BOOTSTRAP_HASKELL_GHC_VERSION=8.10.7 BOOTSTRAP_HASKELL_CABAL_VERSION=3.8.1.0 BOOTSTRAP_HASKELL_INSTALL_STACK=1 BOOTSTRAP_HASKELL_INSTALL_HLS=1 BOOTSTRAP_HASKELL_ADJUST_BASHRC=P sh
ENV PATH="/root/.cabal/bin:/root/.ghcup/bin:/root/.local/bin:/root/.nix-profile/bin:$PATH"
RUN git clone https://github.com/supranational/blst && cd blst && git checkout v0.3.10 && ./build.sh && echo cHJlZml4PS91c3IKZXhlY19wcmVmaXg9JHtwcmVmaXh9CmxpYmRpcj0ke2V4ZWNfcHJlZml4fS9saWIKaW5jbHVkZWRpcj0ke3ByZWZpeH0vaW5jbHVkZQoKTmFtZTogbGliYmxzdApEZXNjcmlwdGlvbjogTXVsdGlsaW5ndWFsIEJMUzEyLTM4MSBzaWduYXR1cmUgbGlicmFyeQpVUkw6IGh0dHBzOi8vZ2l0aHViLmNvbS9zdXByYW5hdGlvbmFsL2Jsc3QKVmVyc2lvbjogMC4zLjEwCkNmbGFnczogLUkke2luY2x1ZGVkaXJ9CkxpYnM6IC1MJHtsaWJkaXJ9IC1sYmxzdA== | base64 --decode >> libblst.pc && cp libblst.pc /usr/lib/pkgconfig/ && cp bindings/blst_aux.h bindings/blst.h bindings/blst.hpp  /usr/include/ && cp libblst.a /usr/lib && chmod u=rw,go=r /usr/lib/libblst.a && chmod u=rw,go=r /usr/lib/pkgconfig/libblst.pc && chmod u=rw,go=r /usr/include/blst.h && chmod u=rw,go=r /usr/include/blst.hpp && chmod u=rw,go=r /usr/include/blst_aux.h
RUN mkdir secp256k1-sources && cd secp256k1-sources && git clone https://github.com/bitcoin-core/secp256k1.git && cd secp256k1 && git reset --hard ac83be33d0956faf6b7f61a60ab524ef7d6a473a && ./autogen.sh && ./configure --prefix=/usr --enable-module-schnorrsig --enable-experimental && make && make check && make install
RUN git clone https://github.com/input-output-hk/libsodium && cd libsodium && git checkout $(curl -L https://github.com/input-output-hk/iohk-nix/releases/latest/download/INFO | awk '$1 == "debian.libsodium-vrf.deb" { rev = gensub(/.*-(.*)\.deb/, "\\1", "g", $2); print rev }') && ./autogen.sh && ./configure && make && make check && make install
RUN ghcup install ghc 8.10.7
RUN ghcup set ghc 8.10.7
RUN ghcup install cabal 3.8.1.0
RUN ghcup set cabal 3.8.1.0
ENV LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH" \
    PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH"
RUN echo "Building tags/$VERSION..." 
RUN git clone https://github.com/input-output-hk/cardano-node.git \
    && cd cardano-node \
    && git checkout $(curl -s https://api.github.com/repos/IntersectMBO/cardano-node/releases/latest | jq -r .tag_name) \
    && touch cabal.project.local \
    && cabal update \
    && cabal configure --with-compiler=ghc-8.10.7 \
    && echo "package cardano-crypto-praos" >>  cabal.project.local \
    && echo "  flags: -external-libsodium-vrf" >>  cabal.project.local \
    && cabal build all \
    && mkdir -p /root/.local/bin/ \
    && ls -ltr /cardano-node/dist-newstyle/build/x86_64-linux/ghc-8.10.7/cardano-node-*/x \
    && find /cardano-node/dist-newstyle -name cardano-cli
    && cp -p /cardano-node/dist-newstyle/build/x86_64-linux/ghc-8.10.7/cardano-node-*/x/cardano-node/build/cardano-node/cardano-node /root/.local/bin/ \
RUN ln -s /root/.local/bin/cardano-cli /root/.local/bin/cardano-cli-ng
RUN ln -s /root/.local/bin/cardano-node /root/.local/bin/cardano-node-ng
RUN wget -qO - 'https://proget.makedeb.org/debian-feeds/prebuilt-mpr.pub' | gpg --dearmor | tee /usr/share/keyrings/prebuilt-mpr-archive-keyring.gpg 1> /dev/null
RUN echo "deb [arch=all,$(dpkg --print-architecture) signed-by=/usr/share/keyrings/prebuilt-mpr-archive-keyring.gpg] https://proget.makedeb.org prebuilt-mpr $(lsb_release -cs)" | tee /etc/apt/sources.list.d/prebuilt-mpr.list
RUN apt-get update -y \
    && apt-get install -y just \
    && apt-get clean
RUN curl -L https://nixos.org/nix/install | sh -s -- --daemon
RUN curl -sfL https://direnv.net/install.sh | bash
RUN mkdir sanchonet-demo && cd sanchonet-demo
COPY . .
RUN direnv allow
RUN which nix cardano-cli
RUN just run-demo
