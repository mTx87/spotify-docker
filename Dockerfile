# Pull base image.
FROM jlesage/baseimage-gui:ubuntu-16.04

# Define working directory.
WORKDIR /tmp

COPY rootfs/ /

# 1. Add the Spotify repository signing keys to be able to verify downloaded packages
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 931FF8E79F0876134EDDBDCCA87FF9DF48BF1C90

# 2. Add the Spotify repository
RUN echo deb http://repository.spotify.com stable non-free | tee /etc/apt/sources.list.d/spotify.list

# 3. Update list of available packages
RUN apt-get update

# 4. Install Spotify
RUN apt-get install -y spotify-client


ENV APP_NAME="spotify" 

# Define mountable directories.
VOLUME ["/config"]
VOLUME ["/media"]
