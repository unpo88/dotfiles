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
| CLI 도구 | stow, neovim, tmux, ripgrep, fd, lazygit, git, gh, node, pngpaste |
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

## Claude Code 터미널 이미지 첨부 (`clip2img`)

터미널에서 Claude Code를 사용할 때 클립보드 이미지를 첨부하는 방법.

```bash
# 이미지를 복사(Cmd+C)한 뒤
clip2img

# 출력:
# 저장됨: ~/clip.png
# Claude 프롬프트에 다음 경로를 입력하세요: ~/clip.png
```

저장 경로를 바꾸고 싶으면 인자로 지정:
```bash
clip2img ~/screenshots/my-image.png
```

`bootstrap.sh`에서 `pngpaste`(macOS 클립보드 → 파일 변환 도구)가 자동 설치되며, `clip2img` 함수는 `.zshrc`에 정의되어 있습니다.

## Ghostty 커스터마이즈 (셰이더 등)

[`ghostty/README.md`](ghostty/README.md) 참고. 커서 트레일/배경 효과 GLSL 셰이더 카탈로그와 교체 방법이 정리돼 있습니다.

활성 셰이더 빠르게 바꾸기: `ghostty/.../config`의 `# ===== Shaders =====` 블록에서 주석 처리만 바꾸고 `Cmd+Shift+,`로 reload.

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
