FROM quay.io/vektorcloud/base:3.9 as base

ENV GOLANG_VERSION 1.13.4
ENV GOLANG_SRC_URL https://golang.org/dl/go${GOLANG_VERSION}.src.tar.gz
ENV GOLANG_SRC_SHA256 95dbeab442ee2746b9acf0934c8e2fc26414a0565c008631b04addb8c02e7624

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
