-- Protocol Buffers: syntax, LSP (buf), and formatting (buf format).
-- LazyVim auto-installs the `buf` mason package because conform references it.
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "proto" })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        buf_ls = {},
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        proto = { "buf" },
      },
    },
  },
}
