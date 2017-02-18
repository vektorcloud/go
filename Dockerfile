FROM quay.io/vektorcloud/base:3.4

RUN apk add --no-cache curl git mercurial bzr go

ENV GOPATH /go
ENV PATH $PATH:$GOPATH/bin
WORKDIR /go
