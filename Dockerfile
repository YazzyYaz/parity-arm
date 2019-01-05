FROM debian:latest

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    cmake \
    curl \
    git \
    pkg-config \
    gcc-arm-linux-gnueabihf \
    g++-arm-linux-gnueabihf \
    libc6-dev-armhf-cross \
    && rm -rf \
    /var/lib/apt/lists/*

RUN sed 's/^deb/deb-src/' /etc/apt/sources.list > \
        /etc/apt/sources.list.d/deb-src.list \
    && dpkg --add-architecture armhf \
    && apt-get update \
    && apt-get install -y \
        libssl-dev:armhf \
        libc6-dev:armhf \
    && rm -rf \
      /var/lib/apt/lists/*

ENV USER=root
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --verbose
ENV PATH=/root/.cargo/bin:$PATH

ENV CARGO_TARGET_ARMV7_UNKNOWN_LINUX_GNUEABIHF_LINKER=arm-linux-gnueabihf-gcc \
    CC_armv7_unknown_linux_gnueabihf="/usr/bin/arm-linux-gnueabihf-gcc" \
    CXX_armv7_unknown_linux_gnueabihf="/usr/bin/arm-linux-gnueabihf-g++" \
    CROSS_COMPILE="1" \
    OPENSSL_INCLUDE_DIR="/usr/include/arm-linux-gnueabihf" \
    OPENSSL_LIB_DIR="/usr/lib/arm-linux-gnueabihf"

RUN /root/.cargo/bin/rustup target add armv7-unknown-linux-gnueabihf
    
RUN dpkg --add-architecture armhf && \
    apt-get update && \
    apt-get install -y libudev-dev:armhf

RUN git clone https://github.com/paritytech/parity-ethereum.git && cd parity-ethereum && \
    cargo build --target=armv7-unknown-linux-gnueabihf --release


CMD ./parity-ethereum/target/armv7-unknown-linux-gnueabihf/release/parity

EXPOSE 8080 8545 8180
ENTRYPOINT ["/parity-ethereum/target/armv7-unknown-linux-gnueabihf/release/parity"]
