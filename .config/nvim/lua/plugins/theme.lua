return {
  {
    "RRethy/nvim-base16",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd("colorscheme base16-default-dark")

      vim.api.nvim_create_autocmd({ "FocusGained", "TermLeave" }, {
        callback = function()
          vim.cmd("colorscheme base16-default-dark")
        end,
      })
    end,
  },
}