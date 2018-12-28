FROM ubuntu:18.04
WORKDIR /build
# install tools and dependencies
RUN apt-get -y update && \
apt-get install -y --no-install-recommends \
curl git make g++ gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf \
libc6-dev-armhf-cross wget file ca-certificates libudev-dev cmake build-essential \
binutils-arm-linux-gnueabihf && apt-get clean

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

# build parity
RUN git clone https://github.com/paritytech/parity && \
cd parity && git checkout beta && git pull


RUN mkdir -p .cargo && \
echo '[target.armv7-unknown-linux-gnueabihf]\n linker = "arm-linux-gnueabihf-gcc"' >>.cargo/config && \
cat .cargo/config


RUN cd parity && cargo build --target armv7-unknown-linux-gnueabihf --release --verbose && \
ls /build/parity/target/armv7-unknown-linux-gnueabihf/release/parity && \
/usr/bin/arm-linux-gnueabihf-strip /build/parity/target/armv7-unknown-linux-gnueabihf/release/parity

RUN file /build/parity/target/armv7-unknown-linux-gnueabihf/release/parity

EXPOSE 8080 8545 8180
ENTRYPOINT ["/build/parity/target/armv7-unknown-linux-gnueabihf/release/parity"]
