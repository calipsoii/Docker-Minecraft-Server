########################################################
##  This file copied from Marc Tönsing's at:
##  https://github.com/mtoensing/Docker-Minecraft-PaperMC-Server
##
##  I want mine to run Vanilla (not Paper) so I'm editing
##  it slightly to suit my needs.
##
##  It took me a long time to figure out where the volumes
##  are stored in Windows using WSL2 subsystem:
##  https://github.com/microsoft/WSL/discussions/4176
##  \\wsl$\docker-desktop-data\version-pack-data\community\docker\volumes\serverjars
##
##  To build this container image, run the following in a
##  terminal window:
##  docker build -t calipsoii/minecraft-server:1.21.3 .
##
########################################################

# Download and use a Java base image (we need 22)
FROM amazoncorretto:21

# Needed to run the useradd utility on amazon image
RUN yum -y install python3 \
    python3-pip \
    shadow-utils

# Create a volume that holds the .jar files for
# the Minecraft server distributable
VOLUME "/serverjars"

# Change to that directory within the Java container
WORKDIR /serverjars

# We actually want the .jar executable over in /opt so copy
# it there now
ARG minecraft_server_ver="minecraft_server.1.21.3.jar"
ENV minecraftserverver=$minecraft_server_ver
COPY $minecraftserverver /opt/minecraft/

# The executable requires a user account so make
# an account with no privileges in case the server
# gets compromised
RUN /usr/sbin/useradd -ms /bin/bash minecraft && \
    chown minecraft /opt/minecraft -R

# Switch to that user context
USER minecraft

# We have a second volume that holds world data
# and allows us to persist it
VOLUME "/serverdata"

# Change to that directory now so that when we run the
# Java JAR it creates the output here
WORKDIR /serverdata

# Expose minecraft port
EXPOSE 25565/tcp
EXPOSE 25565/udp

# Set memory size
ARG min_memory_size=2G
ENV MINMEMORYSIZE=$min_memory_size
ARG max_memory_size=3G
ENV MAXMEMORYSIZE=$max_memory_size

# Set Java Flags
ARG java_flags="-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -Dcom.mojang.eula.agree=true"
ENV JAVAFLAGS=$java_flags

# Entrypoint with java optimisations
WORKDIR /serverdata
ENTRYPOINT /usr/bin/java -jar -Xms$MINMEMORYSIZE -Xmx$MAXMEMORYSIZE $JAVAFLAGS /opt/minecraft/$minecraftserverver