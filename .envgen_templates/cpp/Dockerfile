FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y build-essential gdb cmake vim curl git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -m developer && \
    mkdir /app && \
    chown developer:developer /app

USER developer
WORKDIR /app

CMD ["/bin/bash"]
