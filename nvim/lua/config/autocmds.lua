-- Loaded automatically by LazyVim. Add personal autocommands here.
local augroup = vim.api.nvim_create_augroup("user_autocmds", { clear = true })

-- Briefly highlight text on yank.
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  callback = function()
    vim.highlight.on_yank({ timeout = 150 })
  end,
})
