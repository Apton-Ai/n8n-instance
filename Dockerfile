# Pinned to n8n 1.123.66 — the last stable 1.x line before v2.0, which disables
# the Execute Command node by default. Do NOT change this to :latest, or you'll
# land back on 2.0 and lose Execute Command again.
FROM n8nio/n8n:1.123.66

USER root

# ffmpeg (video editing), python3+pip (needed for yt-dlp), fontconfig + Noto
# (bold sans font for burned-in captions), curl (debugging network calls)
RUN apk add --no-cache \
    ffmpeg \
    python3 \
    py3-pip \
    fontconfig \
    font-noto \
    curl \
    && pip3 install --break-system-packages --no-cache-dir yt-dlp

# Scratch working directory for downloads/clips. NOT persistent — this is
# wiped on every restart/redeploy since Render free tier has no persistent
# disk. Real storage lives in Supabase Storage, never here.
RUN mkdir -p /tmp/clipmachine && chown -R node:node /tmp/clipmachine

USER node
