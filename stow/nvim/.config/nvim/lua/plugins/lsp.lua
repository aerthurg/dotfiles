return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        tailwindcss = {
          init_options = {
            userLanguages = {
              rust = "html",
              askama = "html",
              jinja = "html",
              jinja2 = "html",
            },
          },
          filetypes = { "html", "rust", "askama", "jinja", "jinja2" },
        },
      },
    },
  },
  {
    "mrcjkb/rustaceanvim",
    opts = {
      server = {
        default_settings = {
          ["rust-analyzer"] = {
            files = {
              excludeDirs = { ".git", ".cargo", "target" },
            },
          },
        },
      },
    },
  },
}
