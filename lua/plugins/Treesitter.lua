return {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        require("nvim-treesitter.configs").setup({
            ensure_installed = {
                "bash", "c", "diff", "html", "lua", "luadoc", "markdown",
                "markdown_inline", "query", "vim", "vimdoc", "kotlin",
                "python", "dockerfile", "json", "javascript", "typescript",
                "tsx", "cmake", "cpp", "astro", "css", "go", "java", "php", "sql",
            },
            auto_install = true,
            sync_install = false,
            highlight = {
                enable = true,
            },
            indent = {
                enable = true,
            },
        })
    end,
}
