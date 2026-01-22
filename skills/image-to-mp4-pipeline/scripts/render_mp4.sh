#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   render_mp4.sh <input_image> <input_audio> <output_mp4>

INPUT_IMAGE=${1:?missing input image}
INPUT_AUDIO=${2:-}
OUTPUT_MP4=${3:?missing output mp4}

# Placeholder: motion and waveform layers should be rendered upstream.
# Replace the filters with real motion/waveform overlays.
if [[ -n "$INPUT_AUDIO" ]]; then
  ffmpeg -y \
    -loop 1 -i "$INPUT_IMAGE" \
    -i "$INPUT_AUDIO" \
    -t 8 \
    -vf "scale=1080:1440,format=yuv420p" \
    -c:v libx264 -profile:v high -crf 20 -preset medium \
    -c:a aac -b:a 128k -ar 44100 \
    "$OUTPUT_MP4"
else
  ffmpeg -y \
    -loop 1 -i "$INPUT_IMAGE" \
    -t 8 \
    -vf "scale=1080:1440,format=yuv420p" \
    -c:v libx264 -profile:v high -crf 20 -preset medium \
    "$OUTPUT_MP4"
fi
