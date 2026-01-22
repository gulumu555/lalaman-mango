---
name: image-to-mp4-pipeline
description: Use when implementing or validating the photo+voice+waveform+motion pipeline that outputs MP4.
---

# Image to MP4 Pipeline

Use this skill to implement or validate the render pipeline for MomentPin.

## Workflow
1) Validate inputs: photo (required), voice (optional), duration target 6-12s.
2) Render motion layer using safe templates.
3) Render waveform overlay synced to voice.
4) Mux video + audio to MP4.
5) Run acceptance checks.

## References
- FFmpeg params and muxing order: `references/ffmpeg_params.md`
- Script template: `scripts/render_mp4.sh`
