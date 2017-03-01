FROM quay.io/vektorcloud/base:3.5

RUN apk add --no-cache curl git mercurial bzr make

ENV GLIDE_VERSION v0.12.3
ENV GLIDE_SRC_URL https://github.com/Masterminds/glide/releases/download/${GLIDE_VERSION}/glide-${GLIDE_VERSION}-linux-amd64.tar.gz
ENV GLIDE_SRC_SHA256 0e2be5e863464610ebc420443ccfab15cdfdf1c4ab63b5eb25d1216900a75109

ENV GOLANG_VERSION 1.8
ENV GOLANG_SRC_URL https://golang.org/dl/go${GOLANG_VERSION}.src.tar.gz
ENV GOLANG_SRC_SHA256 406865f587b44be7092f206d73fc1de252600b79b3cacc587b74b5ef5c623596

RUN set -ex && \
    apk add --no-cache --virtual .build-deps \
                                 bash \
                                 gcc \
                                 musl-dev \
                                 openssl \
                                 go && \
    export GOROOT_BOOTSTRAP="$(go env GOROOT)" && \
    wget -q "$GOLANG_SRC_URL" -O golang.tar.gz && \
    echo "$GOLANG_SRC_SHA256  golang.tar.gz" | sha256sum -c - && \
    tar -C /usr/local -xzf golang.tar.gz && \
    rm golang.tar.gz && \
    cd /usr/local/go/src && \
    ./make.bash && \
    wget -q "$GLIDE_SRC_URL" -O glide.tar.gz && \
    echo "$GLIDE_SRC_SHA256  glide.tar.gz" | sha256sum -c - && \
    tar -C /tmp -xzf glide.tar.gz && \
    rm glide.tar.gz && \
    mv /tmp/linux-amd64/glide /usr/bin/ && \
    rm -rf /tmp/linux-amd64 && \
    apk del .build-deps

ENV GOPATH /go
ENV PATH $PATH:/usr/local/go/bin:$GOPATH/bin
WORKDIR /go
