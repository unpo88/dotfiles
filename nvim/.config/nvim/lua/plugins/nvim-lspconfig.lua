---@type LazySpec
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      ["*"] = {
        capabilities = {
          general = {
            positionEncodings = { "utf-16" },
          },
        },
      },
      ["null-ls"] = false,
      basedpyright = {
        settings = {
          basedpyright = {
            disableOrganizeImports = true,
            analysis = {
              autoImportCompletions = true,
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "openFilesOnly",
              inlayHints = {
                callArgumentNames = false,
              },
            },
            venvPath = "./",
            venv = ".venv",
            importFormat = "absolute",
          },
        },
      },
    },
  },
}
