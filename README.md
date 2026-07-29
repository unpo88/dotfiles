# dotfiles

개인 macOS 환경 설정. **GNU Stow 패키지 레이아웃**.

## 구조

각 패키지는 `$HOME` 기준 상대경로를 그대로 미러링합니다.

```
dotfiles/
├── bootstrap.sh                                          # 새 컴퓨터 셋업 자동화
├── nvim/.config/nvim/                                    → ~/.config/nvim
├── tmux/.tmux.conf                                       → ~/.tmux.conf
├── gh-dash/.config/gh-dash/config.yml                    → ~/.config/gh-dash/config.yml
├── ghostty/                                              # 상세는 ghostty/README.md
│   └── Library/Application Support/com.mitchellh.ghostty/
│       ├── config                                        → ~/Library/.../config
│       ├── cursor_shaders/                               # 커서 효과 GLSL
│       └── shaders/                                      # 배경/풀스크린 GLSL
├── zsh/
│   ├── .zshrc                                            → ~/.zshrc
│   └── .zprofile                                         → ~/.zprofile
└── vim/.vimrc                                            → ~/.vimrc
```

## 새 컴퓨터 셋업 (3단계)

```bash
# 1. 클론
git clone git@github.com:unpo88/dotfiles.git ~/dotfiles

# 2. 의존 도구 일괄 설치 (Homebrew, oh-my-zsh, pyenv, nvm, TPM, Vundle 등)
cd ~/dotfiles && ./bootstrap.sh

# 3. symlink 생성
stow nvim tmux ghostty zsh vim gh-dash
```

이후 자동으로 처리되는 것:
- **nvim**: 첫 실행 시 `lazy.nvim`이 `lazy-lock.json`의 플러그인 버전 그대로 설치, Mason이 LSP/formatter/debugger 자동 설치
- **tmux**: `prefix + I` 한 번으로 플러그인 설치
- **vim**: `:PluginInstall`로 Vundle 플러그인 설치
- **gh-dash**: bootstrap.sh가 `gh auth status` 통과 시 `dlvhdr/gh-dash` extension 자동 설치 (미인증 시 `gh auth login` 후 수동 설치 안내)

## bootstrap.sh가 설치하는 것

| 카테고리 | 항목 |
|---|---|
| 시스템 | Xcode CLT |
| 패키지 매니저 | Homebrew |
| 셸 | oh-my-zsh |
| CLI 도구 | stow, neovim, tmux, ripgrep, fd, lazygit, git, gh, node |
| gh extensions | dlvhdr/gh-dash (gh 인증 후 자동) |
| 언어 환경 | pyenv + Python 3.12.11, nvm + Node 20/22 |
| 터미널 | Ghostty (cask), JetBrains Mono Nerd Font |
| 플러그인 매니저 | tmux TPM, vim Vundle |

스크립트는 **idempotent** — 이미 설치된 항목은 건너뜁니다.

## stow 충돌 시

같은 경로에 파일이 이미 있으면 stow가 거부합니다. 백업 후 재시도:

```bash
mv ~/.zshrc ~/.zshrc.bak
mv ~/.tmux.conf ~/.tmux.conf.bak
# ...
cd ~/dotfiles && stow nvim tmux ghostty zsh vim
```

## 제거 (symlink 해제)

```bash
cd ~/dotfiles
stow -D nvim tmux ghostty zsh vim   # 파일은 repo에 그대로 유지
```

## 로컬 시크릿 처리 (fork 사용자 포함)

이 repo의 `zsh/.zshrc` 끝에는 다음 한 줄이 들어 있습니다:

```bash
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
```

API key, 회사용 alias, 사적인 PATH 같이 **commit하면 안 되는 것**은 `~/.zshrc.local` 에 넣으면 `.zshrc` 마지막에 자동 로드됩니다. `.gitignore`에 패턴이 등록돼 있어 실수로 push될 위험이 없습니다.

예시 (`~/.zshrc.local`):
```bash
export OPENAI_API_KEY="..."
export ANTHROPIC_API_KEY="..."
alias work-vpn="..."
```

## Claude Code 이미지 첨부 (`pbimg` + `clip2img`)

`pbimg`는 macOS 클립보드에서 이미지를 읽어 `/tmp/`에 PNG로 저장하는 자체 제작 도구입니다 (`bin/pbimg.swift`). `bootstrap.sh`에서 `swiftc`로 컴파일되어 `~/.local/bin/pbimg`에 설치됩니다.

### nvim 안에서 (권장)

`<leader>ac`로 Claude 터미널을 열면 `<C-v>`가 자동으로 이미지 인식으로 동작합니다.

```
1. 이미지 복사 (Cmd+C)
2. <leader>ac → Claude 터미널 열기
3. 프롬프트에서 Ctrl+V → /tmp/claude_img_XXX.png 경로 자동 삽입
4. 설명 입력 후 Enter
```

### 터미널에서 (nvim 없이)

```bash
# 이미지를 복사(Cmd+C)한 뒤
clip2img
# → 경로가 클립보드에 복사됨
# → Claude 프롬프트에서 Cmd+V로 붙여넣기
```

