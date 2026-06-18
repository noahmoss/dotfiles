return {
	{
		"coder/claudecode.nvim",
		dependencies = {
			"folke/snacks.nvim",
		},
		opts = {
			snacks_win_opts = {
				keys = {
					nav_left  = { "<C-h>", function() vim.cmd("TmuxNavigateLeft")  end, mode = "t", desc = "Navigate left" },
					nav_down  = { "<C-j>", function() vim.cmd("TmuxNavigateDown")  end, mode = "t", desc = "Navigate down" },
					nav_up    = { "<C-k>", function() vim.cmd("TmuxNavigateUp")    end, mode = "t", desc = "Navigate up" },
					nav_right = { "<C-l>", function() vim.cmd("TmuxNavigateRight") end, mode = "t", desc = "Navigate right" },
				},
			},
		},
	},
}
