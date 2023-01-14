FROM emscripten/emsdk:latest AS builder

LABEL maintainer="drescher.wolfgang@gmail.com"

RUN apt-get update \
    && apt-get install -y \
        software-properties-common \
    && apt-get install -y \
        apt-utils \
        git \
        make \
        cmake \
        gcc \
        g++ \
        automake \
        libtool \
        curl \
        unzip \
        sudo \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local

# humdrum-tools/humdrum-tools
RUN git clone https://github.com/humdrum-tools/humdrum-tools.git
RUN sed -i -e 's/git@github\.com:/https:\/\/github\.com\//g' humdrum-tools/.gitmodules
RUN (cd humdrum-tools && make update)
RUN (cd humdrum-tools && make)

# WolfgangDrescher/humlib
RUN git clone -b verovio-humlib-docker-image https://github.com/WolfgangDrescher/humlib.git
RUN (cd humlib && make)

# WolfgangDrescher/verovio
RUN git clone -b verovio-humlib-docker-image https://github.com/WolfgangDrescher/verovio.git
RUN cp /usr/local/humlib/include/humlib.h /usr/local/verovio/include/hum/humlib.h && \
    cp /usr/local/humlib/src/humlib.cpp /usr/local/verovio/src/hum/humlib.cpp
# RUN (cd verovio/tools && cmake ../cmake && make -j 8 && sudo make install)
RUN (cd verovio/emscripten && ./buildNpmPackage)



FROM ubuntu:jammy

LABEL maintainer="drescher.wolfgang@gmail.com"

RUN apt-get update \
    && apt-get install -y \
        git \
        ssh \
        rsync

COPY --from=builder /usr/local/humdrum-tools/humdrum/bin /usr/local/humdrum-tools/humdrum/bin
COPY --from=builder /usr/local/humdrum-tools/humextra/bin /usr/local/humdrum-tools/humextra/bin
ENV PATH="/usr/local/humdrum-tools/humdrum/bin:/usr/local/humdrum-tools/humextra/bin:${PATH}"

COPY --from=builder /usr/local/humlib/bin /usr/local/humlib/bin
ENV PATH="/usr/local/humlib/bin:${PATH}"

COPY --from=builder /usr/local/verovio/emscripten/npm/dist /usr/local/verovio/dist
COPY --from=builder /usr/local/verovio/emscripten/npm/package.json /usr/local/verovio/package.json

WORKDIR /app
