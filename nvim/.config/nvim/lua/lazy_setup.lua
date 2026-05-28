require("lazy").setup({
  {
    "AstroNvim/AstroNvim",
    version = "^5", -- Remove version tracking to elect for nightly AstroNvim
    import = "astronvim.plugins",
    opts = { -- AstroNvim options must be set here with the `import` key
      mapleader = " ", -- This ensures the leader key must be configured before Lazy is set up
      maplocalleader = ",", -- This ensures the localleader key must be configured before Lazy is set up
      icons_enabled = true, -- Set to false to disable icons (if no Nerd Font is available)
      -- pin_plugins=false: AstroNvim의 lazy_snapshot.lua 하드 commit pin을 비활성화한다.
      -- AstroNvim v5는 nvim-treesitter master(archived)의 옛 commit을 pin하는데,
      -- 그게 nvim 0.12에서 markdown injection 시 `node:range() on nil` 에러를 유발한다.
      -- 이 옵션을 false로 두면 lazy_snapshot이 무력화되어 각 plugin spec의 branch + lazy-lock.json만이
      -- 버전 결정자가 된다. (lock 파일에 명시된 commit이 실질 pin 역할 수행)
      pin_plugins = false,
      update_notifications = true, -- Enable/disable notification about running `:Lazy update` twice to update pinned plugins
    },
  },
  { import = "community" },
  { import = "plugins" },
} --[[@as LazySpec]], {
  -- Configure any other `lazy.nvim` configuration options here
  install = { colorscheme = { "astrotheme", "habamax" } },
  ui = { backdrop = 100 },
  performance = {
    rtp = {
      -- disable some rtp plugins, add more to your liking
      disabled_plugins = {
        "gzip",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "zipPlugin",
      },
    },
  },
} --[[@as LazyConfig]])
