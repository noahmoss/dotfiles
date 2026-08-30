return {
	{ "christoomey/vim-tmux-navigator", init = function() vim.g.tmux_navigator_no_mappings = 1 end },

	-- Replaces vim-easymotion, vim-sneak, and quick-scope with one maintained
	-- plugin. `s` jumps anywhere visible (treesitter-aware), `f/F/t/T` get
	-- per-character highlights, and search integrates with the same labels.
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		opts = {},
		keys = {
			{ "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
			{ "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
			{ "r",     mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
			{ "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
			{ "<C-s>", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
		},
	},

	{
		"nvim-telescope/telescope.nvim",
		event = "VimEnter",
		branch = "master",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},
			{ "nvim-telescope/telescope-ui-select.nvim" },
			{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
		},
		config = function()
			require("telescope").setup({
				defaults = {
					path_display = { "filename_first" },
					-- We pass --hidden to rg (in vimgrep_arguments and find_files)
					-- so dotfiles like .zshrc show up, but that also makes rg
					-- descend into .git/. Exclude it via a glob (below) so rg
					-- never searches .git/ contents in the first place — cwd
					-- here spans many repos, so without this every keystroke
					-- greps through every nested repo's pack files, which is
					-- what causes live_grep to appear to freeze on no-match
					-- queries. file_ignore_patterns is kept as a display-level
					-- backstop for pickers that don't use vimgrep_arguments.
					file_ignore_patterns = { "^%.git/", "/%.git/" },
					layout_strategy = "horizontal",
					layout_config = {
						horizontal = {
							-- Give the results column more room so the matched
							-- line text (filename:line:col: text) isn't truncated
							-- down to just the filename.
							width = 0.95,
							preview_width = 0.55,
						},
					},
					vimgrep_arguments = {
						"rg",
						"--color=never",
						"--no-heading",
						"--with-filename",
						"--line-number",
						"--column",
						"--smart-case",
						"--hidden",
						"--glob=!**/.git/*",
						-- Lockfiles (Cargo.lock etc.) are committed so rg won't
						-- skip them, and they flood grep results (every Cargo.lock
						-- dependency has a `source = "registry+..."` line).
						"--glob=!**/*.lock",
					},
				},
				pickers = {
					find_files = {
						hidden = true,
						find_command = { "rg", "--files", "--hidden", "--glob=!**/.git/*" },
					},
					-- LSP location pickers shorten long dependency paths (e.g.
					-- ~/.rustup/...) so the matched line text stays visible
					-- instead of being truncated away.
					lsp_type_definitions = { path_display = { shorten = { len = 1, exclude = { -1 } } } },
					lsp_definitions = { path_display = { shorten = { len = 1, exclude = { -1 } } } },
					lsp_implementations = { path_display = { shorten = { len = 1, exclude = { -1 } } } },
					lsp_references = { path_display = { shorten = { len = 1, exclude = { -1 } } } },
				},
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown(),
					},
				},
			})

			pcall(require("telescope").load_extension, "fzf")
			pcall(require("telescope").load_extension, "ui-select")

			local builtin = require("telescope.builtin")

			local has_nerd_font = vim.g.have_nerd_font

			-- Definition-like keywords across the languages in this config's
			-- codebases (Go, TS/JS, Python, Rust, Lua, Clojure, etc.). Grep has no
			-- semantic model of a symbol, so "is this a definition" is a heuristic:
			-- does a declaration keyword appear directly before the searched term
			-- (only whitespace between them, so e.g. `const s3Copy = new Foo()`
			-- doesn't misfire on `Foo`). `receiver = true` additionally allows one
			-- balanced-parens group in between, for Go's `func (s *Server) Foo()`.
			local CODE_GREP_DEFINITION_KEYWORDS = {
				{ kw = "func", receiver = true },
				{ kw = "function", receiver = true },
				{ kw = "def" },
				{ kw = "fn" },
				{ kw = "class" },
				{ kw = "struct" },
				{ kw = "enum" },
				{ kw = "trait" },
				{ kw = "interface" },
				{ kw = "type" },
				{ kw = "const" },
				{ kw = "let" },
				{ kw = "var" },
				{ kw = "local" },
				{ kw = "defn" },
				{ kw = "defmacro" },
				{ kw = "defprotocol" },
				{ kw = "defrecord" },
			}

			-- Ranks definitions first, then real usages -- the reverse of lsp.lua's
			-- CATEGORY, where the declaration you just navigated from matters less
			-- than seeing where else the symbol is used. Same shared renderer
			-- (util.categorized_picker), different rank order for a different task.
			local CODE_GREP_CATEGORY = {
				definition = { rank = 0, icon = has_nerd_font and "" or "[def]", hl = "TelescopeRefDefinition" },
				usage = { rank = 1, icon = has_nerd_font and "" or "[use]", hl = "TelescopeRefUsage" },
				import = { rank = 2, icon = has_nerd_font and "" or "[import]", hl = "TelescopeRefImport" },
				test = { rank = 3, icon = has_nerd_font and "" or "[test]", hl = "TelescopeRefTest" },
				doc = { rank = 4, icon = has_nerd_font and "" or "[doc]", hl = "TelescopeRefDoc" },
				vendor = { rank = 5, icon = has_nerd_font and "" or "[vendor]", hl = "TelescopeRefVendor" },
			}
			-- `default = true` so these fall back to sensible, theme-adapting colors
			-- but don't clobber an explicit override from a colorscheme. The other
			-- TelescopeRef* highlights are set up by lsp.lua; re-declaring them here
			-- with `default = true` would be a harmless no-op either load order, but
			-- TelescopeRefDoc only exists for code grep, so it's set here.
			vim.api.nvim_set_hl(0, "TelescopeRefDoc", { link = "Comment", default = true })

			-- Query is matched fuzzily against rg (see fuzzy_rg_pattern below), so
			-- it's rarely a literal substring of the matched line -- can't just
			-- check "does the query appear right after a keyword" anymore. Instead
			-- extract the identifier token that actually follows the keyword and
			-- fuzzy-compare THAT against the query, same idea as the rg matching
			-- itself: query's characters appear in order (not necessarily
			-- contiguous) within the candidate identifier.
			local function fuzzy_match(query, candidate)
				query = query:lower()
				candidate = candidate:lower()
				local qi = 1
				for i = 1, #candidate do
					if qi > #query then
						break
					end
					if candidate:sub(i, i) == query:sub(qi, qi) then
						qi = qi + 1
					end
				end
				return qi > #query
			end

			local function code_grep_looks_like_definition(text, pattern)
				for _, spec in ipairs(CODE_GREP_DEFINITION_KEYWORDS) do
					local kw = spec.kw
					local ident = text:match("%f[%w]" .. kw .. "%*?%s+([%a_][%w_]*)")
					if ident and fuzzy_match(pattern, ident) then
						return true
					end
					if spec.receiver then
						local receiver_ident = text:match("%f[%w]" .. kw .. "%s*%b()%s*([%a_][%w_]*)")
						if receiver_ident and fuzzy_match(pattern, receiver_ident) then
							return true
						end
					end
				end
				-- `name = function` / `name: function` style (JS/Lua object methods)
				local assigned_ident = text:match("([%a_][%w_]*)%s*[:=]%s*function")
				return assigned_ident ~= nil and fuzzy_match(pattern, assigned_ident)
			end

			local function code_grep_categorize(item, pattern)
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
					fname:match("%.md$")
					or fname:match("%.mdx$")
					or fname:match("%.rst$")
					or fname:match("%.adoc$")
					or fname:match("[/\\]docs?[/\\]")
				then
					return "doc"
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
				if code_grep_looks_like_definition(text, pattern) then
					return "definition"
				end
				return "usage"
			end

			-- Spreads the typed query into an rg regex that matches its characters
			-- in order but not necessarily contiguously (e.g. "rtcmd" -> RootCmd),
			-- the same idea fzf-style fuzzy finders use, so code grep is fuzzy from
			-- the first keystroke. `<leader>sg` (plain live_grep) is untouched --
			-- that one stays literal/regex, unaffected by this.
			local function fuzzy_rg_pattern(query)
				local specials = "\\.+*?()|[]{}^$"
				local parts = {}
				for i = 1, #query do
					local c = query:sub(i, i)
					table.insert(parts, specials:find(c, 1, true) and ("\\" .. c) or c)
				end
				return table.concat(parts, ".*?")
			end

			-- Same idea as live_grep (re-run rg on every keystroke) but with a
			-- custom sorter: telescope's own live_grep uses `sorters.highlighter_only`,
			-- which always scores 1, so entries stay in whatever order rg's
			-- filesystem walk happened to emit them (see __files.lua's
			-- `files.live_grep`). This scores each entry by its CODE_GREP_CATEGORY
			-- rank instead, so as results stream in, definitions surface first,
			-- then real usages, with imports/tests/docs/vendor pushed down -- the
			-- same categorize-and-rank idea as lsp.lua's gd/grr, applied live.
			local function code_grep()
				local conf = require("telescope.config").values
				local finders = require("telescope.finders")
				local pickers = require("telescope.pickers")
				local sorters = require("telescope.sorters")
				local make_entry = require("telescope.make_entry")
				local fzy = require("telescope.algos.fzy")
				local categorized_picker = require("util.categorized_picker")

				-- Set by the job's command_generator (called once per keystroke,
				-- before entry_maker runs on the resulting lines) so entry_maker
				-- always categorizes against the query that produced the line it's
				-- looking at. Kept as the raw typed text (not the fuzzy regex sent
				-- to rg) since fuzzy_match wants the original characters in order.
				local current_pattern = ""
				local base_entry_maker = make_entry.gen_from_vimgrep({})

				local function entry_maker(line)
					local entry = base_entry_maker(line)
					if entry then
						local meta = CODE_GREP_CATEGORY[code_grep_categorize(entry, current_pattern)]
						entry.category_rank = meta.rank
						categorized_picker.tag_display(entry, meta)
					end
					return entry
				end

				local live_grepper = finders.new_job(function(prompt)
					if not prompt or prompt == "" then
						return nil
					end
					current_pattern = prompt
					return vim.list_extend(vim.deepcopy(conf.vimgrep_arguments), { "--", fuzzy_rg_pattern(prompt) })
				end, entry_maker, nil, vim.uv.cwd())

				pickers
					-- entry_manager.lua only guarantees a full rank-sort within the
					-- first `temp__scrolling_limit` entries (default 250); anything
					-- past that cutoff can land slightly out of order. A broad grep
					-- across a big repo can easily clear 250 matches, so raise it well
					-- above any realistic match count instead of risking a corrupted
					-- tail.
					.new({ temp__scrolling_limit = 20000 }, {
						prompt_title = "Code Grep",
						finder = live_grepper,
						previewer = conf.grep_previewer({}),
						sorter = sorters.Sorter:new({
							-- Sorter:score calls `self:scoring_function(prompt, ordinal,
							-- entry, ...)` -- a colon call, so `self` lands in the first
							-- slot too. 4 leading params, not 3, or `entry` here is
							-- actually `ordinal` (a string) and category_rank silently
							-- reads as nil off it every time, scoring everyone 1 -- which
							-- is indistinguishable from live_grep's plain unsorted order.
							scoring_function = function(_, _, _, entry)
								return (entry and entry.category_rank) or 1
							end,
							highlighter = function(_, prompt, display)
								return fzy.positions(prompt, display)
							end,
						}),
						attach_mappings = function(_, map)
							map("i", "<c-space>", require("telescope.actions").to_fuzzy_refine)
							return true
						end,
						push_cursor_on_edit = true,
					})
					:find()
			end
			vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
			vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
			vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
			vim.keymap.set("n", "<leader>sF", "<cmd>Telescope frecency<cr>", { desc = "[Search] [F]iles by Frequency" })
			vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
			vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
			vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
			vim.keymap.set("n", "<leader>sc", code_grep, { desc = "[S]earch [C]ode (definitions ranked first)" })
			vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
			vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
			vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
			vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })

			vim.keymap.set("n", "<leader>/", function()
				builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
					winblend = 10,
					previewer = false,
				}))
			end, { desc = "[/] Fuzzily search in current buffer" })

			vim.keymap.set("n", "<leader>s/", function()
				builtin.live_grep({
					grep_open_files = true,
					prompt_title = "Live Grep in Open Files",
				})
			end, { desc = "[S]earch [/] in Open Files" })

			vim.keymap.set("n", "<leader>sn", function()
				builtin.find_files({ cwd = vim.fn.stdpath("config") })
			end, { desc = "[S]earch [N]eovim files" })
		end,
	},

	{
		"nvim-telescope/telescope-frecency.nvim",
		version = "*",
		config = function()
			require("telescope").load_extension("frecency")
		end,
	},
}
