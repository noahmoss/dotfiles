vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Disable netrw so oil.nvim can fully take over directory buffers.
-- Must run before plugins load.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

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

-- Fuzzy-match cmdline completion (case-insensitive). Lets `:goiferr<Tab>`
-- find `:GoIfErr`.
vim.opt.wildoptions:append("fuzzy")

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

-- Keep cursor centered after big jumps and search hits.
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half-page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half-page up (centered)" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search hit (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Prev search hit (centered)" })

-- Keep cursor in place when joining lines (default jumps to the join point).
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines (keep cursor)" })

-- Move highlighted lines up/down (auto-reindented). Visual J was "join", which
-- is rarely used from a multi-line selection; visual K was a man-page lookup.
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Paste over a selection without clobbering the unnamed register.
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "[P]aste over (keep register)" })

-- Delete without yanking — useful before pasting from register.
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]], { desc = "[D]elete (no yank)" })

vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

vim.keymap.set("n", "<leader>fp", function()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  vim.notify("Copied: " .. path)
end, { desc = "[F]ile [P]ath (copy)" })

vim.keymap.set("n", "gx", function()
  local word = vim.fn.expand("<cWORD>")
  local issue = word:match("#(%d+)")
  if issue then
    local remote = vim.fn.system("git remote get-url origin 2>/dev/null"):gsub("%.git%s*$", ""):gsub("%s+$", "")
    local repo = remote:match("github%.com[:/](.+)$")
    if repo then
      vim.ui.open("https://github.com/" .. repo .. "/issues/" .. issue)
      return
    end
  end
  -- fallback: open URL under cursor
  vim.ui.open(vim.fn.expand("<cfile>"))
end, { desc = "Open URL or GitHub issue/PR (#123)" })

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
