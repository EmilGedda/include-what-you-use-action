FROM alpine:3.11

# Install prerequisites
RUN apk update                                                                                                          && \
    apk upgrade                                                                                                         && \
    apk add llvm9-dev llvm9-static clang-dev clang-static g++ git cmake ninja musl-dev python3                          && \
    git clone -b clang_9.0 --single-branch https://github.com/include-what-you-use/include-what-you-use.git             && \
    mkdir iwyu                                                                                                          && \
    cd iwyu                                                                                                             && \
    cmake ../include-what-you-use -DCMAKE_PREFIX_PATH=/usr/lib/llvm9 -DCMAKE_BUILD_TYPE=MinSizeRel -G Ninja -Wno-dev    && \
    ninja install                                                                                                       && \
    mkdir /usr/local/lib/clang                                                                                          && \
    ln -s $(clang -print-resource-dir) $(include-what-you-use -print-resource-dir 2>&-)                                 && \
    apk del llvm9-static clang-static git cmake ninja                                                                   && \
    cd /                                                                                                                && \
    rm -rf /iwyu /include-what-you-use

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
# iwyu_tool.py -o clang -p . | sed "/note: #includes\/fwd-decls are correct/d"
# iwyu_tool.py -p . | sed '/ has correct #includes\/fwd-decl/d;1d' | cat -s
