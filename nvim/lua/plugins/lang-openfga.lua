-- OpenFGA authorization DSL (.fga): treesitter highlighting only.
-- No Neovim LSP exists yet (OpenFGA ships VS Code / IntelliJ extensions only).
-- Parser github.com/matoous/tree-sitter-fga is NOT in the official registry,
-- so we register it by hand. nvim-treesitter is pinned to the `main` branch
-- (see lazy-lock.json), which copies query files from the grammar on install.
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- 1. Map the .fga extension to an `fga` filetype.
      vim.filetype.add({ extension = { fga = "fga" } })

      -- 1b. tree-sitter-fga's highlights.scm uses `#is-not? local`, a Zed-only
      --     predicate nvim core doesn't implement (and the arg isn't even a
      --     capture, so real "is this a local var" semantics can't be honored
      --     anyway). Register a no-op handler so it always matches instead of
      --     erroring out of the whole highlighter.
      pcall(vim.treesitter.query.add_predicate, "is-not?", function()
        return true
      end, { force = true })

      -- 2. Register the out-of-tree parser + where its highlight queries live.
      --    Fired by `require('nvim-treesitter').install()` before it builds.
      vim.api.nvim_create_autocmd("User", {
        pattern = "TSUpdate",
        callback = function()
          require("nvim-treesitter.parsers").fga = {
            install_info = {
              url = "https://github.com/matoous/tree-sitter-fga",
              queries = "queries", -- copies highlights.scm + locals.scm onto runtimepath
            },
          }
        end,
      })

      -- 3. Tell LazyVim to install & keep the parser updated.
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "fga" })

      -- 4. Start treesitter highlighting when an .fga buffer opens.
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "fga",
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })
    end,
  },
}
