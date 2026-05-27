---@type LazySpec
return {
  "mfussenegger/nvim-dap-python",
  -- stylua: ignore
  keys = {
    {
      "<leader>dPt",
      function() require("dap-python").test_method() end,
      desc = "Debug Method",
      ft = "python",
    },
    {
      "<leader>dPc",
      function() require("dap-python").test_class() end,
      desc = "Debug Class",
      ft = "python",
    },
    {
      "<leader>dn",
      function() require("dap").step_over() end,
      desc = "Step Over",
    },
  },

  config = function()
    require("dap-python").setup("uv")
    table.insert(require("dap").configurations.python, 1, {
      type = "python",
      request = "launch",
      name = "django",
      program = "${workspaceFolder}/manage.py",
      args = {
        "runserver",
        "7777",
        "--settings=server.settings.local",
        "--noreload",
        "--skip-checks",
      },
      console = "integratedTerminal",
    })
  end,
}
