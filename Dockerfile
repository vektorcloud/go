FROM quay.io/vektorcloud/base:3.6

# Certain Go packages such as go-sqlite3 depend
# on libc headers, thus we include musl-dev.
RUN apk add --no-cache curl git mercurial bzr bash make musl-dev

ENV GOLANG_VERSION 1.8.3
ENV GOLANG_SRC_URL https://golang.org/dl/go${GOLANG_VERSION}.src.tar.gz
ENV GOLANG_SRC_SHA256 5f5dea2447e7dcfdc50fa6b94c512e58bfba5673c039259fd843f68829d99fa6

ENV GOPATH /go
ENV PATH $PATH:/usr/local/go/bin:$GOPATH/bin

RUN set -ex && \
    apk add --no-cache --virtual .build-deps gcc openssl go && \
    export GOROOT_BOOTSTRAP="$(go env GOROOT)" && \
    cd /tmp && wget -q "$GOLANG_SRC_URL" -O golang.tar.gz && \
    echo "$GOLANG_SRC_SHA256  golang.tar.gz" | sha256sum -c - && \
    tar xzf golang.tar.gz -C /usr/local && \
    cd /usr/local/go/src && ./make.bash && \
    go get github.com/golang/dep/cmd/dep && \
    go get github.com/jteeuwen/go-bindata/... && \
    rm -rf /go/src/github.com/ /tmp/* && \
    apk del .build-deps

WORKDIR /go
