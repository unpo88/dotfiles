-- nvim-treesitter-textobjects: main 브랜치 강제
--
-- AstroNvim 기본 spec이 이 플러그인을 자동으로 끌어오는데, 별도 지정이 없으면 master(archived)에서 가져온다.
-- master의 plugin/nvim-treesitter-textobjects.vim 이 require("nvim-treesitter.configs")를 호출하지만
-- nvim-treesitter main에는 그 모듈이 없어서 "module 'nvim-treesitter.configs' not found" 에러 발생.
--
-- 해결: textobjects도 main 브랜치 강제 (main에는 문제의 plugin/ 디렉토리 자체가 없음).
return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  branch = "main",
}
