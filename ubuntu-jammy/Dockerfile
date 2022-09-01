FROM ubuntu:jammy

ENV OS_NAME=ubuntu

# Install packages
RUN apt-get update
RUN apt-get full-upgrade -y
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y build-essential libsdl2-dev libboost-dev libfreetype6-dev zlib1g-dev libpugixml-dev cmake git

# Create build user
RUN useradd compile -m -g users

# Copy build script
USER compile
COPY scripts/build-gf.sh /home/compile
