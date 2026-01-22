# FFmpeg Params (Reference)

Goal: H.264 MP4 with audio, 1080x1440 (or 1080x1920) target.

## Video encode
- codec: libx264
- profile: high
- pix_fmt: yuv420p
- crf: 18-23
- preset: medium

## Audio encode
- codec: aac
- bitrate: 128k
- sample_rate: 44100

## Muxing order
1) base image -> video stream
2) apply motion overlay
3) apply waveform overlay
4) mux audio
