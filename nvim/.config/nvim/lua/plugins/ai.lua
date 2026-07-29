local function get_relative_path()
  local abs = vim.fn.expand("%:p")
  if abs == "" then return nil end
  local cwd = vim.fn.getcwd()
  if abs:sub(1, #cwd + 1) == cwd .. "/" then return abs:sub(#cwd + 2) end
  return abs
end

local function focus_buf(buf)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == buf then
      vim.api.nvim_set_current_win(win)
      vim.cmd("startinsert")
      return
    end
  end
end

-- 하나의 AI 터미널(Claude, oh-my-pi 등)에 대한 열기/참조 전송 동작을 생성한다.
--   opts.name     : 알림 메시지에 쓰이는 표시 이름
--   opts.pattern  : 터미널 버퍼 이름 매칭용 Lua 패턴 (소문자 기준)
--   opts.open_cmd : :terminal 로 실행할 명령
--   opts.open_key : 터미널을 찾지 못했을 때 안내할 열기 키
local function make_agent(opts)
  local function find_buf()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.bo[buf].buftype == "terminal" then
        local name = vim.api.nvim_buf_get_name(buf)
        if name:lower():match(opts.pattern) then return buf end
      end
    end
  end

  local function send(text)
    local buf = find_buf()
    if not buf then
      vim.notify(opts.name .. " 터미널을 찾지 못했습니다. " .. opts.open_key .. " 로 먼저 여세요.", vim.log.levels.WARN)
      return
    end
    local chan = vim.b[buf].terminal_job_id
    if not chan then
      vim.notify(opts.name .. " 터미널 채널을 가져오지 못했습니다.", vim.log.levels.ERROR)
      return
    end
    vim.api.nvim_chan_send(chan, text)
    focus_buf(buf)
  end

  local function file_ref()
    local path = get_relative_path()
    if not path then
      vim.notify("현재 버퍼에 파일이 없습니다.", vim.log.levels.WARN)
      return
    end
    send("@" .. path .. " ")
  end

  local function selection_ref()
    local path = get_relative_path()
    if not path then
      vim.notify("현재 버퍼에 파일이 없습니다.", vim.log.levels.WARN)
      return
    end
    local mode = vim.fn.mode()
    local start_line, end_line
    if mode:match("[vV\22]") then
      start_line = vim.fn.line("v")
      end_line = vim.fn.line(".")
    else
      start_line = vim.fn.line("'<")
      end_line = vim.fn.line("'>")
    end
    if start_line > end_line then
      start_line, end_line = end_line, start_line
    end
    -- visual mode 명시적 종료 (선택 영역이 터미널로 텍스트로 흘러들어가는 것 방지)
    if mode:match("[vV\22]") then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
    end
    local ref = start_line == end_line
        and string.format("@%s#L%d ", path, start_line)
      or string.format("@%s#L%d-%d ", path, start_line, end_line)
    send(ref)
  end

  return {
    open = function() vim.cmd("vsplit | terminal " .. opts.open_cmd) end,
    file_ref = file_ref,
    selection_ref = selection_ref,
  }
end

local claude = make_agent({ name = "Claude", pattern = "claude", open_cmd = "claude", open_key = "<leader>ac" })
local pi = make_agent({ name = "oh-my-pi", pattern = ":omp", open_cmd = "omp", open_key = "<leader>ap" })

-- Claude 터미널 버퍼에서 Ctrl+V: 클립보드에 이미지 있으면 경로 삽입, 없으면 일반 붙여넣기
vim.api.nvim_create_autocmd("TermOpen", {
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    local name = vim.api.nvim_buf_get_name(buf)
    if not name:lower():match("claude") then return end
    vim.keymap.set("t", "<C-v>", function()
      local chan = vim.b.terminal_job_id
      if not chan then return end
      local path = vim.fn.trim(vim.fn.system("pbimg"))
      if vim.v.shell_error == 0 and path ~= "" then
        vim.api.nvim_chan_send(chan, path)
      else
        vim.api.nvim_chan_send(chan, vim.fn.getreg("+"))
      end
    end, { buffer = buf })
  end,
})

return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      suggestion = {
        auto_trigger = true,
      },
    },
  },
  {
    "AstroNvim/astrocore",
    opts = {
      mappings = {
        n = {
          ["<leader>ac"] = {
            claude.open,
            desc = "Open Claude Code",
          },
          ["<leader>af"] = {
            claude.file_ref,
            desc = "Send file reference to Claude",
          },
          ["<M-k>"] = {
            claude.file_ref,
            desc = "Send file reference to Claude (VSCode 호환)",
          },
          ["<leader>ap"] = {
            pi.open,
            desc = "Open oh-my-pi",
          },
          ["<M-p>"] = {
            pi.file_ref,
            desc = "Send file reference to oh-my-pi (VSCode 호환)",
          },
        },
        x = {
          ["<leader>af"] = {
            claude.selection_ref,
            desc = "Send selection (with line range) to Claude",
          },
          ["<M-k>"] = {
            claude.selection_ref,
            desc = "Send selection to Claude (VSCode 호환)",
          },
          ["<M-p>"] = {
            pi.selection_ref,
            desc = "Send selection to oh-my-pi (VSCode 호환)",
          },
        },
      },
    },
  },
}
