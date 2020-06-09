FROM ubuntu:latest
LABEL Description="using an external library (fuzzylite) in ns3"
LABEL Author="Jashanjot Singh"
LABEL Email="jshn.singh1@gmail.com"

RUN apt-get update

ARG DEBIAN_FRONTEND=noninteractive

# general dependencies
RUN apt-get install -y \
    wget \
    vim \
    build-essential \
    valgrind \
    gcc \
    g++ \
    mercurial \
    autoconf \
    cvs \
    bzr \
    tcpdump \
    unrar \
    unzip

RUN apt-get install -y \
    python \
    python-dev \
    python-setuptools \
    cmake 


# download ns-3 source
RUN cd /home \
    && wget http://www.nsnam.org/release/ns-allinone-3.30.1.tar.bz2 \
    && tar -xf ns-allinone-3.30.1.tar.bz2 \
    && mv ns-allinone-3.30.1 ns3

# download fuzzylite
RUN cd /home \
    && wget https://s3.amazonaws.com/s3-fuzzylite-public/6.x/fuzzylite-6.0-linux64.zip \
    && unzip fuzzylite-6.0-linux64.zip \
    && mv fuzzylite-6.0 fuzzylite

# cleanup
RUN apt-get clean \
    && rm -rf /var/lib/apt \
    && rm /home/ns-allinone-3.30.1.tar.bz2 \
    && rm /home/fuzzylite-6.0-linux64.zip

# create ns3 module
RUN cd /home/ns3/ns-3.30.1/src \
    && ./create-module.py fuzzylite-demo \
    && ls -a

# update wscript & example code of newly created module
COPY example /home/ns3/ns-3.30.1/src/fuzzylite-demo/examples

# set env variable LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH=/home/fuzzylite/release/bin

# build ns3
RUN cd /home/ns3/ns-3.30.1 \
    && ./waf configure --enable-examples \
    && ./waf --run fuzzylite-demo-example -v

# EOF