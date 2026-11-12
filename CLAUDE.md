# Neovim Config — CLAUDE.md

## Overview

Personal Neovim config for **Yannick Bohrer**, located at `~/.config/nvim`.
Plugin manager: **lazy.nvim** (stable branch, auto-bootstrapped in `init.lua`).
All plugins live under `lua/plugins/`, each file returns a lazy.nvim plugin spec.
Core settings (non-plugin) live under `lua/core/`.

---

## Directory Structure

```
init.lua                        -- entry point: loads core/env first, then rest of core/, then lazy
lua/
  core/
    env.lua                     -- MUST be first: injects mason/bin + JAVA_HOME into PATH
                                --   respects shell JAVA_HOME; falls back to homebrew openjdk 25→21→latest
                                --   ensures nvim works when launched from GUI, tmux, or any non-shell context
    options.lua                 -- vim options (tabs=4, clipboard=unnamedplus, no relative numbers, etc.)
    keymaps.lua                 -- all non-plugin keymaps; leader = <Space>
    terminal.lua                -- floating terminal toggle on <C-t> (50%×50%, bottom-right)
  plugins/
    Alpha.lua                   -- dashboard (goolord/alpha-nvim, startify theme, custom ASCII header)
    Autocompletion.lua          -- nvim-cmp + LuaSnip + friendly-snippets + copilot-cmp source
    Autoformatting.lua          -- none-ls (null-ls fork) + mason-null-ls, format-on-save via BufWritePre
    Bufferline.lua              -- akinsho/bufferline.nvim + vim-bbye; <Tab>/<S-Tab> cycle, <leader>x close
    Colortheme.lua              -- kanagawa.nvim (wave, transparent=true, ACTIVE) + vscode.nvim (loaded but inactive)
    Copilot.lua                 -- copilot.lua (suggestion/panel disabled, uses cmp) + CopilotChat (<leader>cc toggle)
    Gitsigns.lua                -- lewis6991/gitsigns, +/~/_ symbols
    Lsp.lua                     -- nvim-lspconfig + mason + mason-lspconfig + fidget + clangd_extensions
    Lualine.lua                 -- statusline; theme switchable via $NVIM_THEME env var (kanagawa|onedark)
    Neotree.lua                 -- neo-tree v3, position=right, width=40; <leader>e toggle, \ reveal
    Telescope.lua               -- telescope 0.1.x + fzf-native + ui-select; extensive <leader>s* keymaps
    Treesitter.lua              -- nvim-treesitter master branch, auto_install=true
    vim-tmux-navigator.lua      -- christoomey/vim-tmux-navigator, lazy=false
```

---

## Language Support (Python · Java · C · C++ · Bash)

Fully verified working as of 2026-06-02. All binaries confirmed present in `~/.local/share/nvim/mason/bin/`.

### LSP (`lua/plugins/Lsp.lua`)

Uses `vim.lsp.config()` + `vim.lsp.enable()` (native API introduced in Nvim 0.11, not the old `lspconfig.setup()` style).
`mason-lspconfig` with `ensure_installed = vim.tbl_keys(servers)` auto-installs all LSPs.

| Language   | Server          | Notes                                                                 |
|------------|-----------------|-----------------------------------------------------------------------|
| Python     | `pyright`       | typeCheckingMode=basic, autoImportCompletion, openFilesOnly diagnostics |
| Java       | `jdtls`         | per-project workspace at `stdpath("data")/jdtls-workspace/<dirname>`; built-in format disabled (handled by none-ls) |
| C / C++    | `clangd`        | filetypes: c, cpp, objc, objcpp, cuda; clang-tidy, iwyu, detailed completion, fallback-style=llvm; `<leader>ch` switches header/source |
| Bash       | `bashls`        | standard                                                              |

Also configured (not primary target languages): `ts_ls`, `denols`, `eslint`, `tailwindcss`, `cssls`, `html`, `jsonls`, `yamlls`, `lua_ls`, `angularls`, `gopls`, `rust_analyzer`, `ruff` (LSP), `kotlin_language_server`.

**Note:** `gopls` will fail to install if `go` is not in PATH — expected, non-fatal.
**Note:** `pylsp` was removed and replaced with `pyright`. Do not re-add `pylsp`.
**Note:** pyright auto-detects the project venv in `before_init`: `$VIRTUAL_ENV` → `<root>/.venv` → `<root>/venv`, so imports resolve without activating the venv first. Ruff's hover is disabled on attach (pyright owns hover) and pyright's organize-imports is disabled (ruff owns it).
**Note:** jdtls requires Java 21+. `env.lua` respects `JAVA_HOME` if set by the shell; otherwise detects homebrew openjdk in descending order (25→21→latest). Do not use Java 17 — jdtls fails at the OSGi bundle level regardless of `--no-validate-java-version`.
**Note:** In Nvim 0.12+, use `client:supports_method()` (colon syntax). The dot syntax `client.supports_method()` is deprecated. Both `Lsp.lua` and `Autoformatting.lua` use the correct colon form.

