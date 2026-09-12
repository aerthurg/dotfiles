return {
    "folke/snacks.nvim",
    opts = {
        picker = {
            sources = {
                explorer = {
                    layout = {
                        preset = "default",
                        preview = true,
                    },
                    jump = {
                        close = true,
                    },
                },
            },
        },
        terminal = {
            win = {
                position = "float",
                height = 0.8,
                width = 0.8,
                border = "rounded",
            },
        },
    },
}
