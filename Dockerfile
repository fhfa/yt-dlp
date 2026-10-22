FROM docker.io/python:3-slim AS builder

# Allow for installing a specific yt-dlp version published in PyPi.org
# otherwise fallback to the latest stable version.
ARG YT_DLP_VERSION=""

# Build tools are only needed for compiling native wheels in the builder stage.
RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

RUN python -m pip install --no-cache-dir --root-user-action=ignore --prefix=/usr/local \
    brotli yt-dlp-ejs certifi mutagen pycryptodomex requests websockets xattr "yt-dlp[default,curl-cffi]${YT_DLP_VERSION:+==${YT_DLP_VERSION}}" \
    && python -m pip cache purge || true

# Get ffmpeg special build with yt-dlp related patches.
# This is assembled in the builder stage so the runtime image keeps only the final binaries.
ARG TARGETARCH
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl xz-utils \
    && cd /tmp \
    && case "${TARGETARCH}" in \
           amd64) FFMPEG_ARCH=linux64 ;; \
           arm64) FFMPEG_ARCH=linuxarm64 ;; \
           *) echo "Unsupported architecture ${TARGETARCH}" && exit 1 ;; \
       esac \
    && curl -fsSL -o "ffmpeg-master-latest-${FFMPEG_ARCH}-gpl.tar.xz" "https://github.com/yt-dlp/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-${FFMPEG_ARCH}-gpl.tar.xz" \
    && tar Jxf "ffmpeg-master-latest-${FFMPEG_ARCH}-gpl.tar.xz" \
    && install -m 0755 "ffmpeg-master-latest-${FFMPEG_ARCH}-gpl/bin/ffmpeg" /usr/local/bin/ffmpeg \
    && install -m 0755 "ffmpeg-master-latest-${FFMPEG_ARCH}-gpl/bin/ffprobe" /usr/local/bin/ffprobe \
    && apt-get purge -y --auto-remove xz-utils curl \
    && rm -rf "ffmpeg-master-latest-${FFMPEG_ARCH}-gpl" "ffmpeg-master-latest-${FFMPEG_ARCH}-gpl.tar.xz" /tmp/* /var/tmp/* /var/lib/apt/lists/* /var/cache/apt/archives/* /root/.cache

FROM docker.io/python:3-slim AS runtime
LABEL maintainer="github.com/fhfa/yt-dlp"

# Install only runtime dependencies needed for the final image.
RUN apt-get update \
    && apt-get install -y --no-install-recommends --no-install-suggests atomicparsley ca-certificates curl unzip \
    && DENO_INSTALL=/usr/local sh -c "$(curl -fsSL https://deno.land/install.sh)" \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* /root/.cache /tmp/* /var/tmp/*

# Copy the already-installed Python packages and FFmpeg binaries from the builder stage.
COPY --from=builder /usr/local /usr/local

# Create unprivileged user
RUN useradd --shell /usr/sbin/nologin appuser \
    && mkdir -p /storage \
    && chown appuser:appuser /storage

# Workdir where yt-dlp usage is performed
WORKDIR /storage

# Run with unprevileged user
USER appuser

# Entry point for the container
ENTRYPOINT ["yt-dlp"]

# Show help by default
CMD ["--help"]