Capabilities: `cmp_nvim_lsp.default_capabilities()` merged into all servers. `offsetEncoding = utf-16` set globally (required by clangd).

### Formatters (`lua/plugins/Autoformatting.lua`)

Plugin: `nvimtools/none-ls.nvim` + `nvimtools/none-ls-extras.nvim` + `jayp0521/mason-null-ls.nvim`.
Format-on-save: `BufWritePre` autocmd registered per-buffer in null-ls `on_attach`. Fires on every `:w`, `<C-s>`, or any write command. Use `<leader>sn` (`noautocmd w`) to skip.

| Language   | Formatter            | Mason package        |
|------------|----------------------|----------------------|
| Python     | `ruff_format`        | `ruff` (via none-ls-extras: `require("none-ls.formatting.ruff_format")`) |
| Java       | `google_java_format` | `google-java-format` |
| C / C++    | `clang_format`       | `clang-format` (filetypes: c, cpp, cs, java, cuda, proto) |
| Bash       | `shfmt`              | `shfmt`              |

Also active: `prettier` (JS/TS/CSS/HTML/JSON/YAML/Markdown), `stylua` (Lua), `ktlint` (Kotlin), `checkmake` (Makefile diagnostics).

**Important:** The mason package is `"prettier"`, not `"prettierd"`. `prettierd` is not a valid mason package name. The none-ls source uses `formatting.prettier`, not `formatting.prettierd`.

### Treesitter (`lua/plugins/Treesitter.lua`)

`auto_install = true`. Explicitly listed: bash, c, cpp, python, java, typescript, tsx, javascript, lua, html, css, json, yaml, go, kotlin, cmake, dockerfile, sql, astro, markdown, vim, vimdoc, diff, query.

---

## Completion (`lua/plugins/Autocompletion.lua`)

`nvim-cmp` with sources (in priority order): copilot → lazydev (group_index=0) → nvim_lsp → luasnip → path.

Key mappings: `<C-n>`/`<C-p>` select, `<C-y>` confirm, `<C-Space>` trigger, `<C-b>`/`<C-f>` scroll docs, `<C-l>`/`<C-h>` snippet jump.

---

## Copilot (`lua/plugins/Copilot.lua`)

- `copilot.lua`: suggestion/panel disabled — completions flow through nvim-cmp via `copilot-cmp`
- `CopilotChat.nvim`: `<leader>cc` toggle, `<leader>ce` explain selection (visual mode)

---

## Colorscheme (`lua/plugins/Colortheme.lua`)

Active: **kanagawa** wave, `transparent = true`. Both kanagawa and vscode.nvim are loaded (`lazy=false, priority=1000`) but only kanagawa sets `vim.cmd.colorscheme`.
Lualine theme switches via `$NVIM_THEME` env var (`kanagawa` default, `onedark` alternative).

---

## Testing

Test files live in `claude-testing-grounds/`:
- `test.py` — Python (classes, type hints)
- `Test.java` — Java (class with main)
- `test.c` — C (structs, malloc/free, stdio)
- `test.cpp` — C++ (polymorphism, smart pointers)
- `test.ts` — TypeScript (interface, class)
- `test.sh` — Bash (strict mode, functions, arrays)

To verify a language: open the file in nvim, wait a few seconds, run `:LspInfo` to confirm attachment, make a formatting change, and `:w` to confirm format-on-save fires.

---

## Clean Install Guarantee

`rm -rf ~/.local/share/nvim && nvim .` produces a fully working install:
- **lazy.nvim** auto-bootstraps from GitHub on first launch
- **lazy** installs all plugins from pinned `lazy-lock.json` commits
- **mason-lspconfig** `ensure_installed` auto-installs all LSP servers
- **mason-null-ls** `ensure_installed` auto-installs all formatters
- **nvim-treesitter** `auto_install = true` installs parsers on first file open
- **`lua/core/env.lua`** injects mason/bin + Java into PATH before any plugin loads, so everything works even before mason has run once AND in GUI/non-shell launch contexts

---

## Known Non-Issues

- `gopls` install fails if `go` is not in PATH — expected, non-fatal
- `denols` and `ts_ls` both configured — `denols` only activates when `deno.json`/`deno.jsonc` exists in root
- `pylsp` package may remain in `~/.local/share/nvim/mason/packages/` from before migration — it is not loaded
- Both kanagawa and vscode.nvim configs run at startup — only kanagawa applies the colorscheme
- jdtls prints harmless JVM warnings on startup (`incubator modules`, `sun.misc.Unsafe`) — these are not errors
- `[LSP][null-ls] timeout` on first Java file open — jdtls JVM cold-start only; formatting works on all subsequent saves
