# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
# Homebrew
export PATH=/opt/homebrew/bin:$HOME/.local/bin:$PATH
# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
# nvm
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

autoload -U add-zsh-hook

load-nvmrc() {
  local nvmrc_path
  nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version
    nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$(nvm version)" ]; then
      nvm use
    fi
  elif [ -n "$(PWD=$OLDPWD nvm_find_nvmrc)" ] && [ "$(nvm version)" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}

add-zsh-hook chpwd load-nvmrc
load-nvmrc

export PATH="/opt/homebrew/opt/libxml2/bin:$PATH"
export PATH="/opt/homebrew/opt/libxml2/bin:$PATH"
export PATH="/opt/homebrew/opt/mysql-client@8.0/bin:$PATH"
export PATH="/opt/homebrew/opt/libxml2/bin:$PATH"
export PATH="/opt/homebrew/opt/mysql@8.0/bin:$PATH"
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"
export PATH="/opt/homebrew/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# ===== Orca/Ghostty에서 nvim을 독립 tmux 세션으로 감싸기 =====
# 의도:
#   - 어떤 터미널이든 셸 자체는 plain (자동 tmux attach 안 함)
#   - 단, Orca/Ghostty에서 `nvim` 호출 시 worktree별 독립 tmux 세션 안에서 nvim 실행
#   - 이미 tmux 안이거나 Orca/Ghostty가 아닌 터미널(iTerm 등)에선 plain nvim
nvim() {
  if [ -n "$TMUX" ] || [[ "$TERM_PROGRAM" != "ghostty" && "$TERM_PROGRAM" != "Orca" ]]; then
    command nvim "$@"
    return
  fi

  local quoted="command nvim"
  for arg in "$@"; do
    quoted+=" $(printf '%q' "$arg")"
  done

  local root
  root="$(git -C "$PWD" rev-parse --show-toplevel 2>/dev/null || pwd)"

  local label
  label="$(basename "$root" | tr -c '[:alnum:]_.-' '-')"
  label="${label%-}"

  local session="nvim-${label}-$$"

  tmux new-session -d -s "$session" "$quoted"
  tmux set-option -t "$session" detach-on-destroy on
  tmux attach-session -t "$session"
}

# ===== Ghostty 탭 제목 자동 갱신 =====
# 현재 git 브랜치를 탭 제목으로 표시 (워크트리별 구분).
# git repo가 아니면 cwd 디렉터리명 사용.
precmd() {
  local branch=$(git branch --show-current 2>/dev/null)
  print -Pn "\e]2;${branch:-${PWD##*/}}\a"
}

# ===== wtn: create/attach a branch worktree in Orca/Cmux + nvim =====
# 사용법:
#   wtn <branch-name>              신규 worktree 생성 또는 기존 worktree attach
#   wtn <branch-name> <base>       특정 base 기준 신규 생성
# 동작:
#   [Orca 터미널] wt가 worktree 생성 → Orca worktree 터미널에서 Worktrunk setup + nvim 실행
#   [Cmux 터미널] 기존 Cmux workspace/tmux 세션 + dev(BE/FE) + nvim 윈도우 생성
#   결과:
#     [Orca worktree: <branch>]
#     └─ terminal: DB 복제/Worktrunk setup 로그 → NVIM_WORKTREE=1 nvim .
#   또는:
#     [Cmux workspace: <branch>]
#     └─ [wt-<branch> tmux 세션]
#        ├─ window 1 (nvim): nvim (NVIM_WORKTREE=1)   ← wtn이 추가
#        └─ window 2 (dev) : 좌 FE 로그 / 우 BE 로그  ← `wt` CLI
#     Ctrl-1/2 로 전환
# 주의:
#   - Orca/Cmux workspace 생성에 실패하면 현재 터미널에서 실행하지 않고 오류로 종료
wtn() {
  local name=$1
  local base=$2
  if [ -z "$name" ]; then
    echo "usage: wtn <branch-name> [base-branch]"
    echo "  ex) wtn my-feature"
    echo "  ex) wtn my-feature origin/master"
    return 1
  fi
  local root=$(git rev-parse --show-toplevel 2>/dev/null)
  if [ -z "$root" ]; then
    echo "git repo 안에서 실행해주세요"
    return 1
  fi

  # `wt switch`가 만드는 세션명과 동일하게
  local wt_session="wt-${name//\//-}"

  # 탭 제목 라벨: <branch>(<base>) — base 없으면 <branch>만
  local label="$name"
  [ -n "$base" ] && label="$name($base)"

  # 기존 worktree 존재 여부 확인 (신규 생성 vs 재연결 분기)
  local _wtn_existing=0
  local _wtn_repo
  _wtn_repo=$(basename "$root")
  if git -C "$root" worktree list | awk '{print $3}' | grep -qxF "[$name]"; then
    _wtn_existing=1
  fi

  local _wtn_in_orca=0
  if [ -n "$ORCA_WORKTREE_ID" ] || [ -n "$ORCA_TERMINAL_HANDLE" ]; then
    _wtn_in_orca=1
  fi

  if [ "$_wtn_in_orca" = "1" ] && command -v orca >/dev/null 2>&1 && orca status --json >/dev/null 2>&1; then
    if [ "$_wtn_existing" != "1" ] && [ -n "$base" ]; then
      if ! git -C "$root" rev-parse --verify "$base" >/dev/null 2>&1; then
        echo "❌ base 브랜치/커밋을 찾을 수 없습니다: $base"
        echo "   - 오타 확인 (예: 'origint/master' → 'origin/master')"
        echo "   - 원격 최신 받기: git fetch origin"
        return 1
      fi
    fi

    local wt_output worktree_path
    local -a wt_args
    wt_args=(switch --no-cd --no-hooks)
    if [ "$_wtn_existing" != "1" ]; then
      wt_args+=(--create)
      [ -n "$base" ] && wt_args+=(--base "$base")
      if ! wt_output=$(wt "${wt_args[@]}" "$name" 2>&1); then
        echo "$wt_output" >&2
        return 1
      fi
    fi

    worktree_path=$(git -C "$root" worktree list | awk -v b="[$name]" '$3==b {print $1}')
    if [ -z "$worktree_path" ]; then
      echo "❌ worktree '$name' 경로를 찾을 수 없습니다" >&2
      [ -n "$wt_output" ] && echo "$wt_output" >&2
      return 1
    fi

    local orca_script
    orca_script=$(mktemp -t "wtn-orca-XXXXXX") || { echo "mktemp 실패"; return 1; }
    cat > "$orca_script" <<ORCA_EOF
#!/bin/zsh
set -e
trap 'rm -f "\$0"' EXIT
printf '\e]2;%s\a' '$label'

cd ${(q)worktree_path}
echo ""
echo "⏳ setup + 서버 부팅까지 수 분 걸립니다 (DB 복제 포함). 끊지 말고 기다려 주세요."
echo "   완료되면 자동으로 nvim 화면으로 전환됩니다."
echo ""
if [ '$_wtn_existing' != '1' ]; then
  echo "▶ Worktrunk setup 실행: $label"
  # --foreground: 훅은 기본이 백그라운드라 start.sh가 wt-test 세션을 만들기 전에
  # 리턴해버린다. 그러면 아래 tmux 검사가 실패한다. 블로킹시켜 순차 실행 보장.
  # -y: 비대화형 터미널에서 프로젝트 훅 승인 프롬프트로 멈추지 않도록.
  wt hook pre-start --foreground -y
else
  echo "▶ Worktrunk 서버 시작: $label"
  wt hook pre-start --foreground -y start
fi

env_file="\$PWD/.env"
if [ -f "\$env_file" ]; then
  _wt_domain="\$(grep '^WORKTRUNK_DOMAIN=' "\$env_file" | cut -d= -f2)"
fi
if [ -n "\$_wt_domain" ]; then
  actual_session="wt-\${_wt_domain%.lemonbase.test}"
else
  actual_session='$wt_session'
fi

if ! tmux has-session -t "\$actual_session" 2>/dev/null; then
  echo "❌ tmux 세션을 찾을 수 없습니다: \$actual_session"
  exit 1
fi

if ! tmux list-windows -t "\$actual_session" -F '#W' | grep -qx 'nvim'; then
  tmux new-window -t "\$actual_session" -n nvim -c "\$PWD"
  tmux send-keys -t "\$actual_session:nvim" 'NVIM_WORKTREE=1 nvim .' Enter
fi

tmux swap-window -s "\$actual_session:nvim" -t "\$actual_session:1" 2>/dev/null || true
tmux swap-window -s "\$actual_session:dev" -t "\$actual_session:2" 2>/dev/null || true
tmux select-window -t "\$actual_session:nvim" 2>/dev/null || tmux select-window -t "\$actual_session"
tmux set-option -t "\$actual_session" set-titles on
tmux set-option -t "\$actual_session" set-titles-string '$label'

echo "▶ tmux attach: \$actual_session"
if [ -n "\$TMUX" ]; then
  exec tmux switch-client -t "\$actual_session"
else
  exec tmux attach -t "\$actual_session"
fi
ORCA_EOF
    chmod +x "$orca_script"

    # wt가 새 worktree를 만든 직후엔 Orca 파일시스템 워처가 아직 등록 전이라
    # path: 셀렉터가 selector_not_found로 실패한다(등록까지 ≈1초 걸림).
    # 등록될 때까지 잠깐 대기(최대 5초) 후 진행.
    if [ "$_wtn_existing" != "1" ]; then
      local _orca_wait
      for _orca_wait in 1 2 3 4 5 6 7 8 9 10; do
        orca worktree show --worktree "path:$worktree_path" --json >/dev/null 2>&1 && break
        sleep 0.5
      done
    fi

    local orca_selector="path:$worktree_path"
    local orca_worktree_json orca_worktree_id terminal_json terminal_handle
    orca worktree set --worktree "$orca_selector" --display-name "$label" --workspace-status in-progress >/dev/null 2>&1 || true
    if orca_worktree_json=$(orca worktree show --worktree "$orca_selector" --json 2>/dev/null); then
      orca_worktree_id=$(printf '%s' "$orca_worktree_json" | jq -r '.result.worktree.id // empty' 2>/dev/null)
      [ -n "$orca_worktree_id" ] && orca_selector="id:$orca_worktree_id"
    fi

    local run_cmd="zsh ${(q)orca_script}"
    # 항상 새 터미널을 생성한다. 기존 터미널에 orca terminal send로 명령을 주입하면
    # 그 터미널이 이미 tmux/nvim에 붙어 있거나 실행 중일 때 입력이 깨진다(예: zsh→ezsh).
    # 새 터미널은 깨끗한 zsh에서 스크립트를 실행하므로 안전하다.
    if terminal_json=$(orca terminal create --worktree "$orca_selector" --title "$label" --command "$run_cmd" --focus --json 2>&1); then
      terminal_handle=$(printf '%s' "$terminal_json" | jq -r '.result.terminal.handle // .result.startupTerminal.handle // .result.handle // empty' 2>/dev/null)
      [ -n "$terminal_handle" ] && orca terminal switch --terminal "$terminal_handle" --json >/dev/null 2>&1 || true
      return
    fi

    echo "Orca worktree 터미널 생성 실패 — 현재 화면은 변경하지 않았습니다." >&2
    [ -n "$terminal_json" ] && echo "$terminal_json" >&2
    rm -f "$orca_script"
    return 1
  fi

  # 실행 스크립트를 임시 파일로 생성 → 새 탭엔 짧은 한 줄만 paste
  local script
  script=$(mktemp -t "wtn-XXXXXX") || { echo "mktemp 실패"; return 1; }

  if [ "$_wtn_existing" = "1" ]; then
    # ── ATTACH FLOW: 기존 worktree ──────────────────────────────────────────
    cat > "$script" <<ATTACH_EOF
#!/bin/zsh
printf '\e]2;%s\a' '$label'

# worktree 경로 확인
worktree_dir="\$(git -C '$root' worktree list | awk -v b='[$name]' '\$3==b {print \$1}')"
if [ -z "\$worktree_dir" ]; then
  echo "❌ worktree '$name' 경로를 찾을 수 없습니다"
  exit 1
fi

# start.sh와 동일한 로직으로 실제 tmux 세션 이름 계산
# start.sh: BRANCH_SANITIZED="\${DOMAIN%.lemonbase.test}" SESSION="wt-\${BRANCH_SANITIZED}"
env_file="\${worktree_dir}/.env"
if [ -f "\$env_file" ]; then
  _wt_domain="\$(grep '^WORKTRUNK_DOMAIN=' "\$env_file" | cut -d= -f2)"
fi
if [ -n "\$_wt_domain" ]; then
  actual_session="wt-\${_wt_domain%.lemonbase.test}"
else
  actual_session='$wt_session'
fi

if tmux has-session -t "\$actual_session" 2>/dev/null; then
  # 세션 살아있음 — nvim 윈도우가 없으면 추가, 있으면 그냥 포커스
  if ! tmux list-windows -t "\$actual_session" -F '#W' | grep -qx 'nvim'; then
    tmux new-window -t "\$actual_session" -n nvim -c "\$worktree_dir"
    tmux send-keys -t "\$actual_session:nvim" 'NVIM_WORKTREE=1 nvim .' Enter
  fi
  # window 순서 고정: 1=nvim(코드), 2=dev(서버)
  tmux swap-window -s "\$actual_session:nvim" -t "\$actual_session:1" 2>/dev/null || true
  tmux swap-window -s "\$actual_session:dev" -t "\$actual_session:2" 2>/dev/null || true
  tmux select-window -t "\$actual_session:nvim" 2>/dev/null || tmux select-window -t "\$actual_session"
else
  # 세션 없음 — .env에서 WORKTRUNK_* 읽어 start.sh 직접 호출
  # (wt switch는 인터랙티브 셸 통합 필요 → 스크립트 내 사용 불가)
  set -e
  if [ ! -f "\$env_file" ]; then
    echo "❌ \$env_file 없음 — setup이 완료되지 않은 worktree입니다"
    exit 1
  fi
  _wt_api_port="\$(grep '^WORKTRUNK_API_PORT=' "\$env_file" | cut -d= -f2)"
  _wt_fe_port="\$(grep '^WORKTRUNK_FRONTEND_PORT=' "\$env_file" | cut -d= -f2)"
  if [ -z "\$_wt_api_port" ] || [ -z "\$_wt_fe_port" ] || [ -z "\$_wt_domain" ]; then
    echo "❌ .env에 WORKTRUNK_* 값이 없습니다. setup이 완료되지 않은 worktree입니다"
    exit 1
  fi
  cd "\$worktree_dir"
  ./scripts/worktrunk/start.sh "\$_wt_api_port" "\$_wt_fe_port" "\$_wt_domain" '$_wtn_repo'
  tmux swap-pane -s "\$actual_session:dev.1" -t "\$actual_session:dev.2" 2>/dev/null || true
  tmux new-window -t "\$actual_session" -n nvim -c "\$worktree_dir"
  tmux send-keys -t "\$actual_session:nvim" 'NVIM_WORKTREE=1 nvim .' Enter
  # window 순서 고정: 1=nvim(코드), 2=dev(서버)
  tmux swap-window -s "\$actual_session:nvim" -t "\$actual_session:1" 2>/dev/null || true
  tmux swap-window -s "\$actual_session:dev" -t "\$actual_session:2" 2>/dev/null || true
  tmux select-window -t "\$actual_session:nvim"
fi

tmux set-option -t "\$actual_session" set-titles on
tmux set-option -t "\$actual_session" set-titles-string '$label'
rm -f '$script'
if [ -n "\$TMUX" ]; then
  exec tmux switch-client -t "\$actual_session"
else
  exec tmux attach -t "\$actual_session"
fi
ATTACH_EOF

  else
    # ── CREATE FLOW: 신규 worktree (기존 로직 그대로, NVIM_WORKTREE=1만 추가) ──
    # base 인자 사전 검증 — 오타로 새 탭 열고 실패하는 걸 방지
    if [ -n "$base" ]; then
      if ! git -C "$root" rev-parse --verify "$base" >/dev/null 2>&1; then
        echo "❌ base 브랜치/커밋을 찾을 수 없습니다: $base"
        echo "   - 오타 확인 (예: 'origint/master' → 'origin/master')"
        echo "   - 원격 최신 받기: git fetch origin"
        rm -f "$script"
        return 1
      fi
    fi
    local wt_cmd="wt switch --create $name"
    [ -n "$base" ] && wt_cmd="$wt_cmd --base $base"

    cat > "$script" <<CREATE_EOF
#!/bin/zsh
# paste 시 명령어 텍스트가 탭 제목에 잠시 들어가는 걸 즉시 덮어쓰기
printf '\e]2;%s\a' '$label'
set -e
cd '$root'
$wt_cmd
# wt switch가 wt-<branch> 세션 + dev 윈도우(좌 BE / 우 FE)를 만들어 둠.
# dev 윈도우 안 pane 순서 swap: FE를 왼쪽, BE를 오른쪽으로.
tmux swap-pane -s '$wt_session:dev.1' -t '$wt_session:dev.2'

# worktree 디렉터리 계산:
#   dev pane의 현재 경로가 worktree/app일 수 있으므로 git root로 정규화한다.
#   nvim cwd가 본진이나 app 폴더가 아니라 worktree root여야 한다.
fe_path="\$(tmux display-message -p -t '$wt_session:dev.1' '#{pane_current_path}' 2>/dev/null)"
worktree_path="\$(git -C "\$fe_path" rev-parse --show-toplevel 2>/dev/null)"

# 같은 세션에 nvim 윈도우 추가 — cwd는 worktree root (본진 아님!).
tmux new-window -t '$wt_session' -n nvim -c "\${worktree_path:-\$PWD}"
tmux send-keys -t '$wt_session:nvim' 'NVIM_WORKTREE=1 nvim .' Enter
# window 순서 고정: 1=nvim(코드), 2=dev(서버)
tmux swap-window -s '$wt_session:nvim' -t '$wt_session:1' 2>/dev/null || true
tmux swap-window -s '$wt_session:dev' -t '$wt_session:2' 2>/dev/null || true
tmux select-window -t '$wt_session:nvim'
# tmux가 탭 제목을 윈도우 이름(nvim/dev)으로 덮어쓰지 않도록 세션에 고정 라벨
tmux set-option -t '$wt_session' set-titles on
tmux set-option -t '$wt_session' set-titles-string '$label'
rm -f '$script'
# 이미 tmux 안(자동 attach된 main 세션)이면 nested 에러 피해서 switch-client로 전환
if [ -n "\$TMUX" ]; then
  exec tmux switch-client -t '$wt_session'
else
  exec tmux attach -t '$wt_session'
fi
CREATE_EOF
  fi

  chmod +x "$script"

  local run_cmd="zsh ${(q)script}"
  local cmux_error=""

  if ! command -v cmux >/dev/null 2>&1; then
    echo "cmux 명령어를 찾을 수 없습니다. 현재 화면은 변경하지 않았습니다." >&2
    rm -f "$script"
    return 1
  fi

  if cmux_error="$(cmux workspace create --name "$label" --cwd "$root" --command "$run_cmd" --focus false 2>&1)"; then
    return
  fi

  echo "cmux 새 작업 공간 생성 실패 — 현재 화면은 변경하지 않았습니다." >&2
  if [[ "$cmux_error" == *"only processes started inside cmux can connect"* ]]; then
    echo "현재 셸은 Cmux가 직접 시작한 terminal이 아닙니다. Cmux에서 Cmd+N으로 새 작업 공간을 만든 뒤 그 터미널에서 wtn을 실행하세요." >&2
  fi
  [ -n "$cmux_error" ] && echo "$cmux_error" >&2
  rm -f "$script"
  return 1
}

# ===== clip2img: 클립보드 이미지를 파일로 저장 (Claude Code 터미널 이미지 첨부용) =====
# 사용법: clip2img → ~/clip.png 저장 후 경로 출력
# Claude Code 프롬프트에 ~/clip.png 경로를 입력하면 이미지 첨부 가능
clip2img() {
  if ! command -v pbimg &>/dev/null; then
    echo "pbimg가 없습니다. dotfiles bootstrap.sh 를 다시 실행하세요."
    return 1
  fi
  local path
  path=$(pbimg 2>/dev/null)
  if [ $? -eq 0 ]; then
    echo "$path" | pbcopy
    echo "저장됨: $path"
    echo "경로가 클립보드에 복사됨 — 프롬프트에서 Cmd+V 로 붙여넣기하세요."
  else
    echo "클립보드에 이미지가 없습니다. 이미지를 복사한 뒤 다시 실행하세요."
    return 1
  fi
}

# Load local-only overrides (secrets, work aliases) — git-ignored
# NOTE: 아래 dotfiles 함수가 .zshrc.local 의 alias 를 덮어쓸 수 있도록 *먼저* source.
#       (예: .zshrc.local 에 `alias ldb=...` 가 있어도 dotfiles ldb 함수가 이김)
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# ===== ldb: open sqlit (lemonbase-local) in current tmux session's window :3 =====
# - tmux 안에서만 동작
# - :3 비어있으면 새로 만들고 `sqlit -c lemonbase-local` 실행
# - :3 이미 있으면 그쪽으로 select-window만 (중복 실행 X)
# NOTE: 같은 이름의 alias 가 .zshrc.local 에 있을 수 있으니 명시적으로 unalias 후 정의.
unalias ldb 2>/dev/null
ldb() {
  if [ -z "$TMUX" ]; then
    echo "tmux 세션 안에서 실행해주세요."
    return 1
  fi
  ~/.tmux/scripts/start-sqlit-window.sh
}

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi
