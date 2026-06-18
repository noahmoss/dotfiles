return {
	{
		"coder/claudecode.nvim",
		dependencies = {
			"folke/snacks.nvim",
		},
		keys = {
			{ "<leader>a",  "<cmd>ClaudeCode<cr>",     desc = "[A]I toggle" },
			{ "<leader>as", "<cmd>ClaudeCodeSend<cr>", desc = "[A]I [S]end", mode = { "n", "v" } },
		},
		config = true,
	},
}
