return {
	{
		"tpope/vim-fugitive",
		config = function()
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "fugitiveblame",
				callback = function(ev)
					vim.keymap.set("n", "gx", function()
						local hash = vim.api.nvim_get_current_line():match("^%s*(%x+)")
						if not hash or hash:match("^0+$") then
							return
						end
						local git_dir = vim.fn.FugitiveGitDir()
						local remote = vim.fn.system("git --git-dir=" .. vim.fn.shellescape(git_dir) .. " remote get-url origin 2>/dev/null"):gsub("\n", "")
						local owner, repo = remote:match("github%.com[:/]([^/]+)/([^/\n%.]+)")
						if not owner then
							vim.notify("Could not determine GitHub repo", vim.log.levels.ERROR)
							return
						end
						local url = vim.fn
							.system(string.format(
								"gh api repos/%s/%s/commits/%s/pulls --jq '.[0].html_url // empty' 2>/dev/null",
								owner,
								repo,
								hash
							))
							:gsub("\n", "")
						if url == "" then
							vim.notify("No PR found for " .. hash, vim.log.levels.WARN)
							return
						end
						vim.fn.system("open " .. vim.fn.shellescape(url))
					end, { buffer = ev.buf, desc = "Open GitHub PR for blame commit" })
				end,
			})
		end,
	},
	"tpope/vim-rhubarb",
	"sindrets/diffview.nvim",

	{
		"lewis6991/gitsigns.nvim",
		opts = {
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},
		},
	},
}
