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

-- The quickfix/loclist above flattens each diagnostic to one truncated line
-- (e.g. a long TS union-type error gets cut off mid-type). Pop the full,
-- wrapped message in a float instead of squinting at the flattened line.
vim.diagnostic.config({
  float = { border = "rounded", source = true, max_width = 100 },
})
vim.keymap.set("n", "<leader>de", vim.diagnostic.open_float, { desc = "[D]iagnostic in float ([E]rror)" })

vim.keymap.set("n", "<leader>fp", function()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  vim.notify("Copied: " .. path)
end, { desc = "[F]ile [P]ath (copy)" })

vim.keymap.set("n", "<leader>fr", function()
  local path = vim.fn.expand("%:p")
  local base = vim.fn.expand("~/supabase/")
  local rel = path:sub(1, #base) == base and path:sub(#base + 1) or path
  vim.fn.setreg("+", rel)
  vim.notify("Copied: " .. rel)
end, { desc = "[F]ile path [R]elative to ~/supabase" })

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

vim.keymap.set("n", "<C-h>", "<cmd>TmuxNavigateLeft<cr>",  { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<cmd>TmuxNavigateRight<cr>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<cmd>TmuxNavigateDown<cr>",  { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<cmd>TmuxNavigateUp<cr>",    { desc = "Move focus to the upper window" })

-- Terminal mode window navigation: exit terminal mode first, then navigate.
-- vim-tmux-navigator's built-in tnoremap uses <C-w>: which is unreliable in
-- managed terminal windows (snacks), so we override it globally here.
vim.keymap.set("t", "<C-h>", "<C-\\><C-n><C-w>h", { desc = "Move focus to the left window" })
vim.keymap.set("t", "<C-j>", "<C-\\><C-n><C-w>j", { desc = "Move focus to the lower window" })
vim.keymap.set("t", "<C-k>", "<C-\\><C-n><C-w>k", { desc = "Move focus to the upper window" })
vim.keymap.set("t", "<C-l>", "<C-\\><C-n><C-w>l", { desc = "Move focus to the right window" })

-- vim-sexp-style structural insert: jump to the head/tail of the nearest
-- enclosing bracket pair and enter insert mode. `<I` inserts at the head,
-- `>I` at the tail. Works in any tree-sitter language (TS, Go, Lua, ...) since
-- it keys off the bracket characters rather than per-language queries.
--
-- When a delimiter sits alone on its own line (a multi-line form), inserting
-- right next to it is useless, so we instead append at the end of the last
-- content line (`>I`) or at the start of the first content line (`<I`).
-- (Pressing `<`/`>` waits out timeoutlen, as they're also indent operators.)
local sexp_open = { ["("] = true, ["["] = true, ["{"] = true }
local sexp_close = { [")"] = true, ["]"] = true, ["}"] = true }
-- Returns the opener's length if `text` is a bracketed form, else nil. Handles
-- the usual single-char brackets plus the two-char `${` of TS/JS template
-- substitutions (`${expr}`), whose closer is a plain `}`.
local function sexp_open_len(text)
  if not sexp_close[text:sub(-1)] then
    return nil
  end
  if sexp_open[text:sub(1, 1)] then
    return 1
  end
  if text:sub(1, 2) == "${" then
    return 2
  end
  return nil
end
local function sexp_insert(at_tail)
  local ok, node = pcall(vim.treesitter.get_node)
  if not ok or not node then
    return
  end
  while node do
    local text = vim.treesitter.get_node_text(node, 0)
    local open_len = sexp_open_len(text)
    if open_len then
      local sr, sc, er, ec = node:range() -- 0-indexed rows/cols; ec exclusive
      local lines = vim.api.nvim_buf_get_lines(0, sr, er + 1, false)
      local function line(br) -- buffer row (0-indexed) -> text
        return lines[br - sr + 1] or ""
      end
      if at_tail then
        -- Is the closing delimiter alone on its line (only whitespace before it)?
        if line(er):sub(1, ec - 1):match("^%s*$") then
          local br = er - 1 -- skip blank lines up to the last content line
          while br > sr and line(br):match("^%s*$") do
            br = br - 1
          end
          vim.api.nvim_win_set_cursor(0, { br + 1, 0 })
          vim.cmd("startinsert!") -- like `A`: end of the content line
        else
          vim.api.nvim_win_set_cursor(0, { er + 1, ec - 1 }) -- before closing delim
          vim.cmd.startinsert()
        end
      else
        -- Is the opening delimiter alone at the end of its line?
        if line(sr):sub(sc + open_len + 1):match("^%s*$") then
          local br = sr + 1 -- first content line below the opener
          while br < er and line(br):match("^%s*$") do
            br = br + 1
          end
          local indent = #(line(br):match("^%s*") or "")
          vim.api.nvim_win_set_cursor(0, { br + 1, indent }) -- start of content
          vim.cmd.startinsert()
        else
          vim.api.nvim_win_set_cursor(0, { sr + 1, sc + open_len }) -- just past the opener
          vim.cmd.startinsert()
        end
      end
      return
    end
    node = node:parent()
  end
end

vim.keymap.set("n", ">I", function() sexp_insert(true) end, { desc = "Insert at end of enclosing form" })
vim.keymap.set("n", "<I", function() sexp_insert(false) end, { desc = "Insert at start of enclosing form" })

-- [[ Autocommands ]]

-- Go uses tabs (gofmt/goimports enforce this). Override the global
-- expandtab default so we don't fight the formatter; display tabs 4 wide.
local go_augroup = vim.api.nvim_create_augroup("go-tabs", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
	group = go_augroup,
	pattern = "go",
	callback = function()
		vim.opt_local.expandtab = false
		vim.opt_local.tabstop = 4
		vim.opt_local.shiftwidth = 4
		vim.opt_local.softtabstop = 4
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
