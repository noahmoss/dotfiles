-- Shared by lsp.lua's references/definitions pickers and navigation.lua's
-- code grep: renders category-ranked, icon-tagged Telescope results so e.g.
-- real usages vs. imports/tests/vendor/docs are visually distinguishable
-- instead of a flat, undifferentiated list. Callers own their own CATEGORY
-- table (rank order is use-case specific -- LSP references ranks usage above
-- definition, code grep ranks definition first) and how each item maps to a
-- category; this module only owns the generic tag/sort/render mechanics.
local M = {}

--- Wraps entry.display so the rendered line gets `meta.icon` prefixed and
--- highlighted with `meta.hl`, with existing highlight ranges shifted to
--- account for the added prefix. No-op if meta.icon is "".
function M.tag_display(entry, meta)
	if meta.icon == "" then
		return
	end
	local base_display = entry.display
	entry.display = function(e)
		local text, highlights = base_display(e)
		local prefix = meta.icon .. " "
		local shifted = { { { 0, #meta.icon }, meta.hl } }
		for _, h in ipairs(highlights or {}) do
			table.insert(shifted, {
				{ h[1][1] + #prefix, h[1][2] + #prefix },
				h[2],
			})
		end
		return prefix .. text, shifted
	end
end

--- Renders a static, pre-fetched result set as a Telescope picker, sorted by
--- category rank ahead of everything else.
--- items: list of quickfix-style { filename, lnum, col, text }
--- category_defs: map of category name -> { rank = number, icon = string, hl = string }
--- get_category: function(item) -> category name (a key in category_defs)
function M.show(prompt_title, items, category_defs, get_category)
	-- Match Telescope's own lsp_definitions/lsp_references behavior (see
	-- list_or_jump in telescope.nvim's __lsp.lua): jump straight to the
	-- single result instead of opening a picker with one entry in it.
	if #items == 1 then
		local item = items[1]
		vim.cmd.edit(vim.fn.fnameescape(item.filename))
		vim.api.nvim_win_set_cursor(0, { item.lnum, math.max((item.col or 1) - 1, 0) })
		vim.cmd("normal! zz")
		return
	end

	table.sort(items, function(a, b)
		local ra, rb = category_defs[get_category(a)].rank, category_defs[get_category(b)].rank
		if ra ~= rb then
			return ra < rb
		end
		if a.filename ~= b.filename then
			return a.filename < b.filename
		end
		return a.lnum < b.lnum
	end)

	local opts = { path_display = { shorten = { len = 1, exclude = { -1, -2 } } } }
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local make_entry = require("telescope.make_entry")
	local base_entry_maker = make_entry.gen_from_quickfix(opts)

	pickers
		.new(opts, {
			prompt_title = prompt_title,
			finder = finders.new_table({
				results = items,
				entry_maker = function(item)
					local entry = base_entry_maker(item)
					M.tag_display(entry, category_defs[get_category(item)])
					return entry
				end,
			}),
			sorter = conf.generic_sorter(opts),
			previewer = conf.qflist_previewer(opts),
		})
		:find()
end

return M
