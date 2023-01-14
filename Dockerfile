FROM emscripten/emsdk:latest

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
        ssh \
        rsync \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local

# humdrum-tools/humdrum-tools
RUN git clone https://github.com/humdrum-tools/humdrum-tools.git
RUN sed -i -e 's/git@github\.com:/https:\/\/github\.com\//g' humdrum-tools/.gitmodules
RUN (cd humdrum-tools && make update)
RUN (cd humdrum-tools && make)
RUN (cd humdrum-tools && make install)
ENV PATH="/usr/local/humdrum-tools/humdrum/bin:/usr/local/humdrum-tools/humextra/bin:${PATH}"

# WolfgangDrescher/humlib
RUN git clone -b verovio-humlib-docker-image https://github.com/WolfgangDrescher/humlib.git
RUN (cd humlib && make)
ENV PATH="/usr/local/humlib/bin:${PATH}"

# WolfgangDrescher/verovio
RUN git clone -b verovio-humlib-docker-image https://github.com/WolfgangDrescher/verovio.git
RUN cp /usr/local/humlib/include/humlib.h /usr/local/verovio/include/hum/humlib.h && \
    cp /usr/local/humlib/src/humlib.cpp /usr/local/verovio/src/hum/humlib.cpp
RUN (cd verovio/tools && cmake ../cmake && make -j 8 && sudo make install)
RUN (cd verovio/emscripten && ./buildNpmPackage)

WORKDIR /app
