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
      -- 타이머 폴링 방식: GUI/embed nvim(neovide, vscode-neovim 등)에서도 동작.
      -- BE가 뒤늦게 뜨더라도 자동 attach 보장 (tmux 스크립트의 pane→nvim send 경로에 의존 X)
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          if vim.fn.filereadable(vim.fn.getcwd() .. "/manage.py") == 0 then
            return
          end
          local timer_lib = vim.uv or vim.loop
          local timer = timer_lib.new_timer()
          if not timer then return end
          -- 1.5초 후 시작, 2초 간격 폴링
          timer:start(1500, 2000, vim.schedule_wrap(function()
            local ok_dap, dap = pcall(require, "dap")
            if not ok_dap then return end
            -- 이미 attach된 세션이 있으면 폴링 종료
            if dap.session() then
              timer:stop()
              if not timer:is_closing() then timer:close() end
              return
            end
            -- BE의 debugpy 5678 listen 상태 확인
            local handle = io.popen("lsof -i :5678 -sTCP:LISTEN 2>/dev/null")
            if not handle then return end
            local out = handle:read("*a") or ""
            handle:close()
            if out == "" then return end  -- 아직 BE 안 뜸, 다음 tick 재시도
            pcall(function() vim.cmd("DapDjango") end)
            vim.notify("🐛 Django debugger auto-attached", vim.log.levels.INFO)
          end))
          -- nvim 종료 시 타이머 정리
          vim.api.nvim_create_autocmd("VimLeavePre", {
            once = true,
            callback = function()
              pcall(function()
                if timer and not timer:is_closing() then
                  timer:stop()
                  timer:close()
                end
              end)
            end,
          })
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
