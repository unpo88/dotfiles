local function find_local_biome(start_dir)
  local dir = start_dir
  while dir and dir ~= "" do
    local candidate = dir .. "/node_modules/.bin/biome"
    if vim.fn.executable(candidate) == 1 then return candidate end
    local parent = vim.fn.fnamemodify(dir, ":h")
    if parent == dir then break end
    dir = parent
  end
end

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
      config = {
        eslint = {
          -- nvim 0.12 vim.lsp.config는 root_dir(bufnr, on_dir) 시그니처를 요구한다.
          -- 구 lspconfig.util.root_pattern은 on_dir을 호출하지 않아 서버가 안 뜬다.
          root_dir = function(bufnr, on_dir)
            on_dir(vim.fs.root(bufnr, { "eslint.config.mjs", "eslint.config.js" }))
          end,
        },
        ts_ls = {
          root_dir = function(bufnr, on_dir)
            on_dir(vim.fs.root(bufnr, { "tsconfig.json", "package.json" }))
          end,
        },
        biome = {
          root_dir = function(bufnr, on_dir)
            on_dir(vim.fs.root(bufnr, { "biome.json", "biome.jsonc" }))
          end,
          -- on_new_config는 lspconfig 전용이라 nvim 0.12 네이티브 vim.lsp에서는 호출되지 않는다.
          -- 프로젝트 로컬 biome 바이너리 선택 로직을 cmd 함수로 이전 (config.root_dir 사용 가능).
          cmd = function(dispatchers, config)
            local bin = find_local_biome(config.root_dir) or "biome"
            return vim.lsp.rpc.start({ bin, "lsp-proxy" }, dispatchers)
          end,
        },
      },
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
