# dotfiles

개인 macOS 환경 설정. **GNU Stow 패키지 레이아웃**.

## 구조

각 패키지는 `$HOME` 기준 상대경로를 그대로 미러링합니다.

```
dotfiles/
├── bootstrap.sh                                          # 새 컴퓨터 셋업 자동화
├── nvim/.config/nvim/                                    → ~/.config/nvim
├── tmux/.tmux.conf                                       → ~/.tmux.conf
├── ghostty/Library/Application Support/com.mitchellh.ghostty/config
│                                                         → ~/Library/Application Support/com.mitchellh.ghostty/config
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
stow nvim tmux ghostty zsh vim
```

이후 자동으로 처리되는 것:
- **nvim**: 첫 실행 시 `lazy.nvim`이 `lazy-lock.json`의 플러그인 버전 그대로 설치, Mason이 LSP/formatter/debugger 자동 설치
- **tmux**: `prefix + I` 한 번으로 플러그인 설치
- **vim**: `:PluginInstall`로 Vundle 플러그인 설치

## bootstrap.sh가 설치하는 것

| 카테고리 | 항목 |
|---|---|
| 시스템 | Xcode CLT |
| 패키지 매니저 | Homebrew |
| 셸 | oh-my-zsh |
| CLI 도구 | stow, neovim, tmux, ripgrep, fd, lazygit, git, node |
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

## 메모

- `nvim/.config/nvim/lazy-lock.json`은 commit 대상 (플러그인 버전 고정).
- 시크릿(API key, AWS credentials 등)은 **repo에 포함하지 않음** — 위 `.zshrc.local` 패턴 활용.
- 본 repo는 MIT License로 공개. 자유롭게 fork·참고 가능.

## License

[MIT](LICENSE)
