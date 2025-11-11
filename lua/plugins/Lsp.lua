return {
	"neovim/nvim-lspconfig",
	dependencies = {
		-- You can unpin these if you want the latest, but your pinned versions are fine.
		{ "williamboman/mason.nvim", version = "1.11.0", config = true },
		{ "williamboman/mason-lspconfig.nvim", version = "1.32.0" },
		{ "j-hui/fidget.nvim", opts = {} },
		"hrsh7th/cmp-nvim-lsp",
		"MunifTanjim/nui.nvim",
	},
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

				local client = vim.lsp.get_client_by_id(event.data.client_id)

				if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
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
					vim.api.nvim_create_autocmd("LspDetach", {
						group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
						callback = function(event2)
							vim.lsp.buf.clear_references()
							vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
						end,
					})
				end

				if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
					map("<leader>th", function()
						vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
					end, "[T]oggle Inlay [H]ints")
				end
			end,
		})

		local capabilities = vim.lsp.protocol.make_client_capabilities()
		capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

		-- Put this where your `local servers` table is
		local util = require("lspconfig.util")

		local servers = {
			-- === Web / JS / TS ===
			-- Typescript/JS (nvim-lspconfig renamed tsserver -> ts_ls)
			ts_ls = {
				-- Prevent attaching inside Deno projects
				root_dir = util.root_pattern("package.json", "tsconfig.json", "jsconfig.json", ".git"),
				single_file_support = false,
				settings = {
					javascript = { inlayHints = { includeInlayParameterNameHints = "all" } },
					typescript = { inlayHints = { includeInlayParameterNameHints = "all" } },
				},
			},

			-- If you use Deno projects, this enables Deno LSP only when it detects them.
			denols = {
				root_dir = util.root_pattern("deno.json", "deno.jsonc"),
				init_options = { lint = true, unstable = true },
			},

			-- ESLint (attach only where an eslint config exists)
			eslint = {
				root_dir = util.root_pattern(
					".eslintrc",
					".eslintrc.js",
					".eslintrc.cjs",
					".eslintrc.json",
					".eslintrc.yaml",
					".eslintrc.yml",
					"eslint.config.js",
					"eslint.config.mjs",
					"eslint.config.cjs",
					"eslint.config.ts"
				),
			},

			-- Tailwind CSS (helpful for React/Vue/Svelte)
			tailwindcss = {
				filetypes = {
					"html",
					"css",
					"scss",
					"sass",
					"postcss",
					"javascript",
					"javascriptreact",
					"typescript",
					"typescriptreact",
					"vue",
					"svelte",
					"astro",
					"templ", -- go templ
				},
			},

			cssls = {},
			html = { filetypes = { "html" } },
			jsonls = {},
			yamlls = {},
			marksman = {}, -- Markdown
			emmet_ls = { -- optional, quick HTML/TSX expand
				filetypes = { "html", "css", "scss", "sass", "javascriptreact", "typescriptreact", "vue", "svelte" },
			},

			-- === Python ===
			ruff = {}, -- fast linting/format hints
			pylsp = {
				settings = {
					pylsp = {
						plugins = {
							pyflakes = { enabled = false },
							pycodestyle = { enabled = false },
							autopep8 = { enabled = false },
							yapf = { enabled = false },
							mccabe = { enabled = false },
							pylsp_mypy = { enabled = false },
							pylsp_black = { enabled = false },
							pylsp_isort = { enabled = false },
						},
					},
				},
			},

			-- === Go / Rust / C/C++ ===
			gopls = {},
			rust_analyzer = {
				settings = {
					["rust-analyzer"] = {
						cargo = { allFeatures = true },
						check = { command = "clippy" },
					},
				},
			},
			clangd = {},

			-- === Scripting / DevOps ===
			bashls = {},
			dockerls = {},
			docker_compose_language_service = {},
			terraformls = {},
			tflint = {},

			-- === Databases / Data ===
			sqlls = {}, -- or use "sqls" if you prefer
			taplo = {}, -- TOML

			-- === Lua (Neovim) ===
			lua_ls = {
				settings = {
					Lua = {
						completion = { callSnippet = "Replace" },
						runtime = { version = "LuaJIT" },
						workspace = {
							checkThirdParty = false,
							library = {
								"${3rd}/luv/library",
								unpack(vim.api.nvim_get_runtime_file("", true)),
							},
							telemetry = { enable = false },
							diagnostics = { disable = { "missing-fields" } },
						},
					},
				},
			},

			-- === Frameworks / SPA (optional: enable if you use them) ===
			svelte = {},
			volar = { -- Vue
				init_options = { typescript = { tsdk = "" } }, -- tsdk auto if empty; set if you use pnpm workspaces
			},
			graphql = {},

			-- === Other popular languages (enable if you use them) ===
			phpactor = {}, -- PHP (alternative: intelephense)
			ruby_lsp = {}, -- Ruby
			elixirls = {}, -- Elixir (requires elixir-ls in Mason)
			kotlin_language_server = {},
			zls = {}, -- Zig
			hls = {}, -- Haskell
		}

		require("mason").setup()

		require("mason-lspconfig").setup({
			ensure_installed = vim.tbl_keys(servers),
			-- mason-lspconfig v1.x: keep these if you really want; v2 changed options.
			automatic_installation = false,
			automatic_enable = false,
			handlers = {
				function(server_name)
					local cfg = servers[server_name] or {}
					cfg.capabilities = vim.tbl_deep_extend("force", {}, capabilities, cfg.capabilities or {})
					-- NEW: define the config in core
					vim.lsp.config(server_name, cfg)
					-- Do NOT call lspconfig.setup here.
				end,
			},
		})

		-- Finally enable all the servers you've defined
		vim.lsp.enable(vim.tbl_keys(servers))
	end,
}
