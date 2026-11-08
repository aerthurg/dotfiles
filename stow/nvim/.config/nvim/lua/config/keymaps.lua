-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Window navigation that does not collide with Zellij's Ctrl-based keybinds
vim.keymap.set("n", "<leader>wh", "<C-w>h", { desc = "Go to Left Window" })
vim.keymap.set("n", "<leader>wl", "<C-w>l", { desc = "Go to Right Window" })
