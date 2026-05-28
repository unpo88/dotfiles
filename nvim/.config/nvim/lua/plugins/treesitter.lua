-- nvim-treesitter
--
-- AstroNvim v6 default가 다음을 자동 처리하므로 추가 override 불필요:
--   - branch = "main" (Neovim 0.12+)
--   - lazy_snapshot.lua에서 nvim 버전 감지 → main HEAD commit 자동 pin
--   - opts = {} (깨끗한 v6 default)
--
-- 이 파일은 user-specific 확장만 담는다. 현재는 ensure_installed로 파서 목록만 추가.
return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "bash",
      "css",
      "diff",
      "gitcommit",
      "gitignore",
      "go",
      "html",
      "javascript",
      "json",
      "lua",
      "markdown",
      "markdown_inline",
      "python",
      "regex",
      "toml",
      "tsx",
      "typescript",
      "vim",
      "vimdoc",
      "yaml",
    },
  },
}
