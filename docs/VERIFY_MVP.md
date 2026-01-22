MVP Verify (dev)

Goal: minimal smoke check for Create -> Play -> Map list.

Backend (local):
- Install ffmpeg if needed.
- Run: `LOCAL_RENDER=1 backend/run_verify.sh`
- Expect: smoke test passes and local render reports ok.

iOS (simulator):
- Open: `IOS/MomentPin.xcodeproj`
- Run on iPhone simulator.
- Check:
  - Nearby shows map, bubbles, list.
  - Tap a bubble or "随机听听" opens Detail.
  - Tap "+" to enter Create flow.

Notes:
- This is a UI/data placeholder flow until real API wiring is done.
