#!/usr/bin/env bash
set -euo pipefail

# 현재 tmux 세션의 window :3 에 sqlit (Lemonbase Local) 띄우기.
# - .zshrc 의 ldb() 함수가 호출.
# - :3 가 비어있으면 새로 만들고 sqlit 실행.
# - :3 가 이미 있으면 select-window 만 (중복 실행 X).
#
# 다른 머신에서 connection 이름이 다르면 SQLIT_CONNECTION 환경변수로 override.

if [ -z "${TMUX:-}" ]; then
  echo "tmux 세션 안에서 실행해주세요." >&2
  exit 1
fi

# sqlit connections.json 에 등록된 이름. 기본값은 "Lemonbase Local".
# 머신마다 다르면 .zshrc.local 등에서 export SQLIT_CONNECTION="..." 로 override.
sqlit_connection="${SQLIT_CONNECTION:-Lemonbase Local}"

session_name="$(tmux display -p '#S')"

# window index 3 이 이미 있으면 그쪽으로만 이동
if tmux list-windows -t "$session_name" -F '#I' | grep -qx '3'; then
  tmux select-window -t "${session_name}:3"
  exit 0
fi

# 없으면 :3 자리에 새 window 생성 후 sqlit 실행 (connection 이름이 공백 포함이라 따옴표 처리)
tmux new-window -t "${session_name}:3" -n "sqlit" -c "$HOME" "sqlit -c '${sqlit_connection}'"
