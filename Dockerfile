FROM nvidia/cuda:11.8.0-base-ubuntu22.04

RUN apt update

# build Python 3.10.6
RUN apt install -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget libbz2-dev
WORKDIR /tmp
RUN wget https://www.python.org/ftp/python/3.10.6/Python-3.10.6.tgz
RUN tar -xf Python-3.10.6.tgz
WORKDIR /tmp/Python-3.10.6
RUN ./configure --enable-optimizations
RUN make -j $(nproc)
RUN make install
WORKDIR /
