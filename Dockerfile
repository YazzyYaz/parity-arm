FROM ubuntu:latest

RUN apt-get update && \
    apt-get install \
    --yes \
    binutils \
    build-essential \
    curl \
    git \
    wget \
    libudev-dev \
    zip

ARG RASPBERRY_PI_TOOLS_COMMIT_ID=5caa7046982f0539cf5380f94da04b31129ed521
ENV CC=arm-linux-gnueabihf-gcc
ENV TARGET=arm-unknown-linux-gnueabihf
ENV CARGO_CFG_TARGET_ARCH=arm
ENV CARGO_CFG_TARGET_ENDIAN=little
ENV CARGO_CFG_TARGET_ENV=gnu
ENV CARGO_CFG_TARGET_FAMILY=unix
ENV CARGO_CFG_TARGET_OS=linux
ENV CARGO_CFG_TARGET_POINTER_WIDTH=32
ENV CARGO_FEATURE_DEFAULT=1
ENV CARGO_FEATURE_DEV_URANDOM_FALLBACK=1
ENV CARGO_FEATURE_RSA_SIGNING=1
ENV CARGO_FEATURE_USE_HEAP=1
ENV LD=/usr/bin/arm-linux-gnueabihf-ld
ENV LD_LIBRARY_PATH=/src/parity/target/release/deps:/root/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/lib:/root/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/lib
ENV QEMU_LD_PREFIX=/usr/arm-linux-gnueabihf/libc
RUN wget https://github.com/raspberrypi/tools/archive/$RASPBERRY_PI_TOOLS_COMMIT_ID.zip -O /root/pi-tools.zip
RUN unzip /root/pi-tools.zip -d /root
RUN mv /root/tools-$RASPBERRY_PI_TOOLS_COMMIT_ID /root/pi-tools
ENV PATH=/root/pi-tools/arm-bcm2708/arm-linux-gnueabihf/bin:$PATH
ENV PATH=/root/pi-tools/arm-bcm2708/arm-linux-gnueabihf/libexec/gcc/arm-linux-gnueabihf/4.8.3:$PATH

# Install Rust.
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --verbose
ENV PATH=/root/.cargo/bin:$PATH

# Install the arm target for Rust.
RUN rustup target add arm-unknown-linux-gnueabihf
# Configure the linker for the arm target.
ENV PKG_CONFIG_ALLOW_CROSS=1 
RUN echo '[target.arm-unknown-linux-gnueabihf]\nlinker = "arm-linux-gnueabihf-gcc"' >> /root/.cargo/config

ENV USER=root
RUN cargo new /src
WORKDIR /src
RUN git clone https://github.com/paritytech/parity && cd parity && \
    /root/.cargo/bin/rustup target add arm-unknown-linux-gnueabihf && \
    /root/.cargo/bin/cargo build --target=arm-unknown-linux-gnueabihf --release --features final

# Verify that the output file is for armv6
RUN readelf --arch-specific ./target/arm-unknown-linux-gnueabihf/debug/src

RUN file /build/parity/target/armv7-unknown-linux-gnueabihf/release/parity

EXPOSE 8080 8545 8180
ENTRYPOINT ["/build/parity/target/armv7-unknown-linux-gnueabihf/release/parity"]
