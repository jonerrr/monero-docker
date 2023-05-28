FROM debian:stable-slim as build

RUN apt update \
    && apt install -y --no-install-recommends \
    ca-certificates \
    wget \
    bzip2 \
    && apt clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ARG HASH=186800de18f67cca8475ce392168aabeb5709a8f8058b0f7919d7c693786d56b

RUN cd /tmp \
    && wget https://downloads.getmonero.org/cli/linux64 -O monero.tar.bz2 \
    && echo "${HASH}  monero.tar.bz2" | sha256sum -c - \
    && tar -xvf monero.tar.bz2

FROM debian:stable-slim

COPY --from=build /tmp/monero-x86_64-linux-gnu-v0.18.2.2/monero-wallet-rpc /usr/local/bin

RUN apt update \
    && apt install -y --no-install-recommends \
    ca-certificates \
    && apt clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 28088

CMD ["monero-wallet-rpc", "--rpc-bind-ip", "0.0.0.0", "--rpc-bind-port", "28088", "--trusted-daemon", "--non-interactive", "--daemon-address", "http://monerod:18080", "--wallet-dir", "/data", "--confirm-external-bind"]