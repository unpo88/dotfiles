-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- yank → macOS 시스템 클립보드 (tmux의 set-clipboard on과 함께 OSC52로 Ghostty까지 전달)
vim.opt.clipboard = "unnamedplus"

-- wtn으로 열린 nvim은 resession dirsession 자동 복원 스킵.
-- AstroNvim이 VimEnter에서 resession.load(..., { dir = "dirsession" }) 를 호출하므로
-- 해당 호출만 무시하도록 load를 monkey-patch한다.
if vim.env.NVIM_WORKTREE == "1" then
  local ok, resession = pcall(require, "resession")
  if ok then
    local orig_load = resession.load
    resession.load = function(name, opts)
      if type(opts) == "table" and opts.dir == "dirsession" then return end
      return orig_load(name, opts)
    end
  end
end
