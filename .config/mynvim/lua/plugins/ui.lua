return {

    -- statusline (lua line)
    {
        'nvim-lualine/lualine.nvim',
        dependencies = {
            'nvim-tree/nvim-web-devicons',
            'lewis6991/gitsigns.nvim', -- Required for git diff
        },
        opts = {
            options = {
                theme = 'auto',
                component_separators = { left = '', right = '' },
                section_separators = { left = '', right = '' },
            },
            sections = {
                lualine_a = {
                    { 'mode', separator = { left = '' }, right_padding = 2 }
                },
                lualine_b = {
                    'branch',
                    {
                        'diff',
                        symbols = { added = ' ', modified = ' ', removed = ' ' },
                        colored = true,
                    },
                },
                lualine_c = {
                    'filetype',
                    {
                        'filename',
                        path = 1, -- Relative path
                        symbols = {
                            modified = '[+]',
                            readonly = '[-]',
                            unnamed = '[No Name]',
                        }
                    }
                },
                lualine_x = {
                    -- TODO: why doesnto work?
                    --[[{
                        require("utils.macro_recording"),
                        separator = { left = '' },
                        right_padding = 2,
                    },--]]
                    require("utils.macro_recording"),
                    {
                        'diagnostics',
                        sources = { 'nvim_diagnostic' }, -- modern source
                        symbols = {
                            error = ' ',
                            warn  = ' ',
                            info  = ' ',
                            hint  = ' ',
                        },
                        colored = true,
                        update_in_insert = false,
                        separator = { right = '' },
                        left_padding = 2,
                    },
                },
                lualine_y = { 'progress' },
                lualine_z = {
                    { 'location', separator = { right = '' }, left_padding = 2 },
                },
            },
            inactive_sections = {
                lualine_a = { 'filename' },
                lualine_b = {},
                lualine_c = {},
                lualine_x = {},
                lualine_y = {},
                lualine_z = { 'location' },
            },
        },
    },

    -- bufferline
    {
        "akinsho/bufferline.nvim",
        version = "*",
        event = "VeryLazy",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        keys = {
            { "<S-h>",      "<cmd>BufferLineCyclePrev<CR>",  desc = "Prev buffer" },
            { "<S-l>",      "<cmd>BufferLineCycleNext<CR>",  desc = "Next buffer" },
            { "<leader>br", "<Cmd>BufferLineCloseRight<CR>", desc = "Delete Buffers to the Right" },
            { "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>",  desc = "Delete Buffers to the Left" },
            { "[b",         "<cmd>BufferLineMovePrev<cr>",   desc = "Move buffer prev" },
            { "]b",         "<cmd>BufferLineMoveNext<cr>",   desc = "Move buffer next" },
        },
        opts = {
            options = {
                diagnostics = "nvim_lsp",

                show_close_icon = false,
                show_buffer_close_icons = false,

                always_show_bufferline = false,

                separator_style = "slope",

                offsets = { -- TODO: more settings?
                    {
                        filetype = "oil",
                        text = "Oil",
                        highlight = "Directory",
                        text_align = "left",
                        separator = true,
                    },
                },
            },
        },
        config = function(_, opts)
            require("bufferline").setup(opts)
        end,
    },

    -- which key
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts_extend = { "spec" },
        opts = {
            preset = "helix", -- or "modern"
            defaults = {},
            spec = {
                {
                    mode = { "n", "v" },
                    { "<leader>c", group = "code" },
                    { "<leader>d", group = "debug" },
                    { "<leader>f", group = "file/find" },
                    { "<leader>g", group = "git" },
                    { "<leader>q", group = "quit/session" },
                    { "<leader>s", group = "search" },
                    { "<leader>u", group = "ui" },
                    { "<leader>x", group = "diagnostics/quickfix" },
                    { "[",         group = "prev" },
                    { "]",         group = "next" },
                    { "g",         group = "goto" },
                    { "z",         group = "fold" },
                    {
                        "<leader>b",
                        group = "buffer",
                        expand = function()
                            return require("which-key.extras").expand.buf()
                        end,
                    },
                    {
                        "<leader>w",
                        group = "windows",
                        proxy = "<c-w>",
                        expand = function()
                            return require("which-key.extras").expand.win()
                        end,
                    },
                },
            },
        },
        keys = {
            {
                "<leader>?",
                function()
                    require("which-key").show({ global = false })
                end,
                desc = "Buffer Keymaps (which-key)",
            },
            {
                "<c-w><space>",
                function()
                    require("which-key").show({ keys = "<c-w>", loop = true })
                end,
                desc = "Window Hydra Mode (which-key)",
            },
        },
        config = function(_, opts)
            local wk = require("which-key")
            wk.setup(opts)
        end,
    }
}
