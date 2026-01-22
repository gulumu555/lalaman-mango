#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$BASE_DIR/.." && pwd)"
LOG_FILE="/tmp/momentpin_uvicorn.log"
VENV_DIR="$ROOT_DIR/.venv"
PORT="${PORT:-8001}"
PYTHON_BIN="${PYTHON_BIN:-python3}"
LOCAL_RENDER="${LOCAL_RENDER:-0}"

if [ ! -f "$VENV_DIR/bin/python" ]; then
  echo "未发现虚拟环境，正在创建 $VENV_DIR ..."
  "$PYTHON_BIN" -m venv "$VENV_DIR"
fi

VENV_PYTHON="$VENV_DIR/bin/python"

if ! "$VENV_PYTHON" -c "import uvicorn" >/dev/null 2>&1; then
  echo "正在为虚拟环境安装依赖..."
  "$VENV_PYTHON" -m pip install -r "$ROOT_DIR/backend/requirements.txt"
fi

"$VENV_PYTHON" -m uvicorn backend.app:app --port "$PORT" > "$LOG_FILE" 2>&1 &
UVICORN_PID=$!

sleep 1

if ! kill -0 "$UVICORN_PID" 2>/dev/null; then
  echo "后端启动失败，日志如下："
  tail -n 50 "$LOG_FILE" || true
  exit 1
fi

BASE_URL="http://127.0.0.1:$PORT" LOCAL_RENDER="$LOCAL_RENDER" "$ROOT_DIR/backend/smoke_test.sh"

echo "验证完成，正在关闭后端..."
kill "$UVICORN_PID" || true
