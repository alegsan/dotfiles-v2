-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.expandtab    = false  -- Use actual tab characters (not spaces)
vim.opt.tabstop      = 4      -- Tab width
vim.opt.shiftwidth   = 4      -- Indentation width
vim.opt.softtabstop  = 4      -- Backspace behaviour with tabs
vim.opt.list         = true   -- Show invisible characters
vim.opt.listchars    = { tab = "→·", trail = "·", extends = ">", precedes = "<" }
vim.opt.colorcolumn  = "81"   -- Vertical guide at column 81
