FROM quay.io/vektorcloud/base:3.6

RUN apk add --no-cache curl git mercurial bzr make gcc

ENV GOLANG_VERSION 1.9
ENV GOLANG_SRC_URL https://golang.org/dl/go${GOLANG_VERSION}.src.tar.gz
ENV GOLANG_SRC_SHA256 a4ab229028ed167ba1986825751463605264e44868362ca8e7accc8be057e993

ENV GOPATH /go

# Certain Go packages such as go-sqlite3 depend
# on libc headers, thus we include musl-dev.
RUN set -ex && \
    apk add --no-cache --virtual .build-deps \
                                 bash \
                                 gcc \
                                 musl-dev \
                                 openssl \
                                 go && \
    export GOROOT_BOOTSTRAP="$(go env GOROOT)" && \
    cd /tmp && wget -q "$GOLANG_SRC_URL" -O golang.tar.gz && \
    echo "$GOLANG_SRC_SHA256  golang.tar.gz" | sha256sum -c - && \
    tar xzf golang.tar.gz -C /usr/local && \
    cd /usr/local/go/src && ./make.bash && \
    rm -rf /go/src/github.com/ && \
    rm -rf /tmp/* && \
    apk del .build-deps  && \
    apk add --no-cache musl-dev

ENV DEP_BRANCH v0.3.0

RUN mkdir -p /go/src/github.com/golang \
  && cd /go/src/github.com/golang \
  && git clone --branch $DEP_BRANCH --depth 1 https://github.com/golang/dep.git \
  && cd dep/cmd/dep \
  && go install
