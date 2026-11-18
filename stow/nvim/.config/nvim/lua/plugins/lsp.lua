return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        tailwindcss = {
          filetypes_include = { "rust" },
          init_options = {
            userLanguages = {
              rust = "html",
            },
          },
          settings = {
            tailwindCSS = {
              includeLanguages = {
                rust = "html",
              },
              experimental = {
                classRegex = {
                  [[class="([^"]*)"]],
                  [[class=\("([^"]*)"]],
                  [[class:([a-zA-Z0-9\-:]+)=]],
                },
              },
            },
          },
        },
      },
    },
  },
}
