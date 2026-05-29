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

# ===== Ghostty에서만 nvim을 tmux로 감싸기 =====
# 의도:
#   - 어떤 터미널이든 셸 자체는 plain (자동 tmux attach 안 함)
#   - 단, Ghostty에서 `nvim` 호출 시에만 tmux 'main' 세션 안에서 nvim 실행
#   - 이미 tmux 안이거나 Ghostty가 아닌 터미널(iTerm 등)에선 plain nvim
nvim() {
  if [ -n "$TMUX" ] || [[ "$TERM_PROGRAM" != "ghostty" ]]; then
    command nvim "$@"
    return
  fi
  local quoted="command nvim"
  for arg in "$@"; do
    quoted+=" $(printf '%q' "$arg")"
  done
  # Ghostty 창/탭/분할마다 독립된 ad-hoc 세션 (이름: nvim-<pid>).
  # 같은 'main' 세션에 여러 client가 attach하면 모든 client가 같은 화면을
  # 보게 되어(=tmux의 정상 동작) 분할 영역끼리 sync된 것처럼 보이는 문제 회피.
  # nvim 종료 시 그 세션도 함께 종료되어 자동 정리됨.
  tmux new-session -s "nvim-$$" "$quoted"
}

# ===== Ghostty 탭 제목 자동 갱신 =====
# 현재 git 브랜치를 탭 제목으로 표시 (워크트리별 구분).
# git repo가 아니면 cwd 디렉터리명 사용.
precmd() {
  local branch=$(git branch --show-current 2>/dev/null)
  print -Pn "\e]2;${branch:-${PWD##*/}}\a"
}

# ===== wtn: open new Ghostty tab and bootstrap a branch worktree + nvim =====
# 사용법:
#   wtn <branch-name>              신규 worktree 생성 또는 기존 worktree attach
#   wtn <branch-name> <base>       특정 base 기준 신규 생성
# 동작:
#   [신규] wt switch --create → tmux 세션 + dev(BE/FE) + nvim 윈도우 생성
#   [기존] tmux 세션 생사 감지 → 누락 윈도우만 보완하거나 start hook으로 재기동
#   결과:
#     [wt-<branch> 세션]
#     ├─ window 0 (nvim): nvim (NVIM_WORKTREE=1)   ← wtn이 추가
#     └─ window 1 (dev) : 좌 FE 로그 / 우 BE 로그  ← `wt` CLI
#     Ctrl+B + 0/1 로 전환
# 주의:
#   - 최초 실행 시 macOS가 "Ghostty가 시스템 이벤트 제어" 권한 요청 → 허용 필요
#   - clipboard 사용 (Cmd+V 시뮬레이션) → 기존 clipboard 내용은 덮어쓰여짐
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
    tmux swap-window -s "\$actual_session:dev" -t "\$actual_session:nvim" 2>/dev/null || true
  fi
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
  debugpy_port="\$(( \$_wt_api_port + 40000 ))"
  if ! lsof -i :"\$debugpy_port" -sTCP:LISTEN >/dev/null 2>&1; then
    WT_SESSION_NAME="\$actual_session" ~/.tmux/scripts/start-debug-session.sh "\$worktree_dir"
  fi
  tmux new-window -t "\$actual_session" -n nvim -c "\$worktree_dir"
  tmux send-keys -t "\$actual_session:nvim" 'NVIM_WORKTREE=1 nvim .' Enter
  tmux swap-window -s "\$actual_session:dev" -t "\$actual_session:nvim"
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
#   '$wt_session:dev'만 지정하면 swap-pane 직후 active pane(FE = worktree/app)이
#   잡혀서 nvim cwd가 본진 app 폴더가 되고, debugpy_port_for_cwd()가 .env를
#   못 찾아 5678로 fallback → BE는 WORKTRUNK_API_PORT+40000으로 listen 중이라
#   attach 실패. 그래서 dev.1 pane path를 받아 git rev-parse로 worktree 루트로
#   정규화한다 (BE/FE 어느 쪽이든 worktree 안이면 동일한 루트가 나옴).
fe_path="\$(tmux display-message -p -t '$wt_session:dev.1' '#{pane_current_path}' 2>/dev/null)"
worktree_path="\$(git -C "\$fe_path" rev-parse --show-toplevel 2>/dev/null)"

# BE를 debugpy 모드로 자동 재시작 (start-debug-session.sh의 worktrunk 분기 활용).
# tmux 외부 셸에서 호출하므로 WT_SESSION_NAME으로 대상 세션 지정.
if [ -n "\$worktree_path" ]; then
  WT_SESSION_NAME='$wt_session' ~/.tmux/scripts/start-debug-session.sh "\$worktree_path"
fi

# 같은 세션에 nvim 윈도우 추가 — cwd는 worktree (본진 아님!).
# 이게 본진 cwd로 열리면 nvim DAP가 본진 .env 기준 5678로 attach해버려서 충돌.
tmux new-window -t '$wt_session' -n nvim -c "\${worktree_path:-\$PWD}"
tmux send-keys -t '$wt_session:nvim' 'NVIM_WORKTREE=1 nvim .' Enter
# 순서 교환: nvim → 1번 (왼쪽), dev → 2번 (오른쪽)
tmux swap-window -s '$wt_session:dev' -t '$wt_session:nvim'
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

  # clipboard엔 짧은 실행 명령만
  echo -n "zsh $script" | pbcopy

  # Ghostty 활성화 + 새 탭(Cmd+T) + 붙여넣기(Cmd+V) + 엔터
  osascript <<EOF
tell application "Ghostty" to activate
delay 0.2
tell application "System Events"
  keystroke "t" using command down
  delay 0.6
  keystroke "v" using command down
  delay 0.1
  keystroke return
end tell
EOF
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
