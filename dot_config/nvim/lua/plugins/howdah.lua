local howdah_dir = vim.fn.expand("~/Projects/howdah")

if vim.fn.isdirectory(howdah_dir) == 0 then
	return {}
end

return {
	{
		dir = howdah_dir,
		-- Compile the Rust backend on install/update. Produces
		-- target/debug/howdah-server, which the Fennel frontend resolves off
		-- runtimepath via nvim_get_runtime_file.
		build = "cargo build",
		config = function()
			-- Dev-only: drop the module from Lua's require cache on save so
			-- Fennel edits take effect without restarting Neovim. nfnl compiles
			-- fnl -> lua on write; the next require("howdah") reads the fresh lua.
			vim.api.nvim_create_autocmd("BufWritePost", {
				pattern = howdah_dir .. "/fnl/howdah/*.fnl",
				callback = function()
					for name in pairs(package.loaded) do
						if name == "howdah" or vim.startswith(name, "howdah.") then
							package.loaded[name] = nil
						end
					end
				end,
			})
		end,
	},
}