이미지는 `/tmp/`에 저장되어 재부팅 시 자동 삭제됩니다.

## Ghostty 커스터마이즈 (셰이더 등)

[`ghostty/README.md`](ghostty/README.md) 참고. 커서 트레일/배경 효과 GLSL 셰이더 카탈로그와 교체 방법이 정리돼 있습니다.

활성 셰이더 빠르게 바꾸기: `ghostty/.../config`의 `# ===== Shaders =====` 블록에서 주석 처리만 바꾸고 `Cmd+Shift+,`로 reload.

## `wtn` — worktree 원커맨드 런처 (Orca / Cmux / tmux)

브랜치별 git worktree를 만들고, 그 안에서 dev 서버(백엔드+프론트)와 nvim을
자동으로 띄우는 zsh 함수. 정의는 `zsh/.zshrc`의 `wtn()` (`# ===== wtn:` 블록).

```bash
wtn my-feature                 # 신규 worktree 생성 또는 기존 attach
wtn my-feature origin/master   # 특정 base 기준 신규 생성
```

### 동작 흐름

1. `wt`(Worktrunk)로 worktree 생성/attach
2. 실행 환경 감지:
   - **Orca 안** (`ORCA_WORKTREE_ID`/`ORCA_TERMINAL_HANDLE` 존재 + `orca` CLI) →
     Orca worktree 터미널을 새로 만들어 setup + 서버 기동
   - 그 외 → Cmux/일반 tmux 폴백
3. 프로젝트 훅(`wt hook pre-start`)이 `scripts/worktrunk/start.sh` 실행 →
   Caddy 라우트 등록 + tmux `wt-<branch>` 세션에 BE(runserver)/FE(vite) pane 기동
4. tmux에 `nvim` window 추가 (`NVIM_WORKTREE=1 nvim .`) 후 그 화면으로 전환

### 다른 맥에서 쓰려면 (dotfiles만으론 부족)

`wtn` 함수 자체는 `zsh/.zshrc`에 있어 stow하면 따라오지만, **호출하는 도구들은
이 repo 밖에 있음**. 새 맥에서 다음이 갖춰져야 동작함:

| 의존 | 어디서 오나 |
|---|---|
| `wt` (Worktrunk CLI) | 별도 설치 |
| `orca` CLI + Orca 앱 | 별도 설치 (Orca 워크플로우 쓸 때만) |
| tmux | `bootstrap.sh`가 설치 |
| Caddy | 별도 설치 (로컬 HTTPS 프록시용) |
| `scripts/worktrunk/*.sh` + 훅 설정 | **대상 프로젝트 저장소** (예: lemonbase). dotfiles 아님 — 프로젝트를 clone/pull하면 따라옴 |
| `NVIM_WORKTREE=1` 처리 | `nvim/.config/nvim/lua/polish.lua` (dotfiles ✓ — resession 자동복원 스킵) |

즉 **dotfiles clone + stow → 프로젝트 저장소 최신화 → `wt`·`orca`·Caddy 설치**
순서면 새 맥에서도 `wtn`이 동일하게 동작함.

## nvim 플러그인 노트

- **smear-cursor.nvim** — nvim 내부 커서에 부드러운 트레일. `lua/plugins/smear-cursor.lua`.
- **aerial.nvim commit pin** — nvim 0.12에서 `TSNode:start()`가 nil이 되어 v2.7.0이 깨집니다. `lua/plugins/aerial.lua`에서 v4.0.0 commit(`ac583c3`)으로 hard-pin. 이 pin은 `lazy-lock.json`보다 우선하므로 `:Lazy update`해도 v4.0.0 유지.
- **neotest** — Django 러너 + `--keepdb` 사전 설정. `lua/plugins/neotest.lua`. 키맵은 `<leader>T*` (대문자) — AstroNvim 기본 `<leader>t` 터미널 그룹과 충돌 회피. `<leader>Tr`로 커서 위치 테스트 실행, `<leader>Tf` 파일 전체, `<leader>TA` 스위트 전체. 실행 시 `DJANGO_SETTINGS_MODULE=server.settings.test` 환경변수 자동 주입.

## 메모

- `nvim/.config/nvim/lazy-lock.json`은 commit 대상이지만 로컬에서는 `git update-index --skip-worktree`로 freeze해뒀습니다. lazy.nvim이 `:Lazy update`로 working tree를 덮어써도 git에 안 보이므로, **버전을 정말로 강제해야 하는 플러그인은 plugin spec에 `commit = "..."`로 명시 pin**하세요 (aerial 예시 참고).
- skip-worktree 해제: `git update-index --no-skip-worktree nvim/.config/nvim/lazy-lock.json`
- 시크릿(API key, AWS credentials 등)은 **repo에 포함하지 않음** — 위 `.zshrc.local` 패턴 활용.
- 본 repo는 MIT License로 공개. 자유롭게 fork·참고 가능.

## License

[MIT](LICENSE)
