#!/usr/bin/env bash

set -xe

HELMCTL_CHARTS_LOCATION=${HELMCTL_CHARTS_LOCATION:-/root}
cp -r helmctl/charts/* "${HELMCTL_CHARTS_LOCATION}/"
cp "helmctl/bin/helmctl" /usr/local/bin/
chmod +x /usr/local/bin/helmctl 