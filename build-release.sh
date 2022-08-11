#!/bin/bash

# Distributions
declare -a DISTRIBUTIONS=("debian-bullseye")

mkdir -p packages
chmod a+w packages

for DISTRIBUTION in ${DISTRIBUTIONS[@]}
do
  DISTRIBUTION_FAMILY=${DISTRIBUTION%%-*}
  DISTRIBUTION_NAME=${DISTRIBUTION#*-}

  # Build docker image
  docker build -f "$DISTRIBUTION/Dockerfile" -t "gamedev-framework:$DISTRIBUTION" .

  # Run compilation
  docker run \
    --user compile \
    -v $PWD/packages:/home/compile/packages \
    "gamedev-framework:$DISTRIBUTION" \
    /bin/bash \
      /home/compile/build-gf.sh \
        --branch master \
        --runtime-dependencies "libsdl2-2.0-0,libfreetype6,zlib1g,libpugixml1v5" \
        --package-suffix "-${DISTRIBUTION_FAMILY}~${DISTRIBUTION_NAME}"
done
