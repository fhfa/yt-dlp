FROM docker.io/python:3-slim
LABEL maintainer="github.com/fhfa/yt-dlp"

# Install dependencies and minimal packages for SSL/verification
RUN apt-get update \
    && apt-get install -y --no-install-recommends atomicparsley curl wget xz-utils ca-certificates unzip \
    && DENO_INSTALL=/usr/local sh -c "$(wget -qO- https://deno.land/install.sh)" \
    && rm -rf /var/lib/apt/lists/*

# Get ffmpeg special build with yt-dlp related patches
# use Docker buildkit's TARGETARCH to pick correct binary
ARG TARGETARCH
RUN cd /tmp \
    && case "${TARGETARCH}" in \
           amd64) FFMPEG_ARCH=linux64 ;; \
           arm64) FFMPEG_ARCH=linuxarm64 ;; \
           *) echo "Unsupported architecture ${TARGETARCH}" && exit 1 ;; \
       esac \
    && wget "https://github.com/yt-dlp/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-${FFMPEG_ARCH}-gpl.tar.xz" \
    && tar Jxf "ffmpeg-master-latest-${FFMPEG_ARCH}-gpl.tar.xz" \
    && mv "ffmpeg-master-latest-${FFMPEG_ARCH}-gpl/bin/ffmpeg" /usr/local/bin \
    && mv "ffmpeg-master-latest-${FFMPEG_ARCH}-gpl/bin/ffprobe" /usr/local/bin \
    && chmod +x /usr/local/bin/ffmpeg /usr/local/bin/ffprobe \
    && rm -rf "ffmpeg-master-latest-${FFMPEG_ARCH}-gpl" "ffmpeg-master-latest-${FFMPEG_ARCH}-gpl.tar.xz"

# Create unprivileged user with home at /storage
RUN useradd -M --home-dir /storage --shell /usr/sbin/nologin appuser \
    && mkdir -p /storage \
    && chown appuser:appuser /storage

# Allow for installing a specific yt-dlp version published in PyPi.org
# otherwise fallback to the latest stable version.
ARG YT_DLP_VERSION=""

# Upgrade pip and install yt-dlp with recommended dependencies
RUN python -m pip install --no-cache-dir --root-user-action=ignore \
    brotli yt-dlp-ejs certifi mutagen pycryptodomex requests websockets xattr "yt-dlp[default,curl-cffi]${YT_DLP_VERSION:+==${YT_DLP_VERSION}}"

# Workdir where yt-dlp usage is performed
WORKDIR /storage

# Run with unprevileged user
USER appuser

# Entry point for the container
ENTRYPOINT ["yt-dlp"]

# Show help by default
CMD ["--help"]
