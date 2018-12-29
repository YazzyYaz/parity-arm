FROM ubuntu:16.04
WORKDIR /build
# install tools and dependencies
RUN apt-get -y update && \
apt-get install -y \
curl udev git make g++-4.8-multilib-arm-linux-gnueabihf g++ gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf \
libc6-dev-armhf-cross wget file ca-certificates libudev-dev cmake build-essential \
binutils-arm-linux-gnueabihf lib32z1-dev gcc-arm* && apt-get clean
#RUN ls /usr/lib/gcc-cross/arm-linux-gnueabihf/7
#RUN ls /usr/arm-linux-gnueabihf/bin
#RUN ls /lib/udev
#RUN ln -s /lib/x86_64-linux-gnu/libudev.so /usr/arm-linux-gnueabihf/bin/

# install rustup
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

# rustup directory
ENV PATH /root/.cargo/bin:$PATH

ENV RUST_TARGETS="arm-unknown-linux-gnueabihf"

# multirust add arm--linux-gnuabhf toolchain
RUN rustup target add armv7-unknown-linux-gnueabihf

# show backtraces
ENV RUST_BACKTRACE 1

# show tools
RUN rustc -vV && \
cargo -V 

#RUN g++ -L/lib/x86_64-linux-gnu/libudev.so -ludev /root/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/lib/rustlib/armv7-unknown-linux-gnueabihf/lib/

# build parity
RUN git clone https://github.com/paritytech/parity && \
    cd parity && git pull && \
    mkdir -p .cargo && \
    echo '[target.armv7-unknown-linux-gnueabihf]\n linker = "arm-linux-gnueabihf-gcc"' >>.cargo/config && \
    cat .cargo/config && \
    cargo build --target armv7-unknown-linux-gnueabihf --release --verbose && \
    ls /build/parity/target/armv7-unknown-linux-gnueabihf/release/parity && \
    /usr/bin/arm-linux-gnueabihf-strip /build/parity/target/armv7-unknown-linux-gnueabihf/release/parity

RUN file /build/parity/target/armv7-unknown-linux-gnueabihf/release/parity

EXPOSE 8080 8545 8180
ENTRYPOINT ["/build/parity/target/armv7-unknown-linux-gnueabihf/release/parity"]
