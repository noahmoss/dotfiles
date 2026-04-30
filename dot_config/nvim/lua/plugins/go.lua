-- Go-specific helpers: :GoIfErr (insert `if err != nil`), :GoImpl (stub
-- interface methods), :GoTagAdd json, :GoFillStruct, etc. These wrap the
-- canonical Go tools (impl, gomodifytags, gotests, iferr) and aren't
-- something gopls exposes via LSP.
return {
	{
		"olexsmir/gopher.nvim",
		ft = "go",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		build = function()
			vim.cmd.GoInstallDeps()
		end,
		opts = {},
	},
}
