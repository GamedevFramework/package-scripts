FROM debian:bookworm

ENV OS_NAME=debian

# Install packages
RUN apt-get update
RUN apt-get full-upgrade -y
RUN apt-get install -y build-essential libsdl2-dev libboost-dev libfreetype6-dev zlib1g-dev libpugixml-dev cmake git

# Create build user
RUN useradd compile -m -g users

# Copy build script
USER compile
COPY scripts/build-gf.sh /home/compile
