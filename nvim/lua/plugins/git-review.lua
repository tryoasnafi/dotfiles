-- Rich git diff / merge / file-history views. Backend-agnostic.
--   :DiffviewOpen [rev]      review working tree or a range
--   :DiffviewFileHistory %   history of the current file
return {
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFileHistory" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview (open)" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
    },
    opts = {},
  },
}
