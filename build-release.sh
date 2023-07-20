#!/bin/bash

if [ $# -ne 1 ]
then
	echo "Missing argument"
	echo -e "\t$0 TAG"
	exit 1
fi

TAG=$1

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
    --rm \
    --user compile \
    -v $PWD/packages:/home/compile/packages \
    "gamedev-framework:$DISTRIBUTION" \
    /bin/bash \
      /home/compile/build-gf.sh \
        --branch $TAG \
        --package-suffix "${DISTRIBUTION}"
done
