FROM alpine:3.11

RUN apk update                                                                                          && \
    apk upgrade                                                                                         && \
    apk add llvm9-dev llvm9-static clang-dev clang-static g++ git cmake ninja musl-dev python coreutils && \
    git clone -b clang_9.0 --single-branch https://github.com/EmilGedda/include-what-you-use.git        && \
    mkdir iwyu                                                                                          && \
    cd iwyu                                                                                             && \
    cmake ../include-what-you-use -DCMAKE_PREFIX_PATH=/usr/lib/cmake/llvm9 -G Ninja -Wno-dev            && \
    ninja install                                                                                       && \
    mkdir -p /usr/local/lib/clang                                                                       && \
    ln -s $(clang -print-resource-dir) $(include-what-you-use -print-resource-dir 2>&-)                 && \
    apk del llvm9-static clang-static git cmake ninja                                                   && \
    rm -rf /iwyu /include-what-you-use

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
