FROM alpine:latest

RUN  apk update && apk add --no-cache curl && apk add --no-cache jq

WORKDIR /root/

COPY bin /root/bin

ENV PATH /root/bin:$PATH
