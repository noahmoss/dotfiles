-- rustaceanvim replaces the plain lspconfig rust_analyzer setup (removed from
-- lsp.lua — it would double-attach): it spawns rust-analyzer itself and adds
-- the :RustLsp commands (renderDiagnostic for cargo-style rendered errors,
-- explainError, expandMacro, runnables, ...).

-- Configured via a global, not setup(); must be set before the plugin loads.
vim.g.rustaceanvim = {
	server = {
		default_settings = {
			["rust-analyzer"] = {
				check = {
					command = "clippy",
				},
				-- Format via nightly rustfmt so unstable rustfmt.toml
				-- options (import grouping/merging) take effect.
				rustfmt = {
					extraArgs = { "+nightly" },
				},
			},
		},
	},
}

return {
	{
		"mrcjkb/rustaceanvim",
		version = "^9",
		-- The plugin lazy-loads itself by filetype; upstream says don't
		-- additionally lazy it via lazy.nvim.
		lazy = false,
	},
}
