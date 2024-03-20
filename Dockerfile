FROM ubuntu:latest as installer
RUN apt-get -y update && apt-get -y install curl git openssl build-essential
RUN apt-get install curl
RUN apt-get install unzip
RUN apt-get install wget
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.23.0/bin/linux/amd64/kubectl
RUN chmod a+x kubectl
RUN wget https://get.helm.sh/helm-v3.10.2-linux-amd64.tar.gz
RUN tar -zxvf helm-v3.10.2-linux-amd64.tar.gz
RUN mv linux-amd64/helm /usr/local/bin/helm

FROM alpine:latest
RUN apk update
RUN apk add curl
RUN apk add postgresql-client
RUN apk add --update coreutils
COPY --from=installer kubectl /usr/local/bin/kubectl
COPY --from=installer /usr/local/bin/helm /usr/local/bin/helm
RUN apk add --no-cache python3 py3-pip \
    && pip3 install --upgrade pip \
    && pip3 install --no-cache-dir awscli \
    && rm -rf /var/cache/apk/*
ENV BUILD_DEPS="gettext"  \
    RUNTIME_DEPS="libintl"

RUN set -x && \
    apk add --update $RUNTIME_DEPS && \
    apk add --virtual build_deps $BUILD_DEPS &&  \
    cp /usr/bin/envsubst /usr/local/bin/envsubst && \
    apk del build_deps
RUN apk add --no-cache vault libcap && \
    setcap cap_ipc_lock= /usr/sbin/vault
RUN apk add jq
ENV BUILD_DEPS="gettext"  \
    RUNTIME_DEPS="libintl"

RUN set -x && \
    apk add --update $RUNTIME_DEPS && \
    apk add --virtual build_deps $BUILD_DEPS &&  \
    cp /usr/bin/envsubst /usr/local/bin/envsubst && \
    apk del build_deps
RUN apk add bash