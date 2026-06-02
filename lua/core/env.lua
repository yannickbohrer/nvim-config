-- Ensure critical paths are available regardless of how nvim is launched
-- (terminal with zshrc, GUI app, tmux, etc.)

local function prepend_path(dir)
	if vim.fn.isdirectory(dir) ~= 1 then return end
	local path = vim.env.PATH or ""
	if not path:find(dir, 1, true) then
		vim.env.PATH = dir .. (path ~= "" and (":" .. path) or "")
	end
end

-- Mason-installed binaries (LSPs, formatters, linters)
prepend_path(vim.fn.stdpath("data") .. "/mason/bin")

-- Java: prefer the version already set by the shell; otherwise try homebrew installs
-- in descending version order (jdtls requires 21+)
if not vim.env.JAVA_HOME or vim.fn.isdirectory(vim.env.JAVA_HOME) ~= 1 then
	local candidates = {
		"/opt/homebrew/opt/openjdk@25/libexec/openjdk.jdk/Contents/Home",
		"/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home",
		"/opt/homebrew/opt/openjdk/libexec/openjdk.jdk/Contents/Home",
	}
	for _, candidate in ipairs(candidates) do
		if vim.fn.isdirectory(candidate) == 1 then
			vim.env.JAVA_HOME = candidate
			break
		end
	end
end
if vim.env.JAVA_HOME then
	prepend_path(vim.env.JAVA_HOME .. "/bin")
end
