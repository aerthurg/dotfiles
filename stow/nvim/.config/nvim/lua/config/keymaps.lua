-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Lazydocker keymap
vim.keymap.set("n", "<leader>kd", function()
    LazyVim.terminal.open({ "lazydocker" }, {
        cwd = LazyVim.root(),
        esc_esc = false,
        ctrl_hjkl = false,
    })
end, { desc = "LazyDocker (Root Dir)" })

-- File explorer and finder keymap
vim.keymap.set("n", "<leader>ff", function()
    Snacks.picker.explorer()
end, { desc = "Explorer (Snacks)" })

-- Disabled keymaps
vim.keymap.set("n", "<leader>e", "<nop>", { desc = "Disabled" })
vim.keymap.set("n", "<leader><space>", "<nop>", { desc = "Disabled" })
