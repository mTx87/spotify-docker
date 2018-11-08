#
# TinyMediaManager Dockerfile
#

#FROM jlesage/baseimage-gui:alpine-3.8
#FROM jlesage/baseimage-gui:alpine-3.5-glibc-v3.3.4
#FROM jlesage/baseimage-gui:alpine-3.8-glibc
FROM jlesage/baseimage-gui:ubuntu-16.04

# Define working directory.
WORKDIR /tmp

# 1. Add the Spotify repository signing keys to be able to verify downloaded packages
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 931FF8E79F0876134EDDBDCCA87FF9DF48BF1C90

# 2. Add the Spotify repository
RUN echo deb http://repository.spotify.com stable non-free | tee /etc/apt/sources.list.d/spotify.list

# 3. Update list of available packages
RUN apt-get update

# 4. Install Spotify
RUN apt-get install -y spotify-client


# Maximize only the main/initial window.
RUN \
    sed-patch 's/<application type="normal">/<application type="normal" title="spotify">/' \
        /etc/xdg/openbox/rc.xml

# Generate and install favicons.
RUN \
    APP_ICON_URL=https://raw.githubusercontent.com/faviouz/fix-spotify-icon/master/src/fix-spotify-icon.sh && \
    install_app_icon.sh "$APP_ICON_URL"

# Add files.
COPY rootfs/ /

# Set environment variables.
ENV APP_NAME="Spotify" \
    S6_KILL_GRACETIME=8000

# Define mountable directories.
VOLUME ["/config"]
VOLUME ["/media"]

# Metadata.
LABEL \
      org.label-schema.name="spotify" \
      org.label-schema.description="Docker container for Spotify" \
      org.label-schema.version="unknown" \
      org.label-schema.vcs-url="https://github.com/mTx87/spotify-docker" \
      org.label-schema.schema-version="1.0"
