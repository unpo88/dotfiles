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
      -- worktree별 독립 debugpy 포트 규약:
      --   nvim cwd의 .env에 WORKTRUNK_API_PORT 있으면 → debugpy_port = API_PORT + 40000
      --   없으면 → 5678 (본진 lemonbase repo)
      -- 같은 규약을 tmux start-debug-session.sh도 따른다.
      local function debugpy_port_for_cwd()
        local f = io.open(vim.fn.getcwd() .. "/.env", "r")
        if not f then return 5678 end
        for line in f:lines() do
          local api = line:match("^WORKTRUNK_API_PORT=(%d+)")
          if api then
            f:close()
            return tonumber(api) + 40000
          end
        end
        f:close()
        return 5678
      end

      -- :DapDjango → 같은 디렉터리의 .env 기반으로 결정된 포트의 debugpy에 attach
      vim.api.nvim_create_user_command("DapDjango", function()
        local dap = require("dap")
        local port = debugpy_port_for_cwd()
        dap.adapters.python = {
          type = "server",
          host = "127.0.0.1",
          port = port,
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
      -- BE가 뒤늦게 뜨면 폴링하다가, debugpy 포트 listen 감지되면 :DapDjango 1회 시도 후 종료
      -- 최대 ~60초 폴링 후 포기 (다른 BE가 점유 중이거나 attach 실패해도 무한 반복 방지)
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          if vim.fn.filereadable(vim.fn.getcwd() .. "/manage.py") == 0 then
            return
          end
          local port = debugpy_port_for_cwd()
          local lsof_cmd = string.format("lsof -i :%d -sTCP:LISTEN 2>/dev/null", port)
          local timer_lib = vim.uv or vim.loop
          local timer = timer_lib.new_timer()
          if not timer then return end
          local attempts = 0
          local MAX_ATTEMPTS = 30  -- 1.5s + 30*2s ≈ 60s
          local stop_timer = function()
            if timer and not timer:is_closing() then
              timer:stop()
              timer:close()
            end
          end
          timer:start(1500, 2000, vim.schedule_wrap(function()
            attempts = attempts + 1
            if attempts > MAX_ATTEMPTS then
              stop_timer()
              return
            end
            local ok_dap, dap = pcall(require, "dap")
            if not ok_dap then return end
            if dap.session() then
              stop_timer()
              return
            end
            local handle = io.popen(lsof_cmd)
            if not handle then return end
            local out = handle:read("*a") or ""
            handle:close()
            if out == "" then return end  -- 아직 BE 안 뜸, 다음 tick 재시도
            -- debugpy 포트 listen 확인 → 1회만 attach 시도 후 timer 종료
            -- (성공이든 실패든 반복하지 않음 — "already being debugged" 같은 충돌 시
            --  에러 창이 반복적으로 뜨는 것 방지)
            stop_timer()
            pcall(function() vim.cmd("DapDjango") end)
          end))
          -- nvim 종료 시 타이머 정리
          vim.api.nvim_create_autocmd("VimLeavePre", {
            once = true,
            callback = function() pcall(stop_timer) end,
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
