#!/usr/bin/env bash
# macOS dev environment bootstrap.
# Idempotent — safe to re-run.

set -euo pipefail

step() { printf '\n\033[1;36m═══ %s ═══\033[0m\n' "$1"; }
ok()   { printf '\033[1;32m✓\033[0m %s\n' "$1"; }

# ─── Xcode Command Line Tools ────────────────────────────────────────────
step "Xcode Command Line Tools"
if ! xcode-select -p &>/dev/null; then
  xcode-select --install || true
  echo "GUI 다이얼로그에서 설치를 완료한 뒤 이 스크립트를 다시 실행하세요."
  exit 0
fi
ok "already installed"

# ─── Homebrew ────────────────────────────────────────────────────────────
step "Homebrew"
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  ok "already installed"
fi

# ─── Brew packages ───────────────────────────────────────────────────────
step "Brew packages"
brew install \
  stow \
  neovim \
  tmux \
  ripgrep \
  fd \
  lazygit \
  git \
  gh \
  node \
  pyenv

# ─── Casks (terminal + font) ─────────────────────────────────────────────
step "Casks: Ghostty + Nerd Font"
brew install --cask ghostty || true
brew install --cask font-jetbrains-mono-nerd-font || true

# ─── oh-my-zsh ───────────────────────────────────────────────────────────
step "oh-my-zsh"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    "" --unattended
else
  ok "already installed"
fi

# ─── Python (via pyenv) ──────────────────────────────────────────────────
step "Python 3.12.11"
pyenv install -s 3.12.11

# ─── nvm + Node ──────────────────────────────────────────────────────────
step "nvm + Node 20, 22"
if [ ! -d "$HOME/.nvm" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
fi
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  # shellcheck disable=SC1091
  . "$NVM_DIR/nvm.sh"
  nvm install 20
  nvm install 22
fi

# ─── tmux Plugin Manager (TPM) ───────────────────────────────────────────
step "tmux Plugin Manager"
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
else
  ok "already installed"
fi

# ─── Vim Vundle ──────────────────────────────────────────────────────────
step "Vim Vundle"
if [ ! -d "$HOME/.vim/bundle/Vundle.vim" ]; then
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
else
  ok "already installed"
fi

# ─── pbimg (클립보드 이미지 → 파일, pngpaste 대체) ───────────────────────
step "pbimg"
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PBIMG_SRC="$DOTFILES_DIR/bin/pbimg.swift"
PBIMG_BIN="$HOME/.local/bin/pbimg"
mkdir -p "$HOME/.local/bin"
if [ ! -f "$PBIMG_BIN" ] || [ "$PBIMG_SRC" -nt "$PBIMG_BIN" ]; then
  swiftc "$PBIMG_SRC" -o "$PBIMG_BIN"
  ok "compiled → $PBIMG_BIN"
else
  ok "already up to date"
fi

# ─── gh extensions (gh-dash) ─────────────────────────────────────────────
step "gh extensions"
if command -v gh &>/dev/null && gh auth status &>/dev/null; then
  if gh extension list 2>/dev/null | grep -q dlvhdr/gh-dash; then
    ok "gh-dash already installed"
  else
    gh extension install dlvhdr/gh-dash
  fi
else
  echo "gh CLI 미인증 — 'gh auth login' 후 'gh extension install dlvhdr/gh-dash' 직접 실행하세요."
fi

# ─── Done ────────────────────────────────────────────────────────────────
step "Done"
cat <<'EOF'

다음 단계:
  1. cd ~/dotfiles && stow nvim tmux ghostty zsh vim gh-dash
  2. 새 zsh 세션 열기 (또는 exec zsh)
  3. nvim 실행 → lazy.nvim이 플러그인 + Mason 도구 자동 설치
  4. tmux 실행 → prefix + I 로 플러그인 설치
  5. (선택) vim 실행 → :PluginInstall
  6. (gh 미인증 시) gh auth login → gh extension install dlvhdr/gh-dash

EOF
