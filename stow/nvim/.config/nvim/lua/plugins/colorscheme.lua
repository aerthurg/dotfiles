return {
  {
    "craftzdog/solarized-osaka.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("solarized-osaka")

      require("solarized-osaka").setup({
        transparent = true,
        terminal_colors = true,
      })
    end,
  },
}
