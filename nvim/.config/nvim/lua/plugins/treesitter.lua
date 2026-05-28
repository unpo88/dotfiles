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
    local ts = require("nvim-treesitter")

    -- main 브랜치 감지: install API 존재 여부로 판단
    -- spec에서 branch="main"으로 바꿔도 lazy가 :Lazy sync 전에는 디스크의 master 코드를 그대로 로드한다.
    -- master에는 install() 함수가 없어 호출 시 nil error → 가드해서 안전하게 처리.
    if type(ts.install) ~= "function" then
      vim.schedule(function()
        vim.notify(
          "nvim-treesitter still on master branch.\n"
            .. ":Lazy sync nvim-treesitter 실행 후 Neovim 재시작 필요.",
          vim.log.levels.WARN,
          { title = "nvim-treesitter migration" }
        )
      end)
      return
    end

    ts.setup({})
    -- 미설치 파서만 비동기 설치 (설치된 건 no-op)
    ts.install(parsers)

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
