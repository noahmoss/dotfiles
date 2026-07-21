return {
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				{ path = "luvit-meta/library", words = { "vim%.uv" } },
			},
		},
	},

	{ "Bilal2453/luvit-meta", lazy = true },

	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "williamboman/mason.nvim", opts = {} },
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			{ "j-hui/fidget.nvim", opts = {} },
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					map("K", vim.lsp.buf.hover, "Show documentation in hover window")
					map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
					-- Override the Neovim 0.11+ default grr (quickfix list) with Telescope.
					map("grr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
					map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
					map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
					map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
					map(
						"<leader>ws",
						require("telescope.builtin").lsp_dynamic_workspace_symbols,
						"[W]orkspace [S]ymbols"
					)
					map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
					map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })
					map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
						local highlight_augroup =
							vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.document_highlight,
						})
						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.clear_references,
						})
						vim.api.nvim_create_autocmd("LspDetach", {
							group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
							callback = function(event2)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
							end,
						})
					end

					if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
						map("<leader>th", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
						end, "[T]oggle Inlay [H]ints")
					end
				end,
			})

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())
			capabilities.general = capabilities.general or {}
			capabilities.general.positionEncodings = { "utf-16", "utf-8" }

			local servers = {
				pyright = {},
				clojure_lsp = {},
				clangd = {
					-- Flags (not `settings`) are how clangd is configured — it doesn't
					-- read most options via workspace/didChangeConfiguration.
					-- --background-index: index the whole project (via compile_commands.json)
					-- so goto-def/references/hover work across files you haven't opened,
					-- not just the current TU. This is what makes navigating a large
					-- codebase like Postgres tractable.
					-- --header-insertion=iwyu: auto-add #includes when completing symbols
					-- from headers not yet included.
					-- --all-scopes-completion: complete symbols from all namespaces/scopes,
					-- not just ones already visible/included.
					--
					-- Note: clangd needs a compile_commands.json (or compile_flags.txt) at
					-- the project root to resolve include paths/macros correctly. Postgres
					-- uses autoconf/make, not CMake, so generate one with:
					--   ./configure && bear -- make -j$(nproc)
					-- (bear is available via `brew install bear`). Without it, clangd falls
					-- back to guessed flags and diagnostics/completion will be unreliable.
					cmd = {
						"clangd",
						"--background-index",
						"--clang-tidy",
						"--header-insertion=iwyu",
						"--all-scopes-completion",
						"--completion-style=detailed",
						"--pch-storage=memory",
					},
				},
				gopls = {
					settings = {
						gopls = {
							-- Analyze build-tagged files (e.g. admin-mgr's
							-- `//go:build canary`) that are otherwise excluded
							-- from the default build, so gopls has package
							-- metadata for them.
							buildFlags = { "-tags=canary" },
							staticcheck = true,
							usePlaceholders = true,
							completeUnimported = true,
							analyses = {
								unusedparams = true,
								shadow = true,
								nilness = true,
								unusedwrite = true,
								useany = true,
							},
							hints = {
								assignVariableTypes = true,
								compositeLiteralFields = true,
								compositeLiteralTypes = true,
								constantValues = true,
								functionTypeParameters = true,
								parameterNames = true,
								rangeVariableTypes = true,
							},
						},
					},
				},
				rust_analyzer = {
					settings = {
						["rust-analyzer"] = {
							check = {
								command = "clippy",
							},
						},
					},
				},
				cssls = {},
				elixirls = {},
				eslint = {},
				ts_ls = {},
				lua_ls = {
					settings = {
						Lua = {
							completion = {
								callSnippet = "Replace",
							},
						},
					},
				},
			}

			local ensure_installed = vim.tbl_keys(servers or {})
			vim.list_extend(ensure_installed, {
				"stylua",
				"goimports",
				"impl",
				"gomodifytags",
				"gotests",
				"iferr",
				"clang-format",
			})
			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			require("mason-lspconfig").setup({
				ensure_installed = {},
				automatic_installation = false,
				-- v2 auto-enables every Mason-installed server by default, which
				-- would double-enable `ts_ls` (already explicit in `servers` above)
				-- alongside anything else Mason installs. Disable it; the loop
				-- below is the single source of truth for which servers we enable.
				automatic_enable = false,
			})

			for server_name, server_config in pairs(servers) do
				server_config.capabilities =
					vim.tbl_deep_extend("force", {}, capabilities, server_config.capabilities or {})
				vim.lsp.config(server_name, server_config)
				vim.lsp.enable(server_name)
			end

			-- tsgo (typescript-go, @typescript/native-preview) is disabled for now —
			-- its code actions don't yet cover refactors (extract function/variable,
			-- etc.), which `ts_ls` (added to `servers` above) gets from full tsserver.
			-- To flip back: remove `ts_ls` from `servers` and uncomment below.
			-- vim.lsp.config("tsgo", { capabilities = capabilities })
			-- vim.lsp.enable("tsgo")
		end,
	},
}
