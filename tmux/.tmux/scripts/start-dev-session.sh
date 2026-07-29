#!/usr/bin/env bash
set -euo pipefail

cwd="${1:?current path required}"
window_name="dev"
launch_root="$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null || printf '%s' "$cwd")"
app_dir="$launch_root/app"

printf -v left_cmd  'cd %q && uv run manage.py runserver 0.0.0.0:7777 --settings=server.settings.local --skip-checks' "$launch_root"
printf -v right_cmd 'cd %q && pnpm start' "$app_dir"

# 현재 세션 이름 가져오기 (새 세션 만들지 않고 그대로 사용 → debug 모드와 동일)
session_name="$(tmux display -p '#S')"

# 이미 dev window가 있으면 그쪽으로 이동만 (중복 실행 방지)
if tmux list-windows -t "$session_name" -F '#W' | grep -qx "$window_name"; then
  tmux select-window -t "${session_name}:${window_name}"
  exit 0
fi

# 새 window "dev" 만들기 (현재 nvim window는 건드리지 않음)
# 좌측 pane (BE - runserver)
left_pane="$(tmux new-window -P -F '#{pane_id}' -t "$session_name" -n "$window_name" -c "$launch_root")"
# 우측 pane (FE - pnpm start)
right_pane="$(tmux split-window -h -P -F '#{pane_id}' -t "$left_pane" -c "$app_dir")"

tmux send-keys -t "$left_pane"  "$left_cmd"  C-m
tmux send-keys -t "$right_pane" "$right_cmd" C-m

tmux select-layout -t "${session_name}:${window_name}" even-horizontal >/dev/null
tmux select-pane -t "$left_pane"
