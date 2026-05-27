---@type LazySpec
return {
  "sindrets/diffview.nvim",
  keys = {
    {
      "<leader>gD",
      function()
        local git_utils = require("utils.git")
        if not git_utils.is_git_repo() then
          vim.cmd("DiffviewOpen")
          return
        end
        local base_ref = git_utils.get_base_ref()
        if base_ref then
          vim.cmd("DiffviewOpen origin/" .. base_ref .. "...HEAD")
        else
          vim.cmd("DiffviewOpen")
        end
      end,
      desc = "Diffview Open with base",
    },
    { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview Open" },
    { "<leader>gc", "<cmd>DiffviewClose<cr>", desc = "Diffview Close" },
    { "<leader>gF", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview File History" },
  },
}
