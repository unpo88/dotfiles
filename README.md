# dotfiles

개인 macOS 환경 설정 (nvim, tmux, ghostty).

## 구조

GNU Stow 패키지 레이아웃. 각 디렉토리는 `$HOME` 기준 상대경로를 그대로 미러링합니다.

```
dotfiles/
├── nvim/
│   └── .config/nvim/            → ~/.config/nvim
├── tmux/
│   └── .tmux.conf               → ~/.tmux.conf
└── ghostty/
    └── Library/Application Support/com.mitchellh.ghostty/
        └── config               → ~/Library/Application Support/com.mitchellh.ghostty/config
```

## 새 컴퓨터 셋업

```bash
# 1. 의존성
brew install stow neovim tmux
brew install --cask ghostty

# 2. 클론
git clone git@github.com:unpo88/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 3. symlink 생성
stow nvim tmux ghostty
```

이미 같은 경로에 파일이 있다면 stow가 충돌 에러를 냅니다. 백업 후 제거하고 다시 시도하세요.

```bash
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.tmux.conf ~/.tmux.conf.bak
mv "$HOME/Library/Application Support/com.mitchellh.ghostty/config" \
   "$HOME/Library/Application Support/com.mitchellh.ghostty/config.bak"
```

## 제거

```bash
cd ~/dotfiles
stow -D nvim tmux ghostty   # symlink 제거 (파일은 repo에 그대로 유지)
```

## 메모

- `nvim/.config/nvim/lazy-lock.json`은 플러그인 버전 고정용 — commit 대상.
- 외부 의존성(language servers, ripgrep, fd 등)은 별도로 설치 필요.
