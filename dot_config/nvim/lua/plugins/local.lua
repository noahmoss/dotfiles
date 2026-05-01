local docent_dir = vim.fn.expand("~/Projects/docent/nvim")

if vim.fn.isdirectory(docent_dir) == 0 then
	return {}
end

return {
	{
		dir = docent_dir,
		config = function()
			require("docent").setup()
		end,
	},
}
