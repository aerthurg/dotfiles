return {
    {
        "mason-org/mason.nvim",
        opts = {
            ensure_installed = {
                "stimulus-language-server",
                "html-lsp",
            },
        },
    },
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                sorbet = {
                    cmd = { "bundle", "exec", "srb", "tc", "--lsp", "--disable-watchman" },
                },
                stimulus_ls = {},
                html = {
                    filetypes = { "html", "eruby" },
                },
            },
        },
    },
}
