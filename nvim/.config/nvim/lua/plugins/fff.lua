---@type LazySpec
return {
  "dmtrKovalenko/fff.nvim",
  build = function()
    require("fff.download").download_or_build_binary()
  end,
  lazy = false,
  opts = {
    layout = {
      prompt_position = "top",
    },
  },
  keys = {
    {
      "<leader><leader>",
      function() require("fff").find_files() end,
      desc = "Open file picker",
    },
    {
      "<leader>sg",
      function() require("fff").live_grep() end,
      desc = "LiFFFe grep",
    },
    {
      "<leader>sz",
      function()
        require("fff").live_grep({
          grep = { modes = { "fuzzy", "plain" } },
        })
      end,
      desc = "Live fffuzy grep",
    },
    {
      "<leader>sc",
      function()
        require("fff").live_grep({ query = vim.fn.expand("<cword>") })
      end,
      desc = "Search current word",
    },
  },
}
