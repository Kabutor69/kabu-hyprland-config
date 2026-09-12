return {
  {
    "RRethy/nvim-base16",
    lazy = false,
    priority = 1000,
    config = function()
      local function apply_theme()
        local ok, colors = pcall(dofile, vim.fn.stdpath("config") .. "/lua/matugen.lua")
        if not ok then
          vim.cmd("colorscheme base16-default-dark")
          return
        end

        vim.cmd("highlight clear")
        vim.g.colors_name = "matugen"

        local groups = {
          Normal = { fg = colors.foreground, bg = colors.background },
          NormalFloat = { fg = colors.foreground, bg = colors.surface },
          SignColumn = { bg = colors.background },
          CursorLine = { bg = colors.surface },
          CursorLineNr = { fg = colors.primary, bold = true },
          LineNr = { fg = colors.outline },
          Visual = { bg = colors.surface_variant },
          Search = { fg = colors.background, bg = colors.primary },
          IncSearch = { fg = colors.background, bg = colors.tertiary },
          StatusLine = { fg = colors.foreground, bg = colors.surface },
          StatusLineNC = { fg = colors.comment, bg = colors.surface },
          WinSeparator = { fg = colors.outline },
          FloatBorder = { fg = colors.primary, bg = colors.surface },
          Pmenu = { fg = colors.foreground, bg = colors.surface },
          PmenuSel = { fg = colors.background, bg = colors.primary },
          Comment = { fg = colors.comment, italic = true },
          String = { fg = colors.secondary },
          Function = { fg = colors.primary },
          Keyword = { fg = colors.tertiary },
          Type = { fg = colors.secondary },
          Constant = { fg = colors.tertiary },
          Identifier = { fg = colors.foreground },
          Statement = { fg = colors.primary },
          Error = { fg = colors.error },
          DiagnosticError = { fg = colors.error },
          DiagnosticWarn = { fg = colors.tertiary },
        }

        for group, options in pairs(groups) do
          vim.api.nvim_set_hl(0, group, options)
        end
      end

      apply_theme()

      vim.api.nvim_create_autocmd({ "FocusGained", "TermLeave" }, {
        callback = apply_theme,
      })
    end,
  },
}