---@diagnostic disable: missing-fields
return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-neotest/neotest-python",
      "nvim-neotest/neotest-plenary",
    },
    keys = {
      {
        "<leader>Tr",
        function()
          require("neotest").run.run()
        end,
        desc = "Run the nearest test",
      },
      {
        "<leader>Td",
        function()
          require("neotest").run.run({
            strategy = "dap",
          })
        end,
        desc = "Debug the nearest test",
      },
      {
        "<leader>Tf",
        function()
          require("neotest").run.run(vim.fn.expand("%"))
        end,
        desc = "Run the current file",
      },
      {
        "<leader>TA",
        function()
          require("neotest").run.run({
            suite = true,
          })
        end,
        desc = "Run all tests",
      },
      {
        "<leader>Ta",
        function()
          require("neotest").run.attach()
        end,
        desc = "Attach to the nearest test",
      },
      {
        "<leader>Tu",
        function()
          require("neotest").run.stop()
        end,
        desc = "Stop the test",
      },
      {
        "<leader>To",
        function()
          require("neotest").output.open({ enter = true })
        end,
        desc = "Show test ouput",
      },
      {
        "<leader>Tp",
        function()
          require("neotest").output_panel.toggle()
        end,
        desc = "Toggle test output panel",
      },

      {
        "<leader>Ts",
        function()
          require("neotest").summary.toggle()
        end,
        desc = "Show test summary",
      },
    },
    config = function()
      require("neotest").setup({
        run = {
          augment = function(tree, args)
            args.env = args.env or {}
            args.env.DJANGO_SETTINGS_MODULE = "server.settings.test"
            args.env.DEBUG = "True"

            if type(args[1]) == "string" and not args[1]:find("%.py") then
              -- 출력을 단순하게 만들기 위해
              -- 특정 파일이 아니라 전체 실행의 경우에는 VIEW_TRACEBACK을 False로 실행
              args.env.VIEW_TRACEBACK = "False"
            end

            return args
          end,
        },
        adapters = {
          require("neotest-python")({
            dap = {
              justMyCode = false,
            },
            runner = "django",
            args = {
              "--keepdb", -- 테스트 데이터베이스 재사용
            },
          }),
          require("neotest-plenary"),
        },
        output = {
          open_on_run = true,
          enter = true,
          -- open_win = function()
          --     vim.cmd("vsplit")
          --     vim.opt_local.wrap = false
          --     return vim.api.nvim_get_current_win()
          -- end,
        },
        floating = {
          max_height = 0.8,
          max_width = 0.8,
        },
        output_panel = {
          open = "botright split | resize 20 | setlocal nowrap",
        },
      })
    end,
  },
}
