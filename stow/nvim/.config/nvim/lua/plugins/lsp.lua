return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        html = {},
        htmx = {
          filetypes = { "html", "htmldjango", "jinja" },
        },
        tailwindcss = {
          filetypes_include = { "htmldjango", "jinja" },
          init_options = {
            userLanguages = {
              htmldjango = "html",
              jinja = "html",
            },
          },
          settings = {
            tailwindCSS = {
              includeLanguages = {
                htmldjango = "html",
                jinja = "html",
              },
              experimental = {
                -- Autocomplete do Tailwind em classes dinâmicas do Alpine.js
                -- Ex: :class="open ? 'bg-blue-500' : 'bg-gray-200'" ou x-bind:class="{ 'hidden': !open }"
                classRegex = {
                  { [[(?:x-bind)?:class\s*=\s*"([^"]*)"]], [['([^']*)']] },
                },
              },
            },
          },
        },
      },
    },
  },
}
