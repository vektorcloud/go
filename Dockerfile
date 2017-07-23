FROM quay.io/vektorcloud/base:3.6

# Certain Go packages such as go-sqlite3 depend
# on libc headers, thus we include musl-dev.
RUN apk add --no-cache curl git mercurial bzr bash make musl-dev

ENV GOPATH /go
ENV PATH $PATH:/usr/local/go/bin:$GOPATH/bin

# install go from src
ENV GOLANG_VERSION 1.8.3
ENV GOLANG_SRC_URL https://golang.org/dl/go${GOLANG_VERSION}.src.tar.gz
ENV GOLANG_SRC_SHA256 5f5dea2447e7dcfdc50fa6b94c512e58bfba5673c039259fd843f68829d99fa6

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

# include glide until new dep ensure spec is merged
# https://github.com/golang/dep/pull/489
ENV GLIDE_VERSION "v0.12.3"
ENV GLIDE_SRC_URL "https://github.com/Masterminds/glide/releases/download/${GLIDE_VERSION}/glide-${GLIDE_VERSION}-linux-amd64.tar.gz"

RUN cd /tmp && wget -q $GLIDE_SRC_URL -O glide.tar.gz && \
  tar xvf glide.tar.gz && \
  mv linux-amd64/glide /usr/bin/ && \
  rm -rf /tmp/*

WORKDIR /go
