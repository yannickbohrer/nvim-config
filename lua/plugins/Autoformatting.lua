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
				"google-java-format",
				"ruff",
			},
		})

		local sources = {
			diagnostics.checkmake,
			formatting.prettier.with({
				filetypes = { "javascript", "typescript", "css", "html", "json", "yaml", "markdown" },
			}),
			formatting.stylua,
			formatting.shfmt,
			formatting.clang_format,
			formatting.ktlint,
			formatting.google_java_format,
			require("none-ls.formatting.ruff_format"),
		}

		-- One persistent group; clear per-buffer to avoid duplicate format-on-save
		local fmt_group = vim.api.nvim_create_augroup("LspFormatting", { clear = false })

		null_ls.setup({
			sources = sources,
			on_attach = function(client, bufnr)
				if client:supports_method("textDocument/formatting") then
					vim.api.nvim_clear_autocmds({ group = fmt_group, buffer = bufnr })
					vim.api.nvim_create_autocmd("BufWritePre", {
						group = fmt_group,
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
