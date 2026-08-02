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

	{
		"guns/vim-sexp",
		ft = { "clojure", "scheme", "lisp", "fennel" },
	},

	{
		"tpope/vim-sexp-mappings-for-regular-people",
		ft = { "clojure", "scheme", "lisp", "fennel" },
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
