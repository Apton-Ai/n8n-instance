# ---- Stage 1: builder — fetches static binaries, never touches the n8n image ----
FROM alpine:3.20 AS builder

RUN apk add --no-cache curl xz \
    && curl -fsSL https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz -o /tmp/ffmpeg.tar.xz \
    && tar -xf /tmp/ffmpeg.tar.xz -C /tmp \
    && mv /tmp/ffmpeg-*-amd64-static/ffmpeg /tmp/ffmpeg-bin \
    && mv /tmp/ffmpeg-*-amd64-static/ffprobe /tmp/ffprobe-bin \
    && curl -fsSL https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /tmp/yt-dlp \
    && chmod +x /tmp/yt-dlp /tmp/ffmpeg-bin /tmp/ffprobe-bin \
    && curl -fsSL "https://github.com/google/fonts/raw/main/ofl/notosans/NotoSans%5Bwdth%2Cwght%5D.ttf" -o /tmp/NotoSans.ttf

# ---- Stage 2: the actual n8n image — no apk/apt needed, just copy binaries in ----
# Pinned to 1.x so Execute Command stays enabled by default (2.0 disables it).
FROM n8nio/n8n:1.123.66

USER root

COPY --from=builder /tmp/ffmpeg-bin /usr/local/bin/ffmpeg
COPY --from=builder /tmp/ffprobe-bin /usr/local/bin/ffprobe
COPY --from=builder /tmp/yt-dlp /usr/local/bin/yt-dlp
COPY --from=builder /tmp/NotoSans.ttf /usr/share/fonts/NotoSans.ttf

RUN mkdir -p /tmp/clipmachine && chown -R node:node /tmp/clipmachine

USER node
