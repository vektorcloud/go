FROM quay.io/vektorcloud/base:3.9 as base

ENV GOLANG_VERSION 1.13.3
ENV GOLANG_SRC_URL https://golang.org/dl/go${GOLANG_VERSION}.src.tar.gz
ENV GOLANG_SRC_SHA256 0be127684df4b842a64e58093154f9d15422f1405f1fcff4b2c36ffc6a15818a

ENV GOPATH /go
ENV PATH $PATH:/usr/local/go/bin:$GOPATH/bin

# Include common CVS and Go package deps, including libc headers
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

FROM base as onbuild

WORKDIR /app
ARG CGO_ENABLED=0
ARG LDFLAGS="-w -s"

ONBUILD COPY go.mod .
ONBUILD RUN go mod download
ONBUILD COPY . .
ONBUILD RUN go build -ldflags "$LDFLAGS"
ONBUILD RUN CGO_ENABLED=$CGO_ENABLED go build -ldflags "$LDFLAGS"
