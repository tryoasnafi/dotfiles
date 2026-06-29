-- Optional: review GitLab merge requests without leaving Neovim.
-- Requires Go (builds a small server on install) and a token. Auth via either
-- a GITLAB_TOKEN env var or a `.gitlab.nvim` file at the repo root. See README.
--   <leader>glr  start MR review     <leader>gls  MR summary
--   <leader>glc  comment on a line   <leader>glA  approve
return {
  {
    "harrisoncramer/gitlab.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    build = function()
      require("gitlab.server").build(true)
    end,
    config = function()
      require("gitlab").setup()
    end,
    keys = {
      { "<leader>glr", function() require("gitlab").review() end, desc = "GitLab: review MR" },
      { "<leader>gls", function() require("gitlab").summary() end, desc = "GitLab: MR summary" },
      { "<leader>glA", function() require("gitlab").approve() end, desc = "GitLab: approve" },
      { "<leader>glc", function() require("gitlab").create_comment() end, desc = "GitLab: comment" },
      { "<leader>gln", function() require("gitlab").create_note() end, desc = "GitLab: note" },
    },
  },
}
