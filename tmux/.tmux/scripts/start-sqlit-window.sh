#!/usr/bin/env bash
set -euo pipefail

# 현재 tmux 세션의 window :3 에 sqlit (lemonbase-local) 띄우기.
# - .zshrc 의 ldb() 함수가 호출.
# - :3 가 비어있으면 새로 만들고 `sqlit -c lemonbase-local` 실행.
# - :3 가 이미 있으면 select-window 만 (중복 실행 X).

if [ -z "${TMUX:-}" ]; then
  echo "tmux 세션 안에서 실행해주세요." >&2
  exit 1
fi

session_name="$(tmux display -p '#S')"

# window index 3 이 이미 있으면 그쪽으로만 이동
if tmux list-windows -t "$session_name" -F '#I' | grep -qx '3'; then
  tmux select-window -t "${session_name}:3"
  exit 0
fi

# 없으면 :3 자리에 새 window 생성 후 sqlit 실행
tmux new-window -t "${session_name}:3" -n "sqlit" -c "$HOME" "sqlit -c lemonbase-local"
