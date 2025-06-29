########################################################
##  MS Copilot wrote this as a derivative of the Java version
##  we're running in the other directory.
##
##  To build this container image, run the following in a
##  terminal window:
##  docker build -t calipsoii/minecraft-bedrock-server:1.21.92.1 .
##
##
##  docker run -it \
##  --name minecraft-bedrock-survival \
##  --mount type=bind,source="/usr/minecraft-server/serverdata-bedrock-survival",target=/serverdata \
##  --mount type=bind,source="/usr/minecraft-server/serverjars",target=/serverjars \
##  --restart always \
##  -p 19132:19132/udp \
##  calipsoii/minecraft-bedrock-server:1.21.92.1
##
##
##
########################################################

# Use a minimal base image
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install required dependencies
RUN apt-get update && \
    apt-get install -y unzip libcurl4 openssl ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -ms /bin/bash minecraft

# Volume for world data/configs
VOLUME ["/serverdata"]
WORKDIR /serverdata

# Switch to user context
USER minecraft

# Expose Bedrock UDP port
EXPOSE 19132/udp

# Launch server
CMD ["sh", "-c", "LD_LIBRARY_PATH=/serverdata /serverdata/bedrock_server"]
