FROM quay.io/vektorcloud/base:3.11 as base

ENV GOLANG_VERSION 1.14.3
ENV GOLANG_SRC_URL https://golang.org/dl/go${GOLANG_VERSION}.src.tar.gz
ENV GOLANG_SRC_SHA256 93023778d4d1797b7bc6a53e86c3a9b150c923953225f8a48a2d5fabc971af56

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
