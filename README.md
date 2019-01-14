# Parity Docker Cross-Compilation to ARMV7

Check out the [guide on Medium](https://medium.com/ethereum-classic/ethereum-classic-on-raspberry-pi-a3be200cdca0)

## Compilation Instructions
1. Install [Docker](https://docs.docker.com/install/)
2. `git clone https://github.com/YazzyYaz/parity-arm.git && cd parity-arm`
3. `docker build -t yazanator90:parity-arm .`
4. `docker run -d --name parity-arm yazanator90:parity-arm`
5. `docker start parity-arm`
6. `docker ps`
7. `docker cp parity-arm:/parity-ethereum/target/armv7-unknown-linux-gnueabihf/release/parity parity-arm`
8. `docker stop parity-arm`
9. `docker rm parity-arm`
10. Copy parity-arm into the Raspberry Pi with scp.
