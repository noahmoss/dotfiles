return {
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>f",
				function()
					require("conform").format({ async = true, lsp_format = "fallback" })
				end,
				mode = "",
				desc = "[F]ormat buffer",
			},
		},
		opts = {
			notify_on_error = false,
			format_on_save = {
				timeout_ms = 500,
				lsp_format = "fallback",
			},
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
				javascript = { "oxfmt", "prettierd", "prettier", stop_after_first = true },
				typescript = { "oxfmt", "prettierd", "prettier", stop_after_first = true },
				javascriptreact = { "oxfmt", "prettierd", "prettier", stop_after_first = true },
				typescriptreact = { "oxfmt", "prettierd", "prettier", stop_after_first = true },
				json = { "oxfmt", "prettierd", "prettier", stop_after_first = true },
				yaml = { "prettierd", "prettier", stop_after_first = true },
				markdown = { "prettierd", "prettier", stop_after_first = true },
				go = { "goimports", "gofmt" },
				c = { "clang_format" },
				cpp = { "clang_format" },
			},
		},
	},
}
