require("core.options")
require("core.keymaps")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	require("plugins.Neotree"),
	require("plugins.Colortheme"),
	require("plugins.Bufferline"),
	require("plugins.Lualine"),
	require("plugins.Treesitter"),
	require("plugins.Telescope"),
	require("plugins.Lsp"),
	require("plugins.Autocompletion"),
	require("plugins.Autoformatting"),
	require("plugins.Gitsigns"),
	require("plugins.Alpha"),
	require("plugins.vim-tmux-navigator"),
})
