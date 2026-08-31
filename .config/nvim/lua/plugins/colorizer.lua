return {
  "NvChad/nvim-colorizer.lua",
  event = "BufReadPre",
  config = function()
    require("colorizer").setup({
      filetypes = { "*" },
      user_default_options = {
        RGB = true,        -- rgb(255, 0, 0)
        RRGGBB = true,     -- #ff0000
        names = true,      -- "red"
        RRGGBBAA = true,   -- #ff0000aa
        AARRGGBB = true,   -- 0xff0000aa
        rgb_fn = true,     -- rgb() functions
        hsl_fn = true,     -- hsl() functions
        css = true,        -- enable all CSS features
        css_fn = true,     -- rgba(), hsla()
        mode = "background", -- or "foreground"
      },
    })
  end,
}
