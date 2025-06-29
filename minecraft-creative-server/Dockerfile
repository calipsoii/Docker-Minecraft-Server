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
##  --mount type=bind,source="/usr/minecraft-server/serverdata-bedrock-creative",target=/serverdata \
##  --mount type=bind,source="/usr/minecraft-server/serverjars-bedrock",target=/serverjars \
##  --restart always \
##  -p 19132:19132/udp \
##  minecraft-bedrock-server:1.21.92.1
##
##
##
########################################################

# Use a minimal base image
FROM ubuntu:22.04

# Environment config
ENV DEBIAN_FRONTEND=noninteractive
ENV BEDROCK_VERSION=1.21.92.1
ENV BEDROCK_URL=https://www.minecraft.net/bedrockdedicatedserver/bin-linux/bedrock-server-${BEDROCK_VERSION}.zip

# Install dependencies
RUN apt-get update && \
    apt-get install -y curl unzip libcurl4 openssl ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create user
RUN useradd -ms /bin/bash minecraft

# Working directory to store server binary (bind mount here)
VOLUME ["/serverjars"]
WORKDIR /serverjars

# Download the Bedrock server if not already mounted
RUN curl -o bedrock-server.zip ${BEDROCK_URL} && \
    unzip bedrock-server.zip && \
    rm bedrock-server.zip && \
    chmod +x bedrock_server

# Assign permissions
RUN chown -R minecraft:minecraft /serverjars

# Use non-root user
USER minecraft

# Data will be bind-mounted to this location
VOLUME ["/serverdata"]
WORKDIR /serverdata

# Expose Bedrock port
EXPOSE 19132/udp

# Startup command
CMD ["/serverjars/bedrock_server"]
