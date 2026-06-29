-- Loaded automatically by LazyVim. LazyVim ships a large default keymap set
-- (see https://www.lazyvim.org/keymaps, or press <leader>sk in-editor).
-- Add your own maps here as you go.

-- Call hierarchy (LSP). Deeper than gr's flat references: a callable tree.
--   incoming = who calls this (callers)
--   outgoing = what this calls
vim.keymap.set("n", "<leader>ci", vim.lsp.buf.incoming_calls, { desc = "Incoming calls (callers)" })
vim.keymap.set("n", "<leader>co", vim.lsp.buf.outgoing_calls, { desc = "Outgoing calls (callees)" })
