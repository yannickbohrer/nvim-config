--set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- disable the spacebar's default behavior in normal and visual mode
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- for conciseness
local opts = { noremap = true, silent = true }

-- save file
vim.keymap.set("n", "<C-s>", "<cmd> w <CR>", opts)
vim.keymap.set("n", "<leader>sn", "<cmd>noautocmd w <CR>", opts) -- without auto-formatting

-- quit file
vim.keymap.set("n", "<C-q>", "<cmd> q <CR>", opts)

-- move lines up (J) or down (K)
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- delete single char without copying it into copy register
vim.keymap.set("n", "x", '"_x', opts)

-- Vertical scroll
vim.keymap.set("n", "<C-d>", "<C-d>zz", opts)
vim.keymap.set("n", "<C-u>", "<C-u>zz", opts)

-- Find and center
vim.keymap.set("n", "n", "nzzzv", opts)
vim.keymap.set("n", "N", "Nzzzv", opts)

-- buffer navigation
vim.keymap.set("n", "<Tab>", ":bnext<CR>", opts)
vim.keymap.set("n", "<S-Tab>", ":bprevious<CR>", opts)
vim.keymap.set("n", "<leader>x", ":Bdelete!<CR>", opts) -- close buffer
vim.keymap.set("n", "<leader>b", "<cmd> enew <CR>", opts) -- new buffer

-- window management
vim.keymap.set("n", "<leader>v", "<C-w>v", opts) -- split window vertically
vim.keymap.set("n", "<leader>h", "<C-w>s", opts) -- split window horizontally
vim.keymap.set("n", "<leader>se", "<C-w>=", opts) -- make split windows equal width and height
vim.keymap.set("n", "<leader>xs", ":close<CR>", opts) -- close current split window

-- navigation between splits
vim.keymap.set("n", "<Up>", ":wincmd k<CR>", opts)
vim.keymap.set("n", "<Down>", ":wincmd j<CR>", opts)
vim.keymap.set("n", "<Left>", ":wincmd h<CR>", opts)
vim.keymap.set("n", "<Right>", ":wincmd l<CR>", opts)

-- resize splits with arrows
-- vim.keymap.set("n", "", ":resize -2<CR>", opts)
-- vim.keymap.set("n", "", ":resize +2<CR>", opts)
-- vim.keymap.set("n", "", ":vertical resize -2<CR>", opts)
-- vim.keymap.set("n", "", ":vertical resize +2<CR>", opts)

-- toggle line wrapping
vim.keymap.set("n", "<leader>lw", "<cmd>set wrap!<CR>", opts) -- make really long lines visible through wrapping

-- after indenting, stay in visual mode
vim.keymap.set("v", "<", "<gv", opts)
vim.keymap.set("v", ">", ">gv", opts)

-- keep last yanked when pasting
vim.keymap.set("v", "p", '"_d', opts)

-- navigate diagnostics
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "go to previous diagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "go to next diagnostic message" })
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "open floating diagnostic messge" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "open diagnostics list" })
