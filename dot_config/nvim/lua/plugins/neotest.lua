-- Go test runner: run/summarize tests without the ceremony of dap-go's
-- debug_test() (which always launches a full debug session, even when you
-- just want pass/fail output). neotest-golang is the actively maintained
-- adapter (the older nvim-neotest/neotest-go is largely unmaintained).
-- gotestsum as the runner avoids stdout-parsing flakiness (writes JSON to
-- a file instead) -- installed automatically via the build step below.
--
-- nvim-treesitter (already configured on the `main` branch in
-- treesitter.lua, with the `go`/`gomod`/`gosum`/`gowork` parsers installed)
-- and nvim-nio/plenary.nvim (already pulled in by dap.lua/go.lua) aren't
-- re-declared here to avoid conflicting duplicate plugin specs.
return {
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"antoinemadec/FixCursorHold.nvim",
			{
				"fredrikaverpil/neotest-golang",
				version = "*",
				build = function()
					vim.system({ "go", "install", "gotest.tools/gotestsum@latest" }):wait()
				end,
			},
		},
		config = function()
			local neotest = require("neotest")
			neotest.setup({
				adapters = {
					require("neotest-golang")({ runner = "gotestsum" }),
				},
			})

			local opts = { noremap = true, silent = true }
			vim.keymap.set("n", "<leader>tn", neotest.run.run, opts) -- run Nearest test
			vim.keymap.set("n", "<leader>tf", function()
				neotest.run.run(vim.fn.expand("%"))
			end, opts) -- run tests in current File
			vim.keymap.set("n", "<leader>td", function()
				neotest.run.run({ strategy = "dap" })
			end, opts) -- Debug nearest test (via existing nvim-dap-go/delve setup)
			vim.keymap.set("n", "<leader>to", function()
				neotest.output.open({ enter = true })
			end, opts) -- Output of nearest test
			vim.keymap.set("n", "<leader>ts", neotest.summary.toggle, opts) -- toggle Summary panel
		end,
	},
}
