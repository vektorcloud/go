FROM quay.io/vektorcloud/base:3.15 as base

ENV GOLANG_VERSION 1.18
ENV GOLANG_SRC_SHA256 38f423db4cc834883f2b52344282fa7a39fbb93650dc62a11fdf0be6409bdad6

ENV GOLANG_SRC_URL https://golang.org/dl/go${GOLANG_VERSION}.src.tar.gz

ENV GOPATH /go
ENV PATH $PATH:/usr/local/go/bin:$GOPATH/bin

# Include common CVS and go package deps
RUN apk add --no-cache curl git mercurial make gcc musl-dev

RUN set -ex && \
    apk add --no-cache --virtual .build-deps \
                                 bash \
                                 gnupg \
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
