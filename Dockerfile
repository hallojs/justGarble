FROM ubuntu:12.04

WORKDIR /home
RUN apt-get update
RUN apt-get install -y  git unzip nano build-essential wget libgnutls28-dev libssl-dev doxygen zlib1g zlib1g-dev

#RUN apt-get install -y autotools-dev autoconf libtool

RUN wget https://github.com/Kitware/CMake/archive/refs/tags/v2.8.12.zip
RUN unzip v2.8.12.zip
WORKDIR /home/CMake-2.8.12
RUN ./bootstrap
RUN make
RUN make install

#RUN git clone https://github.com/msgpack/msgpack-c.git
#WORKDIR /home/msgpack-c
#RUN git checkout tags/cpp-0.5.9
#RUN ./bootstrap
#RUN ./configure
#RUN make
#RUN make install

WORKDIR /home
RUN git clone https://github.com/msgpack/msgpack-c.git
WORKDIR msgpack-c
RUN git checkout tags/cpp-0.5.9
WORKDIR /home/msgpack-c
RUN cmake .
RUN make

WORKDIR /home
RUN wget https://github.com/msgpack/msgpack-c/releases/download/cpp-0.5.9/msgpack-0.5.9.tar.gz
RUN tar zxvf msgpack-0.5.9.tar.gz
WORKDIR /home/msgpack-0.5.9
RUN ./configure
RUN make
RUN make install

WORKDIR /home
RUN git clone https://github.com/hallojs/justGarble.git
WORKDIR /home/justGarble
RUN make
