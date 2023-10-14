# ARGs
ARG YT_DLP_VERSION=2023.10.13
ARG FFMPEG_VERSION=6.0

### Preparation Image ###
FROM alpine:latest as preparation

# Bring these args into scope
ARG YT_DLP_VERSION
ARG FFMPEG_VERSION

# Get yt-dlp
RUN wget https://github.com/yt-dlp/yt-dlp/releases/download/${YT_DLP_VERSION}/SHA2-256SUMS \
&& SHA256_SUM=`grep 'yt-dlp$' SHA2-256SUMS` \
&& wget https://github.com/yt-dlp/yt-dlp/releases/download/${YT_DLP_VERSION}/yt-dlp \
&& echo "${SHA256_SUM}" | sha256sum -c

# Get ffmpeg
RUN wget https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz \
&& wget https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz.md5 \
&& md5sum -c ffmpeg-release-amd64-static.tar.xz.md5 \
&& tar Jxf ffmpeg-release-amd64-static.tar.xz

### Final Image ###
FROM python:alpine
LABEL maintainer="github.com/containerisation/yt-dlp"

# Bring this arg into scope
ARG FFMPEG_VERSION

# Copy ffmpeg and fprobe from preparation build
# Apply ownership and permissions
COPY --from=preparation ffmpeg-${FFMPEG_VERSION}-amd64-static/ffmpeg /usr/local/bin
COPY --from=preparation ffmpeg-${FFMPEG_VERSION}-amd64-static/ffprobe /usr/local/bin
RUN chown root:root /usr/local/bin/ffmpeg /usr/local/bin/ffprobe \
&& chmod 755 /usr/local/bin/ffmpeg /usr/local/bin/ffprobe 

# Copy yt-dlp from preparation build
COPY --from=preparation yt-dlp /usr/local/bin

# Apply ownership and permissions to yt-dlp
# Add yt-dlp user
# Create and apply permissions to workdir directory
RUN chown root:root /usr/local/bin/yt-dlp \
&& chmod 755 /usr/local/bin/yt-dlp \
&& adduser -D yt-dlp \
&& mkdir /storage \
&& chmod o+w /storage

# Default workdir, user and entrypoint (yt-dlp executable)
WORKDIR /storage
USER yt-dlp
ENTRYPOINT ["yt-dlp"]
CMD ["--help"]