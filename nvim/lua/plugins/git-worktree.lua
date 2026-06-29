-- Switch between git worktrees from inside Neovim, including bare-repo layouts.
--   <leader>gw  list worktrees (switch / delete)
--   <leader>gW  create a worktree
return {
  {
    "polarmutex/git-worktree.nvim",
    version = "^2",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("telescope").load_extension("git_worktree")
    end,
    keys = {
      {
        "<leader>gw",
        function()
          require("telescope").extensions.git_worktree.git_worktrees()
        end,
        desc = "Worktrees (switch/delete)",
      },
      {
        "<leader>gW",
        function()
          require("telescope").extensions.git_worktree.create_git_worktree()
        end,
        desc = "Create worktree",
      },
    },
  },
}
