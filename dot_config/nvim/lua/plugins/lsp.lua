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
		-- Rewrites the ~67 most confusing tsserver error messages (e.g. the
		-- TS2345/TS2739 "is missing the following properties" combo) into
		-- plainer English. Auto-attaches to `ts_ls` diagnostics.
		"dmmulroy/ts-error-translator.nvim",
		ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
		opts = {},
	},

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
			-- Categorizes references into definition/usage/import/test/vendor,
			-- sorts real usages first (imports, test-file, and dependency hits
			-- last), and tags each row with an icon + highlight so the
			-- categories are visually scannable at a glance instead of a flat,
			-- undifferentiated list.
			local has_nerd_font = vim.g.have_nerd_font
			local CATEGORY = {
				usage = { rank = 0, icon = has_nerd_font and "" or "[use]", hl = "TelescopeRefUsage" },
				-- Ranked below usage: seeing where a symbol is actually used
				-- matters more day-to-day than re-seeing its declaration, which
				-- you just navigated from (or can jump to separately via gd).
				definition = { rank = 1, icon = has_nerd_font and "" or "[def]", hl = "TelescopeRefDefinition" },
				import = { rank = 2, icon = has_nerd_font and "" or "[import]", hl = "TelescopeRefImport" },
				test = { rank = 3, icon = has_nerd_font and "" or "[test]", hl = "TelescopeRefTest" },
				vendor = { rank = 4, icon = has_nerd_font and "" or "[vendor]", hl = "TelescopeRefVendor" },
				-- Unstyled fallback for definitions_picker: a definitions result
				-- that isn't vendor/test is just real project source, so it gets
				-- no icon/tag (icon = "" is a signal make_lsp_picker checks for).
				source = { rank = 0, icon = "", hl = "TelescopeRefUsage" },
			}
			-- `default = true` so these fall back to sensible, theme-adapting
			-- colors but don't clobber an explicit override from a colorscheme.
			vim.api.nvim_set_hl(0, "TelescopeRefDefinition", { link = "Title", default = true })
			vim.api.nvim_set_hl(0, "TelescopeRefUsage", { link = "Normal", default = true })
			vim.api.nvim_set_hl(0, "TelescopeRefImport", { link = "Comment", default = true })
			vim.api.nvim_set_hl(0, "TelescopeRefTest", { link = "Comment", default = true })
			vim.api.nvim_set_hl(0, "TelescopeRefVendor", { link = "Comment", default = true })

			-- `textDocument/references` returns the declaration mixed in with
			-- everywhere else it's used, with nothing to tell them apart. Fire a
			-- `textDocument/definition` lookup at the same time (not before) so
			-- the declaration's location comes back to tag it separately without
			-- adding to the "grr" latency -- definition is a single-symbol lookup,
			-- so on any server it should resolve no slower than the workspace-wide
			-- references search it's racing against. If it's still in flight when
			-- results render, the declaration just displays as a plain usage.
			local function start_definition_lookup()
				local definition_keys = {}
				local bufnr = vim.api.nvim_get_current_buf()
				local win = vim.api.nvim_get_current_win()
				for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/definition" })) do
					local params = vim.lsp.util.make_position_params(win, client.offset_encoding)
					client:request("textDocument/definition", params, function(_, result)
						if not result then
							return
						end
						local locations = vim.islist(result) and result or { result }
						for _, item in ipairs(vim.lsp.util.locations_to_items(locations, client.offset_encoding)) do
							definition_keys[item.filename .. ":" .. item.lnum] = true
						end
					end, bufnr)
				end
				return definition_keys
			end

			-- `default_category` lets callers that have no real "declaration vs
			-- usage" distinction (e.g. a goto-definition result set, where every
			-- item already IS a definition) pick what an otherwise-unclassified
			-- hit should be labeled, instead of always falling back to "usage".
			local function categorize(item, definition_keys, default_category)
				if definition_keys[item.filename .. ":" .. item.lnum] then
					return "definition"
				end
				local fname = item.filename or ""
				if
					fname:match("node_modules")
					or fname:match("[/\\]vendor[/\\]")
					or fname:match("%.d%.ts$")
					or fname:match("site%-packages")
				then
					return "vendor"
				end
				if
					fname:match("%.test%.")
					or fname:match("_test%.")
					or fname:match("%.spec%.")
					or fname:match("[/\\]tests?[/\\]")
				then
					return "test"
				end
				local text = item.text or ""
				if
					text:match("^%s*import%s")
					or text:match("require%(")
					or text:match("^%s*from%s+.-%s+import")
				then
					return "import"
				end
				return default_category or "usage"
			end

			-- Thin wrapper around the shared util.categorized_picker (sorts by
			-- category rank, then tags each entry's display line with its
			-- category's icon/highlight) so real source, vendor/.d.ts, tests,
			-- etc. are visually distinguishable instead of a flat list of
			-- indistinguishable, similarly-shortened paths. navigation.lua's
			-- code grep reuses the same renderer with its own CATEGORY/ranks.
			local function make_lsp_picker(prompt_title, items, get_category)
				require("util.categorized_picker").show(prompt_title, items, CATEGORY, get_category)
			end

			local function references_picker()
				local definition_keys = start_definition_lookup()
				vim.lsp.buf.references(nil, {
					on_list = function(list)
						make_lsp_picker("LSP References", list.items, function(item)
							return categorize(item, definition_keys)
						end)
					end,
				})
			end

			-- Plain `lsp_definitions` shows every overload/declaration Telescope
			-- gets back with no way to tell which hit is real project source vs.
			-- a vendored `.d.ts`/node_modules declaration (common with TS overload
			-- signatures, which often resolve to 2+ near-identical locations).
			-- Reuse the same categorize/tagging as references_picker so vendor
			-- hits are dimmed, tagged, and sorted after real source.
			local function definitions_picker()
				vim.lsp.buf.definition({
					on_list = function(list)
						make_lsp_picker("LSP Definitions", list.items, function(item)
							return categorize(item, {}, "source")
						end)
					end,
				})
			end

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					map("K", vim.lsp.buf.hover, "Show documentation in hover window")
					map("gd", definitions_picker, "[G]oto [D]efinition")
					-- Override the Neovim 0.11+ default grr (quickfix list) with our
					-- categorized picker (real usages first, imports/tests tagged
					-- and sorted last) instead of Telescope's plain lsp_references.
					map("grr", references_picker, "[G]oto [R]eferences")
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
								-- shadow is off (and off by default in gopls and
								-- golangci-lint): it flags the idiomatic
								-- `if err := f(); err != nil` whenever an outer
								-- `err` exists, and the fix it nudges you toward
								-- widens the error's lifetime.
								shadow = false,
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
				-- rust_analyzer is deliberately absent: rustaceanvim (plugins/
				-- rust.lua) owns it — an lspconfig entry here would double-attach.
				cssls = {},
				-- fennel-ls (xerool) over fennel-language-server (rydesun): the
				-- former is actively maintained and configured per-project via a
				-- `flsproject.fnl` file. Neovim detects `*.fnl` as `fennel` natively.
				fennel_ls = {},
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
				-- rust-analyzer no longer comes via the servers table (see note
				-- there); rustaceanvim finds the mason binary on nvim's PATH.
				"rust-analyzer",
				"stylua",
				"goimports",
				"impl",
				"gomodifytags",
				"gotests",
				"iferr",
				-- clang-format comes from homebrew: mason's pypi install needs a
				-- working python venv, and homebrew's python3.14 bottle can't
				-- create one on this macOS (libexpat symbol mismatch).
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
