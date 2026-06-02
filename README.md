# Neovim Config

Personal Neovim configuration by Yannick Bohrer. Built on [lazy.nvim](https://github.com/folke/lazy.nvim) with a focus on a clean IDE-like experience for Python, Java, C, C++, and Bash development.

**Self-bootstrapping** — a fresh `rm -rf ~/.local/share/nvim && nvim .` installs everything automatically.

---

## Requirements

- Neovim 0.12+
- [Nerd Font](https://www.nerdfonts.com/) (icons throughout the UI)
- `git`, `make`, `node` (for some Mason packages)
- Java 21+ (for `jdtls`; detected automatically from `JAVA_HOME` or Homebrew)
- `go` in PATH is optional — `gopls` skips installation gracefully if absent

---

## Structure

```
init.lua                   entry point — loads core/ then bootstraps lazy.nvim
lua/
  core/
    env.lua                PATH injection (mason/bin + Java); must run first
    options.lua            editor options (tabs, clipboard, line numbers, etc.)
    keymaps.lua            all non-plugin keymaps; leader = <Space>
    terminal.lua           floating terminal toggle (<C-t>)
  plugins/
    Alpha.lua              dashboard on startup
    Autocompletion.lua     nvim-cmp + LuaSnip + copilot source
    Autoformatting.lua     none-ls formatters + format-on-save
    Bufferline.lua         tab bar for open buffers
    Colortheme.lua         kanagawa (active) + vscode.nvim (loaded, inactive)
    Copilot.lua            copilot.lua + CopilotChat
    Gitsigns.lua           git change indicators in the sign column
    Lsp.lua                LSP servers via Mason + native vim.lsp API
    Lualine.lua            statusline
    Neotree.lua            file explorer (right side, width 40)
    Telescope.lua          fuzzy finder
    Treesitter.lua         syntax highlighting + indentation
    vim-tmux-navigator.lua seamless navigation between nvim splits and tmux panes
claude-testing-grounds/    test files for verifying LSP + formatting per language
```

---

## Language Support

All five languages are verified working: LSP attaches, diagnostics appear, and format-on-save runs on every `:w`.

| Language   | LSP server | Formatter            |
|------------|------------|----------------------|
| Python     | `pyright` + `ruff` | `ruff_format`   |
| Java       | `jdtls`    | `google-java-format` |
| C          | `clangd`   | `clang-format`       |
| C++        | `clangd`   | `clang-format`       |
| Bash       | `bashls`   | `shfmt`              |

Everything is auto-installed by Mason on first launch — no manual steps needed.

**Format-on-save** fires on `BufWritePre`, which covers `:w`, `<C-s>`, and any other write command. Use `<leader>sn` to save without formatting.

---

## Keymaps

Leader key: `<Space>`

### Files & Buffers

| Key | Action |
|-----|--------|
| `<C-s>` | Save |
| `<C-q>` | Quit |
| `<leader>sn` | Save without formatting |
| `<Tab>` / `<S-Tab>` | Next / previous buffer |
| `<leader>x` | Close buffer |
| `<leader>b` | New buffer |

### Navigation

| Key | Action |
|-----|--------|
| `<C-t>` | Toggle floating terminal (50%×50%, bottom-right) |
| `<leader>e` | Toggle file explorer (Neo-tree, right) |
| `\` | Reveal current file in Neo-tree |
| Arrow keys | Navigate between splits |
| `<leader>h` / `<leader>v` | Split vertical / horizontal |

### Search (Telescope)

| Key | Action |
|-----|--------|
| `<leader>sf` | Find files |
| `<leader>sg` | Live grep |
| `<leader>sw` | Grep current word |
| `<leader>sd` | Diagnostics |
| `<leader>sh` | Help tags |
| `<leader>sk` | Keymaps |
| `<leader>sr` | Resume last search |
| `<leader>s.` | Recent files |
| `<leader><leader>` | Open buffers |
| `<leader>/` | Fuzzy find in current buffer |

### LSP

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | References |
| `gI` | Implementation |
| `gD` | Declaration |
| `<leader>D` | Type definition |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |
| `<leader>ds` | Document symbols |
| `<leader>ws` | Workspace symbols |
| `<leader>ch` | Switch header/source (C/C++) |
| `[d` / `]d` | Previous / next diagnostic |
| `<leader>d` | Open diagnostic float |

### Completion (insert mode)

| Key | Action |
|-----|--------|
| `<C-n>` / `<C-p>` | Next / previous suggestion |
| `<C-y>` | Accept suggestion |
| `<C-Space>` | Trigger completion |
| `<C-b>` / `<C-f>` | Scroll docs |
| `<C-l>` / `<C-h>` | Jump forward / backward in snippet |

### Copilot

| Key | Action |
|-----|--------|
| `<leader>cc` | Toggle CopilotChat |
| `<leader>ce` | Explain selected code (visual mode) |

---

## Colorscheme

**Kanagawa** (wave variant, transparent background) is active. `vscode.nvim` is also loaded but does not apply.

Lualine theme can be switched via the `NVIM_THEME` environment variable: `kanagawa` (default) or `onedark`.

---

## Known Non-Issues

- `gopls` fails to install when `go` is not in PATH — expected and non-fatal
- `denols` and `ts_ls` are both configured — `denols` only activates when `deno.json` / `deno.jsonc` exists at the project root
- jdtls prints harmless JVM warnings on startup (`incubator modules`, `sun.misc.Unsafe`) — not errors
- `[LSP][null-ls] timeout` on first Java file open — jdtls JVM cold-start; formatting works fine after that and on all subsequent saves
- Both kanagawa and vscode.nvim run their `config` functions on startup — only kanagawa calls `vim.cmd.colorscheme`
