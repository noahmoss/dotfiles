vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- [[ Options ]]

vim.opt.number = true
vim.opt.relativenumber = true

vim.g.have_nerd_font = false

vim.opt.mouse = "a"
vim.opt.showmode = false

vim.schedule(function()
	vim.opt.clipboard = "unnamedplus"
end)

vim.opt.breakindent = true
vim.opt.undofile = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

vim.opt.inccommand = "split"
vim.opt.cursorline = true

-- Indentation defaults (vim-sleuth will override for existing files)
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2

-- [[ Keymaps ]]

-- Go to start/end of line with H and L
vim.keymap.set("n", "H", "^", { desc = "Go to start of line (normal mode)" })
vim.keymap.set("n", "L", "$", { desc = "Go to end of line (normal mode)" })
vim.keymap.set("n", "^", "H", { desc = "Remap ^ to H (normal mode)" })
vim.keymap.set("n", "$", "L", { desc = "Remap $ to L (normal mode)" })

vim.keymap.set("v", "H", "^", { desc = "Go to start of line (visual mode)" })
vim.keymap.set("v", "L", "$", { desc = "Go to end of line (visual mode)" })
vim.keymap.set("v", "^", "H", { desc = "Remap ^ to H (visual mode)" })
vim.keymap.set("v", "$", "L", { desc = "Remap $ to L (visual mode)" })

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- [[ Autocommands ]]

local go_augroup = vim.api.nvim_create_augroup("go-spaces", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
	group = go_augroup,
	pattern = "go",
	callback = function()
		vim.opt_local.expandtab = true
		vim.opt_local.tabstop = 4
		vim.opt_local.shiftwidth = 4
		vim.opt_local.softtabstop = 4
		vim.cmd("%retab!")
	end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
	group = go_augroup,
	pattern = "*.go",
	callback = function()
		vim.cmd("%retab!")
	end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- [[ Plugin manager ]]

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	{ import = "plugins" },
}, {
	ui = {
		icons = vim.g.have_nerd_font and {} or {
			cmd = "⌘",
			config = "🛠",
			event = "📅",
			ft = "📂",
			init = "⚙",
			keys = "🗝",
			plugin = "🔌",
			runtime = "💻",
			require = "🌙",
			source = "📄",
			start = "🚀",
			task = "📌",
			lazy = "💤 ",
		},
	},
})

-- vim: ts=2 sts=2 sw=2 et
