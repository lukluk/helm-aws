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
COPY deployer /usr/local/bin/deployer
COPY push /usr/local/bin/push
COPY --from=installer kubectl /usr/local/bin/kubectl
COPY --from=installer /usr/local/bin/helm /usr/local/bin/helm
RUN chmod +x /usr/local/bin/deployer
RUN chmod +x /usr/local/bin/push
RUN apk add --no-cache python3 py3-pip \
    && pip3 install --upgrade pip \
    && pip3 install --no-cache-dir awscli \
    && rm -rf /var/cache/apk/*

