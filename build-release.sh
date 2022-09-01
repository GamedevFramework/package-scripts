#!/bin/bash

# Distributions
declare -a DISTRIBUTIONS=("debian-bullseye" "debian-bookworm" "ubuntu-focal" "ubuntu-jammy")

mkdir -p packages
chmod a+w packages

for DISTRIBUTION in ${DISTRIBUTIONS[@]}
do
  # Build docker image
  docker build -f "$DISTRIBUTION/Dockerfile" -t "gamedev-framework:$DISTRIBUTION" .

  # Run compilation
  docker run \
    --user compile \
    -v $PWD/packages:/home/compile/packages \
    "gamedev-framework:$DISTRIBUTION" \
    /bin/bash \
      /home/compile/build-gf.sh \
        --branch one-package \
        --package-suffix "${DISTRIBUTION}"
done
