return {
	{
		"Olical/conjure",
		init = function()
			vim.g["conjure#filetypes"] = {
				"clojure",
				"fennel",
				"janet",
				"hy",
				"julia",
				"racket",
				"scheme",
				"lua",
				"lisp",
				"python",
			}
		end,
		config = function()
			-- Conjure's Fennel (nfnl) client evaluates in a *copy* of _G taken
			-- when the per-file REPL is created, and Fennel freezes its
			-- known-globals list at the same moment. So any global defined
			-- later (by a plugin, or by debugging aids like howdah's snitch
			-- macro) is an "unknown identifier" as a bare name, even though
			-- `_G.name` works. Give the REPL an env that falls through to the
			-- live _G and skip the frozen check. REPL locals still stay
			-- inside the proxy, so nothing leaks into the real globals.
			local repl = require("conjure.nfnl.repl")
			local new = repl.new
			repl.new = function(opts)
				local cfg = opts.cfg
				opts.cfg = function(key)
					local value = cfg and cfg(key)
					if key[1] == "compiler-options" then
						return vim.tbl_extend("force", value or {}, {
							allowedGlobals = false,
							env = setmetatable({}, { __index = _G }),
						})
					end
					return value
				end
				return new(opts)
			end
		end,
	},

	"luochen1990/rainbow",

	-- Not loaded for fennel: its legacy-syntax form detection misbehaves there
	-- (e.g. `vaf` selecting a bare symbol), and its buffer-local `<I`/`>I`
	-- shadowed the treesitter-based versions in init.lua, which handle fennel
	-- correctly. Balancing in fennel is parinfer's job anyway.
	{
		"guns/vim-sexp",
		ft = { "clojure", "scheme", "lisp" },
	},

	{
		"tpope/vim-sexp-mappings-for-regular-people",
		ft = { "clojure", "scheme", "lisp" },
		dependencies = { "guns/vim-sexp" },
		config = function()
			vim.schedule(function()
				vim.cmd("doautocmd FileType")
			end)
		end,
	},

	{ "eraserhd/parinfer-rust", build = "cargo build --release" },

	-- Compiles Fennel (.fnl) to Lua on write. Activates per-project only when
	-- it finds a `.nfnl.fnl` config file at the project root, so loading it for
	-- every Fennel buffer is safe and a no-op elsewhere.
	{
		"Olical/nfnl",
		ft = "fennel",
	},
}
