########################################################
##  This file copied from Marc Tönsing's at:
##  https://github.com/mtoensing/Docker-Minecraft-PaperMC-Server
##
##  I want mine to run Vanilla (not Paper) so I'm editing
##  it slightly to suit my needs.
########################################################


########################################################
############## We use a java base image ################
########################################################
FROM openjdk:11 AS build

# This is a working directory within the OpenJDK Docker 
# image that we downloaded above.
WORKDIR /opt/minecraft

# We store all the server jar's in a mounted volume and
# retrieve them at runtime
VOLUME "/serverjars"

# Copy the desired server JAR from the mounted volume
ADD /serverjars/minecraft_server.1.16.4.jar /opt/minecraft/

# We need a user to actually run the process inside the
# container, so create it here and grant it permissions
RUN useradd -ms /bin/bash minecraft && \
    chown minecraft /opt/minecraft -R

# Switch to that user context
USER minecraft

########################################################
############## Running environment #####################
########################################################
FROM openjdk:11 AS runtime

# Working directory
WORKDIR /data

# Volumes for the external data (Server, World, Config...)
VOLUME "/data"

# Expose minecraft port
EXPOSE 25565/tcp
EXPOSE 25565/udp

# Set memory size
ARG memory_size=4G
ENV MEMORYSIZE=$memory_size

# Set Java Flags
ARG java_flags="-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=mcflags.emc.gs -Dcom.mojang.eula.agree=true"
ENV JAVAFLAGS=$java_flags

WORKDIR /data

# Entrypoint with java optimisations
ENTRYPOINT /usr/local/openjdk-11/bin/java -jar -Xms$MEMORYSIZE -Xmx$MEMORYSIZE $JAVAFLAGS /opt/minecraft/.jar --nojline nogui