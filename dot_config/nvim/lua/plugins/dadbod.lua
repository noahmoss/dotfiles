return {
  {
    "tpope/vim-dadbod",
    lazy = true,
  },
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = { "tpope/vim-dadbod" },
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection" },
    config = function()
      vim.g.db_ui_save_location = vim.fn.expand("~/.config/db_ui")
      vim.g.db_ui_use_nerd_fonts = 1
    end,
  },
}
