-- plugins/init.lua - lazy.nvim bootstrap and plugin list

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Plugin specs
require("lazy").setup({
    -- LSP
    require("plugins.lsp"),
    -- Autocompletion
    require("plugins.cmp"),
    -- Telescope
    require("plugins.telescope"),
    -- Treesitter
    require("plugins.treesitter"),
    -- UI
    require("plugins.ui"),
}, {
    install = {
        colorscheme = { "tokyonight" },
    },
    checker = {
        enabled = false,
    },
    performance = {
        rtp = {
            disabled_plugins = {
                "gzip",
                "matchit",
                "matchparen",
                "netrwPlugin",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
            },
        },
    },
})
