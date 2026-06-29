-- Bootstrap lazy.nvim, then load LazyVim + language extras, then our own
-- overrides under lua/plugins/.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    -- LazyVim core
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },

    -- Language extras (each wires LSP + treesitter + formatter + linter)
    { import = "lazyvim.plugins.extras.lang.go" },         -- gopls, gofumpt, goimports, delve, neotest-golang
    { import = "lazyvim.plugins.extras.lang.typescript" }, -- vtsls, eslint, prettier
    { import = "lazyvim.plugins.extras.lang.terraform" },  -- terraform-ls
    { import = "lazyvim.plugins.extras.lang.json" },
    { import = "lazyvim.plugins.extras.lang.yaml" },
    { import = "lazyvim.plugins.extras.lang.docker" },
    { import = "lazyvim.plugins.extras.lang.markdown" },
    { import = "lazyvim.plugins.extras.lang.sql" },

    -- Testing + debugging
    { import = "lazyvim.plugins.extras.test.core" }, -- neotest: <leader>t* run/watch/debug tests
    { import = "lazyvim.plugins.extras.dap.core" },  -- nvim-dap: breakpoints, stepping

    -- Editor: prefer Telescope as the fuzzy finder
    { import = "lazyvim.plugins.extras.editor.telescope" },
    { import = "lazyvim.plugins.extras.util.mini-hipatterns" },

    -- Our overrides (proto, graphql, git worktrees, gitlab MRs, colorscheme)
    { import = "plugins" },
  },
  defaults = { lazy = false, version = false },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = { enabled = true, notify = false }, -- check for plugin updates, no popup
  performance = {
    rtp = {
      disabled_plugins = { "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin" },
    },
  },
})
