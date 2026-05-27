---@type LazySpec
return {
  "mizisu/django.nvim",
  dependencies = {
    { "folke/snacks.nvim" },
    {
      "saghen/blink.cmp",
      opts = {
        sources = {
          default = { "django" },
          providers = {
            django = {
              name = "django",
              module = "django.completions.blink",
              async = true,
            },
          },
        },
      },
    },
  },
  opts = {
    shell = {
      command = "shell",
      split = {
        position = "right",
        size = 0.3,
      },
      env = {},
      env_file = ".env",
    },
  },
  config = function(_, opts)
    require("django").setup(opts)
  end,
}
