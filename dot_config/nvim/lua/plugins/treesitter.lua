-- nvim-treesitter `main` branch is the actively maintained one (the legacy
-- `master` branch broke on Neovim 0.12 due to API changes). The new branch
-- doesn't accept a config table — you call `install()` directly and wire
-- highlighting/indent yourself via FileType autocmds.
return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter").install({
				"bash",
				"c",
				"clojure",
				"diff",
				"eex",
				"elixir",
				"fennel",
				"go",
				"gomod",
				"gosum",
				"gowork",
				"heex",
				"html",
				"javascript",
				"json",
				"lua",
				"luadoc",
				"markdown",
				"markdown_inline",
				"python",
				"query",
				"regex",
				"rust",
				"toml",
				"tsx",
				"typescript",
				"vim",
				"vimdoc",
				"yaml",
			})

			-- Start highlighting + indent on every buffer that has a parser available.
			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("treesitter-start", { clear = true }),
				callback = function(args)
					if not pcall(vim.treesitter.start, args.buf) then
						return
					end
					-- Fennel has a local parser-based indenter and Parinfer-safe
					-- = mappings installed by after/ftplugin/fennel.lua.
					if vim.bo[args.buf].filetype ~= "fennel" then
						vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end
				end,
			})
		end,
	},

	-- AST-aware text objects, swap, and movement. Like nvim-treesitter, this
	-- lives on the `main` branch (the only one compatible with Neovim 0.12)
	-- and is wired up by hand.
	--
	-- Note: select keys avoid `af`/`aa` etc. — mini.ai already owns those for
	-- function *calls* and arguments. These target function/class *definitions*.
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		event = "VeryLazy",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("nvim-treesitter-textobjects").setup({
				select = {
					lookahead = true,
					selection_modes = {
						["@parameter.outer"] = "v",
						["@function.outer"] = "V",
						["@class.outer"] = "V",
					},
				},
				move = { set_jumps = true },
			})

			local select = require("nvim-treesitter-textobjects.select")
			local swap = require("nvim-treesitter-textobjects.swap")
			local move = require("nvim-treesitter-textobjects.move")

			-- Select function/class definitions (visual + operator-pending).
			vim.keymap.set({ "x", "o" }, "am", function()
				select.select_textobject("@function.outer", "textobjects")
			end, { desc = "a function (method)" })
			vim.keymap.set({ "x", "o" }, "im", function()
				select.select_textobject("@function.inner", "textobjects")
			end, { desc = "inner function (method)" })
			vim.keymap.set({ "x", "o" }, "ac", function()
				select.select_textobject("@class.outer", "textobjects")
			end, { desc = "a class" })
			vim.keymap.set({ "x", "o" }, "ic", function()
				select.select_textobject("@class.inner", "textobjects")
			end, { desc = "inner class" })

			-- Swap the argument/parameter under the cursor with its sibling.
			vim.keymap.set("n", "<leader>a", function()
				swap.swap_next("@parameter.inner")
			end, { desc = "Swap [a]rg with next" })
			vim.keymap.set("n", "<leader>A", function()
				swap.swap_previous("@parameter.inner")
			end, { desc = "Swap [A]rg with prev" })

			-- Jump between functions / arguments / classes.
			vim.keymap.set({ "n", "x", "o" }, "]m", function()
				move.goto_next_start("@function.outer", "textobjects")
			end, { desc = "Next function start" })
			vim.keymap.set({ "n", "x", "o" }, "[m", function()
				move.goto_previous_start("@function.outer", "textobjects")
			end, { desc = "Prev function start" })
			vim.keymap.set({ "n", "x", "o" }, "]M", function()
				move.goto_next_end("@function.outer", "textobjects")
			end, { desc = "Next function end" })
			vim.keymap.set({ "n", "x", "o" }, "[M", function()
				move.goto_previous_end("@function.outer", "textobjects")
			end, { desc = "Prev function end" })
			vim.keymap.set({ "n", "x", "o" }, "]a", function()
				move.goto_next_start("@parameter.inner", "textobjects")
			end, { desc = "Next argument" })
			vim.keymap.set({ "n", "x", "o" }, "[a", function()
				move.goto_previous_start("@parameter.inner", "textobjects")
			end, { desc = "Prev argument" })
			vim.keymap.set({ "n", "x", "o" }, "]c", function()
				move.goto_next_start("@class.outer", "textobjects")
			end, { desc = "Next class" })
			vim.keymap.set({ "n", "x", "o" }, "[c", function()
				move.goto_previous_start("@class.outer", "textobjects")
			end, { desc = "Prev class" })
		end,
	},

	-- Split a form across lines / join it back. Uses core vim.treesitter (it
	-- dropped its nvim-treesitter dependency), so it's fine on the main branch.
	-- gS/gJ follow the splitjoin.vim convention; gS shadows nothing, gJ shadows
	-- the builtin no-space join (still reachable via visual-mode gJ).
	{
		"Wansmer/treesj",
		keys = {
			{ "gS", "<cmd>TSJSplit<cr>", desc = "Split form across lines" },
			{ "gJ", "<cmd>TSJJoin<cr>", desc = "Join form to one line" },
		},
		opts = { use_default_keymaps = false },
	},
}
