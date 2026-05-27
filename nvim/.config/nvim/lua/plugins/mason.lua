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
      "rust-analyzer",
      "biome",
      "tree-sitter-cli",
    },
  },
}
