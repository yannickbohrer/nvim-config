return {
	"neovim/nvim-lspconfig",
	dependencies = {
		{ "williamboman/mason.nvim", config = true },
		{ "williamboman/mason-lspconfig.nvim" },
		{ "j-hui/fidget.nvim", opts = {} },
		"hrsh7th/cmp-nvim-lsp",
		"MunifTanjim/nui.nvim",
		"p00f/clangd_extensions.nvim",
	},
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
			callback = function(event)
				local map = function(keys, func, desc, mode)
					mode = mode or "n"
					vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
				end

				map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
				map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
				map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
				map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
				map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
				map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
				map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
				map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })
				map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
				map("<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", "Switch Source/Header (C/C++)")

				local client = vim.lsp.get_client_by_id(event.data.client_id)

				-- Let pyright own hover for Python; ruff handles lint/fixes/imports
				if client and client.name == "ruff" then
					client.server_capabilities.hoverProvider = false
				end
				if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
					local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
					vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
						buffer = event.buf,
						group = highlight_augroup,
						callback = vim.lsp.buf.document_highlight,
					})
					vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
						buffer = event.buf,
						group = highlight_augroup,
						callback = vim.lsp.buf.clear_references,
					})
				end
			end,
		})

		local capabilities = vim.lsp.protocol.make_client_capabilities()
		capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())
		capabilities.offsetEncoding = { "utf-16" }

		local util = require("lspconfig.util")
		local servers = {
			ts_ls = {},
			angularls = {},
			denols = {
				root_dir = util.root_pattern("deno.json", "deno.jsonc"),
			},
			eslint = {},
			tailwindcss = {},
			cssls = {},
			html = {},
			jsonls = {},
			yamlls = {},
			lua_ls = {
				settings = {
					Lua = {
						completion = { callSnippet = "Replace" },
						diagnostics = { disable = { "missing-fields" } },
					},
				},
			},
			bashls = {},
			clangd = {
				cmd = {
					"clangd",
					"--background-index",
					"--clang-tidy",
					"--header-insertion=iwyu",
					"--completion-style=detailed",
					"--function-arg-placeholders",
					"--fallback-style=llvm",
					"--query-driver=/usr/bin/clang++,/usr/bin/clang,/usr/bin/g++,/usr/bin/gcc,/usr/bin/c++,/usr/bin/cc",
					"--log=verbose",
				},
				init_options = {
					usePlaceholders = true,
					completeUnimported = true,
					clangdFileStatus = true,
				},
			},
			gopls = {},
			rust_analyzer = {},
			ruff = {},
			pyright = {
				-- Use the project's virtualenv: $VIRTUAL_ENV, else .venv/ or venv/ in the project root
				before_init = function(_, config)
					local root = config.root_dir or vim.fn.getcwd()
					local candidates = {}
					if vim.env.VIRTUAL_ENV then
						table.insert(candidates, vim.env.VIRTUAL_ENV .. "/bin/python")
					end
					table.insert(candidates, root .. "/.venv/bin/python")
					table.insert(candidates, root .. "/venv/bin/python")
					for _, py in ipairs(candidates) do
						if vim.fn.executable(py) == 1 then
							config.settings.python.pythonPath = py
							return
						end
					end
				end,
				settings = {
					pyright = {
						autoImportCompletion = true,
						disableOrganizeImports = true, -- ruff handles import sorting
					},
					python = {
						analysis = {
							autoSearchPaths = true,
							diagnosticMode = "openFilesOnly",
							useLibraryCodeForTypes = true,
							typeCheckingMode = "basic",
						},
					},
				},
			},
			jdtls = {
				settings = {
					java = {
						configuration = { updateBuildConfiguration = "interactive" },
						eclipse = { downloadSources = true },
						maven = { downloadSources = true },
						implementationsCodeLens = { enabled = true },
						referencesCodeLens = { enabled = true },
						format = { enabled = false }, -- handled by google-java-format via none-ls
					},
				},
				init_options = {
					workspace = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t"),
				},
			},
			kotlin_language_server = {
				init_options = {
					storagePath = vim.fn.stdpath("cache") .. "/kotlin_language_server",
				},
			},
		}

		require("mason").setup()
		require("mason-lspconfig").setup({
			ensure_installed = vim.tbl_keys(servers),
		})

		for server, server_cfg in pairs(servers) do
			server_cfg.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server_cfg.capabilities or {})
			vim.lsp.config(server, server_cfg)
		end

		require("clangd_extensions").setup({})

		vim.lsp.enable(vim.tbl_keys(servers))
	end,
}
