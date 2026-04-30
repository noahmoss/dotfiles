return {
	"tpope/vim-sleuth",
	"tpope/vim-surround",
	"mbbill/undotree",

	{
		"stevearc/oil.nvim",
		dependencies = { { "echasnovski/mini.icons", opts = {} } },
		-- `-` opens the parent directory in Oil (the Vinegar-style default).
		-- `<leader>e` opens Oil in the cwd, useful for "explore from project root".
		keys = {
			{ "-", "<cmd>Oil<CR>", desc = "Open parent directory" },
			{ "<leader>e", function() require("oil").open(vim.fn.getcwd()) end, desc = "[E]xplore (cwd)" },
		},
		config = function()
			require("oil").setup({
				view_options = {
					show_hidden = true,
				},
			})
		end,
	},

	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
	},

	{
		"numToStr/Comment.nvim",
		lazy = false,
		dependencies = {
			"JoosepAlviste/nvim-ts-context-commentstring",
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			require("Comment").setup({
				pre_hook = function()
					return vim.bo.commentstring
				end,
			})
		end,
	},

	{
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	},

	{
		"echasnovski/mini.nvim",
		config = function()
			require("mini.ai").setup({
				n_lines = 500,
				custom_textobjects = {
					["("] = false,
					[")"] = false,
				},
			})

			local statusline = require("mini.statusline")
			statusline.setup({ use_icons = vim.g.have_nerd_font })

			---@diagnostic disable-next-line: duplicate-set-field
			statusline.section_location = function()
				return "%2l:%-2v"
			end
		end,
	},
}
