#!/usr/bin/env bash

export HELM_VERSION="v3.1.2"

WORKDIR=$(mktemp -d)

set -xe
cd "${WORKDIR}"

curl -sLO https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz
curl -sL https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz.sha256sum -o checksums.txt
grep "helm-${HELM_VERSION}-linux-amd64.tar.gz" checksums.txt | sha256sum -c
tar -xvzf helm-${HELM_VERSION}-linux-amd64.tar.gz && mv linux-amd64/helm /usr/local/bin/
chmod +x /usr/local/bin/helm

# Install helm plugins
helm plugin install https://github.com/ruizink/helm-diff --version master >/dev/null