return {
	"nvimtools/none-ls.nvim",
	dependencies = {
		"nvimtools/none-ls-extras.nvim",
		"jayp0521/mason-null-ls.nvim",
	},
	config = function()
		local null_ls = require("null-ls")
		local formatting = null_ls.builtins.formatting
		local diagnostics = null_ls.builtins.diagnostics

		require("mason-null-ls").setup({
			ensure_installed = {
				"checkmake",
				"prettier",
				"stylua",
				"shfmt",
				"clang-format",
				"ktlint",
			},
		})

		local sources = {
			diagnostics.checkmake,
			formatting.prettierd.with({
				filetypes = { "javascript", "typescript", "css", "html", "json", "yaml", "markdown" },
			}),
			formatting.stylua,
			formatting.shfmt,
			formatting.clang_format,
			formatting.ktlint,
		}

		null_ls.setup({
			sources = sources,
			on_attach = function(client, bufnr)
				if client.supports_method("textDocument/formatting") then
					local group = vim.api.nvim_create_augroup("LspFormatting", {})
					vim.api.nvim_clear_autocmds({ group = group, buffer = bufnr })
					vim.api.nvim_create_autocmd("BufWritePre", {
						group = group,
						buffer = bufnr,
						callback = function()
							vim.lsp.buf.format({ bufnr = bufnr, async = false })
						end,
					})
				end
			end,
		})
	end,
}
