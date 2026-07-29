---@type LazySpec
return {
  "mason-org/mason.nvim",
  opts = {
    ensure_installed = {
      "lua-language-server",
      "stylua",
      "debugpy",
      "mypy",
      "ruff",
      "basedpyright",
      "ty", -- auto-import 보완용 (보완: basedpyright가 메인 LSP, ty는 completion만)
      "rust-analyzer",
      "biome",
      "tree-sitter-cli",
    },
  },
}
