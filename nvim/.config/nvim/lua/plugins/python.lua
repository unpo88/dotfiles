return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = { "ruff", "pyright", "debugpy" },
    },
  },
  {
    "mfussenegger/nvim-dap",
    optional = true,
    init = function()
      -- :DapDjango → 별도 pane에서 debugpy --listen 5678 로 띄운 BE에 attach
      vim.api.nvim_create_user_command("DapDjango", function()
        local dap = require("dap")
        dap.adapters.python = {
          type = "server",
          host = "127.0.0.1",
          port = 5678,
        }

        -- attach 시작 / 브포 hit 시 DAP UI (Scopes/Watches/Stack/REPL) 자동 열기
        local ok_ui, dapui = pcall(require, "dapui")
        if ok_ui then
          pcall(dapui.setup)
          dap.listeners.after.event_initialized["dapui-open"] = function() dapui.open() end
          dap.listeners.after.event_stopped["dapui-open"] = function() dapui.open() end
          dap.listeners.before.event_terminated["dapui-close"] = function() dapui.close() end
          dap.listeners.before.event_exited["dapui-close"] = function() dapui.close() end
        end

        dap.run({
          type = "python",
          request = "attach",
          name = "Django: Attach",
          django = true,
          justMyCode = false,
        })
      end, {})

      -- nvim 시작 시 manage.py 있는 디렉터리면 자동으로 attach 시도
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          if vim.fn.filereadable(vim.fn.getcwd() .. "/manage.py") == 0 then
            return
          end
          vim.defer_fn(function()
            local handle = io.popen("lsof -i :5678 -sTCP:LISTEN 2>/dev/null")
            if not handle then return end
            local out = handle:read("*a") or ""
            handle:close()
            if out == "" then return end  -- BE 안 떠있으면 skip
            pcall(function() vim.cmd("DapDjango") end)
            vim.notify("🐛 Django debugger auto-attached", vim.log.levels.INFO)
          end, 1500)
        end,
      })

      -- nvim 종료 시 같은 tmux 세션의 be-fe window도 같이 종료 (BE/FE 프로세스 함께 죽음)
      vim.api.nvim_create_autocmd("VimLeavePre", {
        callback = function()
          if vim.fn.filereadable(vim.fn.getcwd() .. "/manage.py") == 0 then
            return
          end
          os.execute("tmux kill-window -t :be-fe 2>/dev/null")
        end,
      })
    end,
  },
}
