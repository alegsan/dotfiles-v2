-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Register <leader>a group label for which-key
require("which-key").add({
  { "<leader>a", group = "AI", icon = "🤖" },
})
