---@type LazySpec
return {
  "AstroNvim/astroui",
  ---@type AstroUIOpts
  opts = {
    -- change colorscheme
    colorscheme = "astrodark",
    -- AstroUI allows you to easily modify highlight groups easily for any and all colorschemes
    highlights = {
      init = { -- this table overrides highlights in all themes
        -- 상대 줄번호 잘 보이게 (기본 #3a3e47 → 더 밝게)
        LineNr = { fg = "#7d8290" },
        LineNrAbove = { fg = "#7d8290" },
        LineNrBelow = { fg = "#7d8290" },
        -- 현재 줄은 노란 강조 (기본 #adb0bb)
        CursorLineNr = { fg = "#e0c060", bold = true },
        -- vim-illuminate: 변수 참조 하이라이트
        IlluminatedWordText  = { bg = "#313748", underline = true }, -- 일반 참조
        IlluminatedWordRead  = { bg = "#263640", underline = true }, -- 읽기 참조
        IlluminatedWordWrite = { bg = "#3a2e3e", underline = true }, -- 쓰기 참조
      },
      astrodark = { -- a table of overrides/changes when applying the astrotheme theme
        -- Normal = { bg = "#000000" },
      },
    },
    -- Icons can be configured throughout the interface
    icons = {
      -- configure the loading of the lsp in the status line
      LSPLoading1 = "⠋",
      LSPLoading2 = "⠙",
      LSPLoading3 = "⠹",
      LSPLoading4 = "⠸",
      LSPLoading5 = "⠼",
      LSPLoading6 = "⠴",
      LSPLoading7 = "⠦",
      LSPLoading8 = "⠧",
      LSPLoading9 = "⠇",
      LSPLoading10 = "⠏",
    },
  },
}
