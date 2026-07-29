return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = { "biome", "eslint-lsp", "typescript-language-server" },
    },
  },
  {
    "AstroNvim/astrolsp",
    ---@type AstroLSPOpts
    opts = {
      -- NOTE: ts_ls/eslint/biome 의 root_dir 오버라이드를 제거했습니다.
      -- Neovim 0.11+ 의 vim.lsp.config 는 root_dir 를 function(bufnr, on_dir) 시그니처로
      -- 호출하며 on_dir(dir) 가 불려야 서버가 시작됩니다. 기존의 lspconfig.util.root_pattern()
      -- 은 구버전 API(디렉토리를 return) 라 on_dir 를 호출하지 않아 서버가 attach 되지 않았습니다.
      -- nvim-lspconfig 의 기본 설정이 이미 새 API 로 올바르게 동작하고(biome 은 로컬
      -- node_modules/.bin/biome 자동 우선 포함) 동일한 root 탐색을 수행하므로 기본값을 사용합니다.
      autocmds = {
        biome_actions_on_save = {
          cond = function(client) return client.name == "biome" end,
          {
            event = "BufWritePre",
            desc = "Biome organizeImports + safe fixAll 을 저장 직전 동기 실행",
            callback = function(args)
              local client = vim.lsp.get_clients({ bufnr = args.buf, name = "biome" })[1]
              if not client then return end
              local encoding = client.offset_encoding or "utf-16"
              for _, action_kind in ipairs({ "source.organizeImports.biome", "source.fixAll.biome" }) do
                local params = {
                  textDocument = { uri = vim.uri_from_bufnr(args.buf) },
                  range = {
                    start = { line = 0, character = 0 },
                    ["end"] = { line = vim.api.nvim_buf_line_count(args.buf), character = 0 },
                  },
                  context = { only = { action_kind }, diagnostics = {} },
                }
                local results = vim.lsp.buf_request_sync(args.buf, "textDocument/codeAction", params, 1500) or {}
                for _, res in pairs(results) do
                  for _, action in ipairs(res.result or {}) do
                    if action.edit then vim.lsp.util.apply_workspace_edit(action.edit, encoding) end
                    if action.command then
                      local cmd = type(action.command) == "table" and action.command or action
                      if client.exec_cmd then
                        client:exec_cmd(cmd, { bufnr = args.buf })
                      else
                        vim.lsp.buf.execute_command(cmd)
                      end
                    end
                  end
                end
              end
            end,
          },
        },
      },
    },
  },
}
