FROM ghcr.io/linuxserver/baseimage-selkies:debiantrixie

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="OpenAudible"

# title
ENV TITLE="OpenAudible"

# Validate supported architectures (x86_64 or aarch64)
RUN \
  ARCH="$(uname -m)" && \
  ([ "$ARCH" = "x86_64" ] || [ "$ARCH" = "aarch64" ]) || \
  (echo "ERROR: Unsupported architecture $ARCH. OpenAudible requires x86_64 or aarch64" && exit 1)

# OpenAudible configuration
ENV DEBIAN_FRONTEND=noninteractive \
    OA_PACKAGING=docker \
    OA_BETA=true \
    OA_KIOSK=true \
    oa_internal_browser=true \
    APP_DIR=/app/OpenAudible

RUN \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install -y \
    ca-certificates \
    libgtk-3-bin \
    libwebkit2gtk-4.1-0 \
    vim \
    wget \
    xterm && \
  echo "**** cleanup ****" && \
  apt-get clean && \
  rm -rf \
    /var/lib/apt/lists/* \
    /tmp/*

# add local files
COPY assets/start_openaudible.sh /app/start_openaudible.sh
COPY assets/install.sh /app/install.sh
COPY assets/upgrade.sh /app/upgrade.sh

RUN \
  echo "**** set permissions and configure ****" && \
  chmod +x \
    /app/*.sh && \
  chown -R abc:abc \
    /app && \
  mkdir -p $APP_DIR && \
  chown -R abc:abc $APP_DIR && \
  ln -s /config/OpenAudible /root/OpenAudible && \
  echo "/app/start_openaudible.sh" > /defaults/autostart

# ports and volumes
EXPOSE 3000
EXPOSE 3001
VOLUME /config
