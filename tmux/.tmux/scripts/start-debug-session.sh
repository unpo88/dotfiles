#!/usr/bin/env bash
set -euo pipefail

cwd="${1:?current path required}"
launch_root="$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null || printf '%s' "$cwd")"
app_dir="$launch_root/app"

# Branch-env worktree mode: don't open a new be-fe window — restart only the
# existing dev window's BE pane in debugpy mode. Triggered when project .env
# defines WT_API_PORT (rename of legacy project-specific marker).
# NOTE: the variable names below (WORKTRUNK_*) come from one project's .env
# convention. Adjust if your project uses different names.
if [ -f "$launch_root/.env" ] && grep -q "^WORKTRUNK_API_PORT=" "$launch_root/.env"; then
  # Load branch-env metadata (WORKTRUNK_API_PORT, WORKTRUNK_DOMAIN, ...).
  # NOTE: macOS 기본 bash 3.2는 `source <(...)` (process substitution)에서
  # 변수를 부모 셸로 전파하지 못함. eval로 우회.
  set -a
  eval "$(grep -E "^WORKTRUNK_" "$launch_root/.env")"
  set +a

  # worktree별 debugpy 포트: WORKTRUNK_API_PORT + 40000.
  # 본진(아래 일반 분기)은 5678 고정, worktree들은 이 규약으로 독립 포트 보유.
  # python.lua의 DapDjango 어댑터/폴링도 동일 규약을 따름.
  debugpy_port=$((WORKTRUNK_API_PORT + 40000))

  # tmux 안에서 호출되면 display로 session 얻고, 외부(예: wtn)에서 호출되면 envar 사용
  session_name="${WT_SESSION_NAME:-$(tmux display -p '#S' 2>/dev/null)}"
  if [ -z "$session_name" ]; then
    echo "❌ 세션을 식별할 수 없습니다 (WT_SESSION_NAME 미설정 + tmux 외부)." >&2
    exit 1
  fi
  # dev 윈도우 안에서 BE pane을 동적으로 찾기 (python/uv 실행 중인 pane).
  # wtn이 좌우 swap한 환경(FE 좌/BE 우)과 worktrunk 기본 환경(BE 좌/FE 우) 양쪽 모두 지원.
  be_pane="$(tmux list-panes -t "${session_name}:dev" -F '#{pane_id} #{pane_current_command}' 2>/dev/null \
    | awk 'tolower($2) ~ /^(python|uv)$/ {print $1; exit}')"

  if [ -z "$be_pane" ]; then
    tmux display-message "Could not find dev-window BE pane (no python/uv running)."
    exit 1
  fi

  # Stop existing runserver → restart in debugpy mode (using branch-env port/domain)
  # NOTE: -Xfrozen_modules=off / PYDEVD_DISABLE_FILE_VALIDATION=1 → Python 3.11+ frozen
  # modules가 debugpy breakpoint를 miss시키는 문제 회피
  tmux send-keys -t "$be_pane" C-c
  sleep 0.5
  tmux send-keys -t "$be_pane" "PYDEVD_DISABLE_FILE_VALIDATION=1 API_PORT=\"${WORKTRUNK_API_PORT}\" WORKTRUNK_DOMAIN=\"${WORKTRUNK_DOMAIN}\" uv run --with debugpy python -Xfrozen_modules=off -m debugpy --listen ${debugpy_port} manage.py runserver \"0.0.0.0:${WORKTRUNK_API_PORT}\" --settings=server.settings.local --skip-checks --noreload" C-m

  # 백그라운드: debugpy_port listen 대기 후 nvim 윈도우에 :DapDjango 자동 입력
  (
    for _ in $(seq 1 60); do
      lsof -i :"${debugpy_port}" -sTCP:LISTEN >/dev/null 2>&1 && break
      sleep 0.5
    done
    nvim_pane=$(tmux list-panes -s -t "$session_name" \
      -F '#{pane_id} #{pane_current_command}' \
      | awk '$2 ~ /^n?vim$/ {print $1; exit}')
    if [ -n "$nvim_pane" ]; then
      tmux send-keys -t "$nvim_pane" Escape
      sleep 0.1
      tmux send-keys -t "$nvim_pane" ":DapDjango" Enter
    fi
  ) >/dev/null 2>&1 &

  tmux display-message "Restarting BE in debugpy mode (waiting on port ${debugpy_port})..."
  exit 0
fi

# 현재 세션 이름 가져오기 (새 세션 만들지 않고 그대로 사용)
session_name="$(tmux display -p '#S')"

# 이미 be-fe window가 있으면 (debug/dev 무관) 내리고 새로 띄움
if tmux list-windows -t "$session_name" -F '#W' | grep -qx 'be-fe'; then
  tmux kill-window -t "${session_name}:be-fe"
  sleep 0.5
fi

# 새 window "be-fe" 만들기 (현재 nvim window는 건드리지 않음)
# 좌측 pane (FE)
fe_pane="$(tmux new-window -P -F '#{pane_id}' -n "be-fe" -c "$app_dir")"
tmux send-keys -t "$fe_pane" "pnpm start" C-m

# 우측 pane (BE - debugpy listen, nvim에서 :DapDjango 로 attach)
# NOTE: -Xfrozen_modules=off / PYDEVD_DISABLE_FILE_VALIDATION=1 → Python 3.11+ frozen
# modules가 debugpy breakpoint를 miss시키는 문제 회피
be_pane="$(tmux split-window -h -P -F '#{pane_id}' -t "$fe_pane" -c "$launch_root")"
tmux send-keys -t "$be_pane" "PYDEVD_DISABLE_FILE_VALIDATION=1 uv run --with debugpy python -Xfrozen_modules=off -m debugpy --listen 5678 manage.py runserver 0.0.0.0:7777 --settings=server.settings.local --skip-checks --noreload" C-m

# 백그라운드: BE가 5678 listen 시작될 때까지 기다린 후, 같은 세션의 nvim pane에 :DapDjango 자동 입력
(
  # 5678 listen 대기 (최대 30초)
  for _ in $(seq 1 60); do
    if lsof -i :5678 -sTCP:LISTEN >/dev/null 2>&1; then
      break
    fi
    sleep 0.5
  done

  # 같은 세션에서 nvim 실행 중인 pane 찾기
  nvim_pane=$(tmux list-panes -s -t "$session_name" \
    -F '#{pane_id} #{pane_current_command}' \
    | awk '$2 ~ /^n?vim$/ {print $1; exit}')

  if [ -n "$nvim_pane" ]; then
    # Esc로 normal mode 확보 후 :DapDjango 실행
    tmux send-keys -t "$nvim_pane" Escape
    sleep 0.1
    tmux send-keys -t "$nvim_pane" ":DapDjango" Enter
  fi
) >/dev/null 2>&1 &
