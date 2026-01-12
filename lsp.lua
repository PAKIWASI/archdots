-- lsp.lua
-- LazyVim-style LSP stack: mason + lspconfig + trouble
-- Formatting + inlay hints + LazyVim-like keymaps via `keys = {}`

return {
  -- =========================
  -- Mason
  -- =========================
  {
    "williamboman/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUpdate" },
    opts = {
      ui = {
        border = "rounded",
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },

  -- =========================
  -- Mason ↔ LSP bridge
  -- =========================
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        "clangd",
        "pyright",
        "lua_ls",
        "bashls",
        "jsonls",
      },
      automatic_installation = true,
    },
  },

  -- =========================
  -- Core LSP
  -- =========================
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "folke/trouble.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },

    -- Native LSP Configuration
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            'williamboman/mason.nvim',
            'williamboman/mason-lspconfig.nvim',
            'hrsh7th/cmp-nvim-lsp',
        },
        config = function()
            -- Diagnostic configuration
            vim.diagnostic.config({
                virtual_text = true,
                signs = true,
                underline = true,
                update_in_insert = false,
                severity_sort = true,
                float = {
                    border = "rounded",
                    source = "if_many",
                },
            })

            -- Diagnostic signs
            local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
            for type, icon in pairs(signs) do
                local hl = "DiagnosticSign" .. type
                vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
            end

            -- Enhanced capabilities with nvim-cmp
            local capabilities = require('cmp_nvim_lsp').default_capabilities()

            -- On attach function
            local on_attach = function(client, bufnr)
                local function map(mode, lhs, rhs, desc)
                    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
                end

                -- LSP keybindings (LazyVim style)
                map('n', 'gd', function() require('trouble').toggle('lsp_definitions') end, 'Goto Definition')
                map('n', 'gr', function() require('trouble').toggle('lsp_references') end, 'References')
                map('n', 'gI', function() require('trouble').toggle('lsp_implementations') end, 'Goto Implementation')
                map('n', 'gy', function() require('trouble').toggle('lsp_type_definitions') end, 'Goto Type Definition')
                map('n', 'gD', vim.lsp.buf.declaration, 'Goto Declaration')

                map('n', 'K', vim.lsp.buf.hover, 'Hover')
                map('n', 'gK', vim.lsp.buf.signature_help, 'Signature Help')
                map('i', '<C-k>', vim.lsp.buf.signature_help, 'Signature Help')

                -- Code actions
                map({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, 'Code Action')
                map('n', '<leader>cA', function()
                    vim.lsp.buf.code_action({
                        context = {
                            only = { 'source' },
                            diagnostics = {},
                        },
                    })
                end, 'Source Action')

                -- Rename
                map('n', '<leader>cr', vim.lsp.buf.rename, 'Rename')

                -- Format
                map({ 'n', 'v' }, '<leader>cf', function()
                    vim.lsp.buf.format({ async = true })
                end, 'Format')

                -- Diagnostics with vim.diagnostic.jump
                map('n', '<leader>cd', vim.diagnostic.open_float, 'Line Diagnostics')
                map('n', ']d', function()
                    vim.diagnostic.jump({ count = 1, float = true })
                end, 'Next Diagnostic')
                map('n', '[d', function()
                    vim.diagnostic.jump({ count = -1, float = true })
                end, 'Prev Diagnostic')
                map('n', ']e', function()
                    vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR })
                end, 'Next Error')
                map('n', '[e', function()
                    vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR })
                end, 'Prev Error')
                map('n', ']w', function()
                    vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.WARN })
                end, 'Next Warning')
                map('n', '[w', function()
                    vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.WARN })
                end, 'Prev Warning')


                -- Highlight symbol under cursor
                if client.supports_method("textDocument/documentHighlight") then
                    local highlight_group = vim.api.nvim_create_augroup('lsp_document_highlight', { clear = false })
                    vim.api.nvim_clear_autocmds({ buffer = bufnr, group = highlight_group })
                    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                        buffer = bufnr,
                        group = highlight_group,
                        callback = vim.lsp.buf.document_highlight,
                    })
                    vim.api.nvim_create_autocmd("CursorMoved", {
                        buffer = bufnr,
                        group = highlight_group,
                        callback = vim.lsp.buf.clear_references,
                    })
                end
            end

            -- Set default config for all servers
            vim.lsp.config('*', {
                capabilities = capabilities,
            })

            -- Load individual server configs from lsp/ directory
            local lsp_dir = vim.fn.stdpath("config") .. "/lua/lsp"

            -- Check if directory exists
            if vim.fn.isdirectory(lsp_dir) == 1 then
            local handle = vim.loop.fs_scandir(lsp_dir)
                if handle then
                    while true do
                    local name, type = vim.loop.fs_scandir_next(handle)
                    if not name then break end

                        if type == 'file' and name:match('%.lua$') then
                            local server_name = name:gsub("%.lua$", "")
                            local ok, server_config = pcall(require, "lsp." .. server_name)

                            if ok then
                            -- Get default config
                            local default_config = vim.lsp.config[server_name] or {}

                            -- Merge custom config with default config and capabilities
                            local merged_config = vim.tbl_deep_extend('force', {
                                capabilities = capabilities,
                            }, default_config, server_config)

                            -- Set the merged config
                            vim.lsp.config[server_name] = merged_config
                            end
                        end
                    end
                end
            end

            -- Mason LSPConfig setup
            local mason_lspconfig = require('mason-lspconfig')

            -- Ensure these servers are installed
            mason_lspconfig.setup({
                ensure_installed = {
                    'lua_ls',
                },
            })

            -- LspAttach autocmd for keybindings
            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
                callback = function(event)
                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    if client then
                        on_attach(client, event.buf)
                    end
                end,
            })

            -- Enable LSP servers (all from ensure_installed)
            vim.lsp.enable({
                'lua_ls',
            })
        end,
    },

    config = function()
      -- =========================
      -- Capabilities (cmp + inlay hints)
      -- =========================
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
      if ok_cmp then
        capabilities = cmp_lsp.default_capabilities(capabilities)
      end

      -- =========================
      -- on_attach
      -- =========================
      local function on_attach(client, bufnr)
        -- Inlay hints (Neovim ≥ 0.10)
        if client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
          vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end

        -- Formatting
        if client.server_capabilities.documentFormattingProvider then
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format({ bufnr = bufnr })
            end,
          })
        end
      end

      -- =========================
      -- Servers (NO custom settings except lua_ls)
      -- =========================
      local lspconfig = require("lspconfig")

      require("mason-lspconfig").setup_handlers({
        function(server)
          lspconfig[server].setup({
            on_attach = on_attach,
            capabilities = capabilities,
          })
        end,

            {
                '<leader>xQ',
                '<cmd>Trouble qflist toggle<cr>',
                desc = 'Quickfix List (Trouble)',
            },
          })
        end,
      })

      -- =========================
      -- Diagnostics UI (LazyVim-like)
      -- =========================
      vim.diagnostic.config({
        virtual_text = false,
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = {
          border = "rounded",
          source = "always",
        },
      })

      local handlers = vim.lsp.handlers
      handlers["textDocument/hover"] = vim.lsp.with(handlers.hover, { border = "rounded" })
      handlers["textDocument/signatureHelp"] = vim.lsp.with(
        handlers.signature_help,
        { border = "rounded" }
      )
    end,
  },

  -- =========================
  -- Trouble.nvim
  -- =========================
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = {
      auto_close = true,
      auto_open = false,
      use_diagnostic_signs = true,
    },
}
