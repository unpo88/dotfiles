#!/usr/bin/env bash
set -euo pipefail

cwd="${1:?current path required}"
window_name="be-fe"
launch_root="$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null || printf '%s' "$cwd")"
app_dir="$launch_root/app"

worktrunk_domain=""
worktrunk_api_port=""
worktrunk_frontend_port=""

if [ -f "$launch_root/.env" ]; then
  while IFS='=' read -r key value; do
    value="${value%$'\r'}"
    value="${value%\"}"
    value="${value#\"}"
    value="${value%\'}"
    value="${value#\'}"

    case "$key" in
      WORKTRUNK_DOMAIN) worktrunk_domain="$value" ;;
      WORKTRUNK_API_PORT) worktrunk_api_port="$value" ;;
      WORKTRUNK_FRONTEND_PORT) worktrunk_frontend_port="$value" ;;
    esac
  done < "$launch_root/.env"
fi

# worktree(branch-env) 모드에선 서버 window를 'dev'로 맞춘다.
# Worktrunk이 이미 'dev' window에 같은 WORKTRUNK 포트로 서버를 띄워두기 때문에,
# be-fe로 새 window를 만들면 포트가 충돌해 서버가 안 뜬다(간헐적 실패의 원인).
# 'dev' window를 재시작하면 기존 서버가 내려가 포트가 풀리고, 디버그 세션
# (Ctrl+B Ctrl+B)이 찾는 'dev' window 규약과도 일치한다.
if [ -n "$worktrunk_domain" ] && [ -n "$worktrunk_api_port" ] && [ -n "$worktrunk_frontend_port" ]; then
  window_name="dev"
fi

# worktree 모드면 Caddy 라우트도 등록/갱신한다.
# 이 스크립트는 서버 프로세스만 띄우므로, 라우트가 없으면 서버는 떠도
# https://<domain> 이 라우팅되지 않아 URL이 죽는다(간헐 실패의 실제 원인).
# setup_caddy.sh는 DELETE 후 재등록이라 매번 호출해도 안전(idempotent).
if [ "$window_name" = "dev" ]; then
  _wt_repo="$(basename "$(dirname "$(git -C "$launch_root" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)")" 2>/dev/null)"
  _wt_branch="${worktrunk_domain%.lemonbase.test}"
  if [ -n "$_wt_repo" ] && [ -n "$_wt_branch" ] \
     && [ -x "$launch_root/scripts/worktrunk/setup_caddy.sh" ]; then
    if ! "$launch_root/scripts/worktrunk/setup_caddy.sh" \
         "$_wt_branch" "$_wt_repo" "$worktrunk_api_port" "$worktrunk_frontend_port" >/dev/null 2>&1; then
      tmux display-message "⚠️ Caddy 라우트 등록 실패 — 서버는 뜨지만 도메인 접속이 안 될 수 있음"
    fi
  fi
fi

# 현재 세션에 window로 띄움 (디버그 세션과 같은 be-fe 슬롯 공유)
session_name="$(tmux display -p '#S')"

# 같은 이름 window가 이미 있으면 내리고 새로 띄운다.
# kill 전에 각 pane에 C-c를 보내 기존 서버가 포트를 반납하게 한다.
# (kill-window만 하면 runserver reloader child가 포트를 붙든 채 남아
#  strictPort/Address-already-in-use로 재기동이 실패할 수 있다.)
if tmux list-windows -t "$session_name" -F '#W' | grep -qx "$window_name"; then
  for pane in $(tmux list-panes -t "${session_name}:${window_name}" -F '#{pane_id}'); do
    tmux send-keys -t "$pane" C-c 2>/dev/null || true
  done
  sleep 1
  tmux kill-window -t "${session_name}:${window_name}"
  sleep 0.5
fi

# 새 window "be-fe" 만들기 (디버그 세션과 동일 배치: 좌 FE / 우 BE)
if [ -n "$worktrunk_domain" ] && [ -n "$worktrunk_api_port" ] && [ -n "$worktrunk_frontend_port" ]; then
  fe_cmd="FRONTEND_PORT=\"$worktrunk_frontend_port\" WORKTRUNK_DOMAIN=\"$worktrunk_domain\" API_HOST=\"$worktrunk_domain\" FRONTEND_DEV_DOMAIN=\"$worktrunk_domain\" FRONTEND_DEV_PORT=\"$worktrunk_frontend_port\" pnpm exec vite --port \"$worktrunk_frontend_port\" --host 0.0.0.0 --strictPort"
  be_cmd="API_PORT=\"$worktrunk_api_port\" WORKTRUNK_DOMAIN=\"$worktrunk_domain\" .venv/bin/python ./manage.py runserver \"0.0.0.0:$worktrunk_api_port\" --settings=server.settings.local --skip-checks"
else
  fe_cmd="pnpm start"
  be_cmd="uv run manage.py runserver 0.0.0.0:7777 --settings=server.settings.local --skip-checks"
fi

# 좌측 pane (FE)
fe_pane="$(tmux new-window -P -F '#{pane_id}' -n "$window_name" -c "$app_dir")"
tmux send-keys -t "$fe_pane" "$fe_cmd" C-m

# 우측 pane (BE - 일반 dev, --noreload 없이 자동 리로드)
be_pane="$(tmux split-window -h -P -F '#{pane_id}' -t "$fe_pane" -c "$launch_root")"
tmux send-keys -t "$be_pane" "$be_cmd" C-m

tmux select-layout -t "${session_name}:${window_name}" even-horizontal >/dev/null
tmux select-pane -t "$be_pane"
tmux select-window -t "${session_name}:${window_name}"
