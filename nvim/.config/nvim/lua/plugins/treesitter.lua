-- nvim-treesitter main 브랜치 (Neovim 0.12+ 공식 권장)
--
-- master는 archive 되어 0.11 backward-compat만 유지. 0.12부터는 main 필수.
-- main은 "full, incompatible rewrite"라서 설정 패턴이 master와 다름:
--   - lazy-loading 불가 (lazy = false 강제)
--   - highlight/indent/fold가 자동 활성화 안 됨 → FileType autocmd 로 수동 enable
--   - 파서 설치는 require("nvim-treesitter").install({...}) 비동기 호출
--   - python except* 같은 query 패치는 main의 fresh query에서 이미 해소됨

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
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").setup({})

    -- 미설치 파서만 비동기 설치 (설치된 건 no-op)
    require("nvim-treesitter").install(parsers)

    -- main 브랜치는 highlight/indent를 자동 활성화하지 않음
    -- 파일 열릴 때마다 해당 언어 highlight + indent 켜기
    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        local lang = vim.treesitter.language.get_lang(args.match)
        if not lang then return end
        -- 파서가 등록되어 있을 때만 시작 (설치 전이면 조용히 패스)
        if not pcall(vim.treesitter.language.add, lang) then return end
        pcall(vim.treesitter.start, args.buf, lang)
        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
