FROM quay.io/vektorcloud/base:3.4

RUN apk add --no-cache curl git mercurial bzr go

ENV GLIDE_VERSION "v0.12.3"

RUN curl -L "https://github.com/Masterminds/glide/releases/download/$GLIDE_VERSION/glide-$GLIDE_VERSION-linux-amd64.tar.gz" -o /tmp/glide.tar.gz && \
  cd /tmp && \
  tar xvf glide.tar.gz && \
  mv linux-amd64/glide /usr/bin/ && \
  rm -v /tmp/glide.tar.gz && \
  rm -Rv /tmp/linux-amd64

ENV GOPATH /go
ENV PATH $PATH:$GOPATH/bin
WORKDIR /go
