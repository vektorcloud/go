FROM quay.io/vektorcloud/base:3.7

ENV GOLANG_VERSION 1.10
ENV GOLANG_SRC_URL https://golang.org/dl/go${GOLANG_VERSION}.src.tar.gz
ENV GOLANG_SRC_SHA256 f3de49289405fda5fd1483a8fe6bd2fa5469e005fd567df64485c4fa000c7f24

ENV GOPATH /go
ENV PATH $PATH:/usr/local/go/bin:$GOPATH/bin

# Certain Go packages such as go-sqlite3 depend
# on libc headers, thus we include musl-dev.
RUN apk add --no-cache curl git mercurial bzr make gcc musl-dev

RUN set -ex && \
    apk add --no-cache --virtual .build-deps \
                                 bash \
                                 gcc \
                                 openssl \
                                 go && \
    export GOROOT_BOOTSTRAP="$(go env GOROOT)" && \
    cd /tmp && wget -q "$GOLANG_SRC_URL" -O golang.tar.gz && \
    echo "$GOLANG_SRC_SHA256  golang.tar.gz" | sha256sum -c - && \
    tar xzf golang.tar.gz -C /usr/local && \
    cd /usr/local/go/src && ./make.bash && \
    rm -rf /go/src/github.com/ && \
    rm -rf /tmp/* && \
    apk del .build-deps

RUN go get -u github.com/golang/dep/cmd/dep
