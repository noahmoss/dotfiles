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
				"sql",
			}
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
