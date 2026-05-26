return {
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "LspAttach",
    priority = 1000,
    config = function()
      require("tiny-inline-diagnostic").setup {
        preset = "modern",
        options = {
          show_source = true,
          multilines = {
            enabled = true,
            always_show = true,
          },
          break_line = {
            enabled = true,
            after = 30,
          },
          softwrap = 15,
          show_all_diags_on_cursorline = true,
          multiple_diag_under_cursor = true,
          overflow = {
            mode = "wrap",
          },
        },
      }
      vim.diagnostic.config { virtual_text = false }
    end,
  },
}
