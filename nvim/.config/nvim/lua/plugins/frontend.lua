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
          root_dir = require("lspconfig.util").root_pattern("eslint.config.mjs", "eslint.config.js"),
        },
        ts_ls = {
          root_dir = require("lspconfig.util").root_pattern("tsconfig.json", "package.json"),
        },
        biome = {
          root_dir = require("lspconfig.util").root_pattern("biome.json", "biome.jsonc"),
          on_new_config = function(new_config, new_root_dir)
            local local_biome = find_local_biome(new_root_dir)
            if local_biome then new_config.cmd = { local_biome, "lsp-proxy" } end
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
