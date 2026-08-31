return {
  "goolord/alpha-nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")
    local icons = require("nvim-web-devicons")

    -- Header
    dashboard.section.header.val = {
      [[                                                                       ]],
      [[                                                                       ]],
      [[                                                                       ]],
      [[                                                                       ]],
      [[                                                                     ]],
      [[       ████ ██████           █████      ██                     ]],
      [[      ███████████             █████                             ]],
      [[      █████████ ███████████████████ ███   ███████████   ]],
      [[     █████████  ███    █████████████ █████ ██████████████   ]],
      [[    █████████ ██████████ █████████ █████ █████ ████ █████   ]],
      [[  ███████████ ███    ███ █████████ █████ █████ ████ █████  ]],
      [[ ██████  █████████████████████ ████ █████ █████ ████ ██████ ]],
      [[                                                                       ]],
      [[                                                                       ]],
      [[                                                                       ]],
    }

    -- Buttons
    dashboard.section.buttons.val = {
      dashboard.button("e", "  New File",           ":ene <BAR> startinsert <CR>"),
      dashboard.button("f", "  Find File",          ":Telescope find_files<CR>"),
      dashboard.button("r", "  Recent Files",       ":Telescope oldfiles<CR>"),
      dashboard.button("s", "  Restore Session", [[<cmd>lua require("persistence").load()<cr>]]),
      dashboard.button("l", "  Lazy",               ":Lazy<CR>"),
      dashboard.button("q", "  Quit",               ":qa<CR>"),
    }

    -- Footer
    local function footer()
      local total_plugins = require("lazy").stats().count
      local version = vim.version()
      return string.format(
        "  v%d.%d.%d   %d plugins loaded",
        version.major, version.minor, version.patch,
        total_plugins
      )
    end

    dashboard.section.footer.val = footer()
    dashboard.section.footer.opts.hl = "Comment"

    -- Highlight groups
    dashboard.section.header.opts.hl  = "Include"
    dashboard.section.buttons.opts.hl = "Keyword"

    -- Layout padding
    dashboard.opts.layout = {
      { type = "padding", val = 2 },
      dashboard.section.header,
      { type = "padding", val = 2 },
      dashboard.section.buttons,
      { type = "padding", val = 1 },
      dashboard.section.footer,
    }

    -- Disable statusline/tabline on alpha buffer
    vim.api.nvim_create_autocmd("User", {
      pattern = "AlphaReady",
      callback = function()
        vim.opt.laststatus = 0
        vim.opt.showtabline = 0
      end,
    })

    vim.api.nvim_create_autocmd("BufUnload", {
      buffer = 0,
      callback = function()
        vim.opt.laststatus = 3
        vim.opt.showtabline = 2
      end,
    })

    alpha.setup(dashboard.opts)
  end,
}
