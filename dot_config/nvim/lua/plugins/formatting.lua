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
			-- fnlfmt is a luarocks --local install, not on PATH. Run it in
			-- --fix (file) mode: stdin mode appends a second trailing
			-- newline, growing a blank line at EOF on every save.
			formatters = {
				fnlfmt = {
					command = vim.fn.expand("~/.luarocks/bin/fnlfmt"),
					args = { "--fix", "$FILENAME" },
					stdin = false,
				},
			},
			formatters_by_ft = {
				fennel = { "fnlfmt" },
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
