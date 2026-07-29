local function get_relative_path()
  local abs = vim.fn.expand("%:p")
  if abs == "" then return nil end
  local cwd = vim.fn.getcwd()
  if abs:sub(1, #cwd + 1) == cwd .. "/" then return abs:sub(#cwd + 2) end
  return abs
end

local function find_claude_buf()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buftype == "terminal" then
      local name = vim.api.nvim_buf_get_name(buf)
      if name:lower():match("claude") then return buf end
    end
  end
end

local function find_omp_buf()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buftype == "terminal" then
      local name = vim.api.nvim_buf_get_name(buf)
      -- term:// 이름은 실행 명령으로 끝남 → 경로에 우연히 "omp"가 있어도 오탐하지 않도록 끝에서 매칭
      if name:lower():match("[%s:]omp%s*$") then return buf end
    end
  end
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

local function send_to_claude(text)
  local buf = find_claude_buf()
  if not buf then
    vim.notify("Claude 터미널을 찾지 못했습니다. <leader>ac 로 먼저 여세요.", vim.log.levels.WARN)
    return
  end
  local chan = vim.b[buf].terminal_job_id
  if not chan then
    vim.notify("Claude 터미널 채널을 가져오지 못했습니다.", vim.log.levels.ERROR)
    return
  end
  vim.api.nvim_chan_send(chan, text)
  focus_buf(buf)
end

local function send_to_omp(text)
  local buf = find_omp_buf()
  if not buf then
    vim.notify("OMP 터미널을 찾지 못했습니다. <leader>ap 로 먼저 여세요.", vim.log.levels.WARN)
    return
  end
  local chan = vim.b[buf].terminal_job_id
  if not chan then
    vim.notify("OMP 터미널 채널을 가져오지 못했습니다.", vim.log.levels.ERROR)
    return
  end
  vim.api.nvim_chan_send(chan, text)
  focus_buf(buf)
end

local function send_file_ref(send)
  local path = get_relative_path()
  if not path then
    vim.notify("현재 버퍼에 파일이 없습니다.", vim.log.levels.WARN)
    return
  end
  send("@" .. path .. " ")
end

local function send_selection_ref(send)
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
  -- visual mode 명시적 종료 (선택 영역이 Claude 로 텍스트로 흘러들어가는 것 방지)
  if mode:match("[vV\22]") then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
  end
  local ref = start_line == end_line
      and string.format("@%s#L%d ", path, start_line)
    or string.format("@%s#L%d-%d ", path, start_line, end_line)
  send(ref)
end

-- Claude 터미널 버퍼에서 Ctrl+V: 클립보드에 이미지 있으면 경로 삽입, 없으면 일반 붙여넣기
vim.api.nvim_create_autocmd("TermOpen", {
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    local name = vim.api.nvim_buf_get_name(buf)
    if not name:lower():match("claude") then return end
    vim.keymap.set("t", "<C-v>", function()
      local pbimg_bin = vim.fn.expand("~/.local/bin/pbimg")
      local path = vim.fn.trim(vim.fn.system(pbimg_bin))
      local shell_error = vim.v.shell_error
      vim.schedule(function()
        if shell_error == 0 and path ~= "" then
          send_to_claude(path)
        else
          local text = vim.fn.getreg("+")
          if text ~= "" then send_to_claude(text) end
        end
      end)
    end, { buffer = buf, noremap = true })
  end,
})

-- OMP 터미널 버퍼에서 Option+Enter: OMP 의 Alt+Enter(follow-up queue) CSI-u 시퀀스 전달
vim.api.nvim_create_autocmd("TermOpen", {
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    local name = vim.api.nvim_buf_get_name(buf)
    if not name:lower():match("[%s:]omp%s*$") then return end

    local function send_omp_alt_enter()
      local chan = vim.b[buf].terminal_job_id
      if chan then vim.api.nvim_chan_send(chan, "\27[13;3u") end
    end

    vim.keymap.set("t", "<M-CR>", send_omp_alt_enter, { buffer = buf, noremap = true, silent = true })
    vim.keymap.set("t", "<A-CR>", send_omp_alt_enter, { buffer = buf, noremap = true, silent = true })
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
            function() vim.cmd("vsplit | terminal claude") end,
            desc = "Open Claude Code",
          },
          ["<leader>ap"] = {
            function() vim.cmd("vsplit | terminal omp") end,
            desc = "Open OMP",
          },
          ["<leader>af"] = {
            function() send_file_ref(send_to_claude) end,
            desc = "Send file reference to Claude",
          },
          ["<M-k>"] = {
            function() send_file_ref(send_to_claude) end,
            desc = "Send file reference to Claude (VSCode 호환)",
          },
          ["<M-p>"] = {
            function() send_file_ref(send_to_omp) end,
            desc = "Send file reference to OMP",
          },
        },
        x = {
          ["<leader>af"] = {
            function() send_selection_ref(send_to_claude) end,
            desc = "Send selection (with line range) to Claude",
          },
          ["<M-k>"] = {
            function() send_selection_ref(send_to_claude) end,
            desc = "Send selection to Claude (VSCode 호환)",
          },
          ["<M-p>"] = {
            function() send_selection_ref(send_to_omp) end,
            desc = "Send selection to OMP",
          },
        },
      },
    },
  },
}
