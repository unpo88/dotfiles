-- nvim-treesitter-textobjects: main 브랜치 강제 + AstroNvim default 무력화
--
-- 같은 이유 (nvim-treesitter master archive). textobjects의 master HEAD plugin/*.vim 이
-- require("nvim-treesitter.configs") 호출해서 startup 즉시 깨짐.
-- main 브랜치에는 plugin/ 디렉토리 자체가 없어서 그 트리거 자체가 사라진다.
return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  branch = "main",
  lazy = true,
  -- AstroNvim/다른 spec이 우리 spec과 merge되어도 main 브랜치 동작이 유지되도록 모든 옛 옵션 비움
  init = function() end,
  opts = function() return {} end,
  config = function() end,
}
