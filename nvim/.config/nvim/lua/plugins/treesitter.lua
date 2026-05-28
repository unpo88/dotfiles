-- nvim-treesitter main 브랜치 (Neovim 0.12+ 공식 권장)
--
-- 핵심 문제: AstroNvim v5의 plugins/treesitter.lua는 master 시대에 만들어졌고,
--   - branch = "master"
--   - main = "nvim-treesitter.configs"          ← main 브랜치에 없는 모듈
--   - event = "VeryLazy"                         ← main은 lazy 로딩 불가
--   - dependencies = { textobjects(branch 무명시) } ← master로 끌려옴
--   - config = require("astronvim.plugins.configs.nvim-treesitter")
--     └─ 그 안에서 ts.available_modules() 호출 (main에 없는 API)
-- 모든 필드를 명시적으로 override해서 AstroNvim default를 완전히 무력화한다.
--
-- 추가: lazy_setup.lua의 pin_plugins = false 와 함께 동작.
--   - pin_plugins=false → AstroNvim lazy_snapshot의 commit pin 무력화
--   - 여기 spec의 branch="main" + 모든 옛 옵션 override → :Lazy sync/update에도 원상복구 안 됨

local parsers = {
  "bash",
  "css",
  "diff",
  "gitcommit",
  "gitignore",
  "go",
  "html",
  "javascript",
  "json",
  "lua",
  "markdown",
  "markdown_inline",
  "python",
  "regex",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "yaml",
}

---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false, -- main 브랜치는 lazy-loading 미지원 (공식 요구사항)
  build = ":TSUpdate",
  main = "nvim-treesitter", -- AstroNvim의 "nvim-treesitter.configs" 강제 override (main엔 그 모듈 없음)
  dependencies = {
    -- textobjects도 main 강제 — AstroNvim default가 master(archived)로 끌어옴
    { "nvim-treesitter/nvim-treesitter-textobjects", branch = "main", lazy = true },
  },
  -- AstroNvim init이 add_to_rtp + nvim-treesitter.query_predicates require — main에서는 불필요
  init = function() end,
  -- AstroNvim opts function이 master 시대 옵션(ensure_installed, highlight, indent) 반환 — main에선 의미 없음
  opts = function() return {} end,
  config = function()
    local ts = require("nvim-treesitter")

    -- 디스크가 master 상태로 남아 있는 비상 케이스 가드 (silent)
    if type(ts.install) ~= "function" then return end

    ts.setup({})
    ts.install(parsers)

    -- main은 highlight/indent 자동 활성화 안 함 → FileType 훅으로 수동 enable
    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        local lang = vim.treesitter.language.get_lang(args.match)
        if not lang then return end
        if not pcall(vim.treesitter.language.add, lang) then return end
        pcall(vim.treesitter.start, args.buf, lang)
        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
