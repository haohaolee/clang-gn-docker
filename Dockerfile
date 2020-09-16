FROM ubuntu:18.04

ARG CMAKE_VERSION=3.18.2

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -qq update -y \
    && apt-get -qq install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        python \
        ninja-build \
        ccache \
        xz-utils \
        curl \
        git \
        cppcheck \
        valgrind \
        dialog \
    && apt-get clean -y \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

ENV DEBIAN_FRONTEND=dialog

RUN curl -SL http://releases.llvm.org/9.0.0/clang+llvm-9.0.0-x86_64-linux-gnu-ubuntu-18.04.tar.xz | tar -xJC . \
    && mv clang+llvm-9.0.0-x86_64-linux-gnu-ubuntu-18.04 clang_9.0.0 \
    && find clang_9.0.0 -type f -executable -exec strip '{}' \;

RUN curl -SL https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-Linux-x86_64.sh -o /tmp/curl-install.sh \
    && chmod u+x /tmp/curl-install.sh \
    && mkdir /usr/bin/cmake \
    && /tmp/curl-install.sh --skip-license --prefix=/usr/bin/cmake \
    && rm /tmp/curl-install.sh

ENV PATH="/clang_9.0.0/bin:/usr/bin/cmake/bin:${PATH}"
ENV LD_LIBRARY_PATH="/clang_9.0.0/lib:${LD_LIBRARY_PATH}"
ENV CC="/clang_9.0.0/bin/clang"
ENV CXX="/clang_9.0.0/bin/clang++"

RUN git clone https://gn.googlesource.com/gn    \
    && cd gn    \
    && python build/gen.py \
    && ninja -C out

ENV PATH=/gn/out:${PATH}

