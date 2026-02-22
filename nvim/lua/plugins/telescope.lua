-- plugins/telescope.lua - Fuzzy finder

return {
    {
        "nvim-telescope/telescope.nvim",
        branch = "0.1.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                build = "make",
            },
        },
        cmd = "Telescope",
        keys = {
            { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find files" },
            { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Live grep" },
            { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Buffers" },
            { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Help tags" },
            { "<leader>fr", "<cmd>Telescope oldfiles<CR>", desc = "Recent files" },
            { "<leader>fc", "<cmd>Telescope git_commits<CR>", desc = "Git commits" },
            { "<leader>fs", "<cmd>Telescope git_status<CR>", desc = "Git status" },
            { "<leader>/", "<cmd>Telescope current_buffer_fuzzy_find<CR>", desc = "Search in buffer" },
        },
        config = function()
            local telescope = require("telescope")

            telescope.setup({
                defaults = {
                    file_ignore_patterns = {
                        "node_modules",
                        ".git/",
                        "vendor/",
                        "__pycache__",
                        "%.pyc",
                    },
                    layout_config = {
                        horizontal = { preview_width = 0.55 },
                        vertical = { mirror = false },
                    },
                    mappings = {
                        i = {
                            ["<C-j>"] = "move_selection_next",
                            ["<C-k>"] = "move_selection_previous",
                        },
                    },
                },
                pickers = {
                    find_files = {
                        hidden = true,
                    },
                },
            })

            -- Load fzf extension
            pcall(telescope.load_extension, "fzf")
        end,
    },
}
