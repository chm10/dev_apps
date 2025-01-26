FROM python:3.11-slim

RUN apt-get update && \
    apt-get install -y vim curl git  && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -m developer && \
    mkdir /app && \
    chown developer:developer /app

USER developer
WORKDIR /app

RUN python -m pip install --upgrade pip && \
    python -m pip install virtualenv

CMD ["/bin/bash"]
