return {
  {
    "williamboman/mason.nvim",
    lazy = false,
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = false,
    opts = {
      auto_install = true,
    },
  },
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      vim.lsp.config('ts_ls', { capabilities = capabilities })      -- javascript, typescript, tsx
      vim.lsp.config('solargraph', { capabilities = capabilities }) -- ruby
      vim.lsp.config('html', { capabilities = capabilities })       -- html
      vim.lsp.config('lua_ls', { capabilities = capabilities })     -- lua
      vim.lsp.config('cssls', { capabilities = capabilities })      -- css
      vim.lsp.config('jsonls', { capabilities = capabilities })     -- json
      vim.lsp.config('bashls', { capabilities = capabilities })     -- bash
      vim.lsp.config('pyright', { capabilities = capabilities })    -- python
      vim.lsp.config('clangd', { capabilities = capabilities })     -- c, cpp


      vim.lsp.enable({ 'ts_ls', 'solargraph', 'html', 'lua_ls', 'cssls', 'jsonls', 'bashls', 'pyright', 'clangd' })

      vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
      vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, {})
      vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, {})
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})
    end,
  },
}
