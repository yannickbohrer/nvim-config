local state = { buf = nil, win = nil }

local function open_terminal()
	local width = math.floor(vim.o.columns * 0.5)
	local height = math.floor(vim.o.lines * 0.5)
	local col = vim.o.columns - width - 1
	local row = vim.o.lines - height - 3

	if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then
		state.buf = vim.api.nvim_create_buf(false, true)
	end

	state.win = vim.api.nvim_open_win(state.buf, true, {
		relative = "editor",
		width = width,
		height = height,
		col = col,
		row = row,
		style = "minimal",
		border = "rounded",
	})

	if vim.bo[state.buf].buftype ~= "terminal" then
		vim.cmd("terminal")
	end

	vim.cmd("startinsert")
end

local function toggle_terminal()
	if state.win and vim.api.nvim_win_is_valid(state.win) then
		vim.api.nvim_win_close(state.win, false)
		state.win = nil
	else
		open_terminal()
	end
end

vim.keymap.set({ "n", "t" }, "<C-t>", toggle_terminal, { noremap = true, silent = true, desc = "Toggle terminal" })
