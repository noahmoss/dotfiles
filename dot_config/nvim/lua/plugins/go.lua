-- Go-specific helpers: :GoIfErr (insert `if err != nil`), :GoImpl (stub
-- interface methods), :GoTagAdd json, :GoFillStruct, etc. These wrap the
-- canonical Go tools (impl, gomodifytags, gotests, iferr) and aren't
-- something gopls exposes via LSP.

-- gopls only diagnoses buffers you have open, so it can miss build errors
-- elsewhere in the module. `:make` runs a real `go build`/`go vet` across
-- the whole project and puts every error in the quickfix list, regardless
-- of what's open. Go's "file:line:col: msg" output already matches vim's
-- default errorformat (%f:%l:%c:%m), so no custom errorformat is needed.
vim.api.nvim_create_autocmd("FileType", {
	pattern = "go",
	callback = function(event)
		vim.opt_local.makeprg = "go build ./..."
		vim.keymap.set("n", "<leader>gb", "<cmd>make<CR>", { buffer = event.buf, desc = "[G]o [B]uild (quickfix)" })
		vim.keymap.set("n", "<leader>gv", function()
			vim.opt_local.makeprg = "go vet ./..."
			vim.cmd("make")
			vim.opt_local.makeprg = "go build ./..."
		end, { buffer = event.buf, desc = "[G]o [V]et (quickfix)" })
	end,
})

-- :make populates the quickfix list but doesn't open it. Auto-open on
-- results (and close it when a re-run comes back clean).
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
	pattern = "make",
	callback = function()
		if #vim.fn.getqflist() > 0 then
			vim.cmd("copen")
		else
			vim.cmd("cclose")
		end
	end,
})

return {
	{
		"olexsmir/gopher.nvim",
		ft = "go",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		opts = {},
	},
}
