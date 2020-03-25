FROM alpine as base

WORKDIR /tmp
RUN apk add --no-cache \
    bash

# Use a disposable image to deal with the installation process
FROM base as install-image

RUN apk add --no-cache \
    curl \
    git

# Helm
ADD install/helm.sh .
RUN sh helm.sh

# Build images with binaries only
FROM base as base-bin
COPY --from=install-image /usr/local/bin /usr/local/bin
COPY --from=install-image /root /root

# Build final image
FROM base-bin

# helmctl
ADD install/helmctl helmctl
ADD install/helmctl.sh .
RUN sh helmctl.sh

# Set envvar needed for helm
ENV XDG_DATA_HOME=/root/.local/share

WORKDIR /workspace
ENV HOME /workspace
ENTRYPOINT [ "helmctl" ]