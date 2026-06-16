return {
	-- Live browser preview of the current markdown buffer. GitHub-styled, with
	-- mermaid/math support and scroll-sync. Toggle with <leader>mp.
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
		ft = { "markdown" },
		-- Builds the bundled web client. Loads the plugin first so the install
		-- helper is on the runtimepath.
		build = function()
			require("lazy").load({ plugins = { "markdown-preview.nvim" } })
			vim.fn["mkdp#util#install"]()
		end,
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
			-- Don't auto-close the browser tab when switching away from the buffer.
			vim.g.mkdp_auto_close = 0
		end,
		keys = {
			{
				"<leader>mp",
				ft = "markdown",
				"<cmd>MarkdownPreviewToggle<cr>",
				desc = "[M]arkdown [P]review (browser)",
			},
		},
	},
}
