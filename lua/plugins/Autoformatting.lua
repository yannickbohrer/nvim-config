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

		-- Manual null-ls tool list (removed mason-null-ls automatic_installation)
		require("mason-null-ls").setup({
			ensure_installed = {
				"checkmake",
				"prettier",
				"stylua",
				"eslint_d",
				"shfmt",
				"ruff",
				"clang-format",
			},
		})

		local sources = {
			diagnostics.checkmake,
			formatting.prettier.with({
				filetypes = {
					"javascript",
					"typescript",
					"javascriptreact",
					"typescriptreact",
					"css",
					"scss",
					"html",
					"json",
					"yaml",
					"markdown",
					"graphql",
					"md",
					"txt",
					"go",
				},
			}),
			formatting.stylua,
			formatting.shfmt.with({ args = { "-i", "4" } }),
			formatting.terraform_fmt,
			require("none-ls.formatting.ruff").with({ extra_args = { "--extend-select", "I" } }),
			require("none-ls.formatting.ruff_format"),
			formatting.clang_format.with({
				filetypes = { "cpp", "c", "objc", "objcpp" },
			}),
		}

		local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
		null_ls.setup({
			sources = sources,
			on_attach = function(client, bufnr)
				if client.supports_method("textDocument/formatting") then
					vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
					vim.api.nvim_create_autocmd("BufWritePre", {
						group = augroup,
						buffer = bufnr,
						callback = function()
							vim.lsp.buf.format({ async = false })
						end,
					})
				end
			end,
		})
	end,
}
