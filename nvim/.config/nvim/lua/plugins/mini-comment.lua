---@type LazySpec
return {
  "nvim-mini/mini.comment",
  event = "VeryLazy",
  init = function()
    local ok, wk = pcall(require, "which-key")
    if ok then
      wk.add({ { "<leader>/", desc = "Toggle Comment lines" } })
    end
  end,
  opts = {
    mappings = {
      comment = "<leader>/",
      comment_line = "<leader>/",
      comment_visual = "<leader>/",
      textobject = "<leader>/",
    },
  },
}
