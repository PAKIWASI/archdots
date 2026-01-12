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

    -- LazyVim-style key declarations
    keys = {
      { "gd", vim.lsp.buf.definition, desc = "Goto Definition" },
      { "gD", vim.lsp.buf.declaration, desc = "Goto Declaration" },
      { "gr", vim.lsp.buf.references, desc = "References" },
      { "gi", vim.lsp.buf.implementation, desc = "Goto Implementation" },
      { "gy", vim.lsp.buf.type_definition, desc = "Goto Type Definition" },

      { "K", vim.lsp.buf.hover, desc = "Hover" },
      { "gK", vim.lsp.buf.signature_help, desc = "Signature Help" },

      { "<leader>ca", vim.lsp.buf.code_action, desc = "Code Action" },
      { "<leader>cr", vim.lsp.buf.rename, desc = "Rename" },

      { "[d", vim.diagnostic.goto_prev, desc = "Prev Diagnostic" },
      { "]d", vim.diagnostic.goto_next, desc = "Next Diagnostic" },
      { "<leader>cd", vim.diagnostic.open_float, desc = "Line Diagnostics" },

      { "<leader>cf", function()
          vim.lsp.buf.format({ async = true })
        end,
        desc = "Format Buffer",
      },

      -- Trouble
      { "<leader>xx", function() require("trouble").toggle() end, desc = "Trouble" },
      { "<leader>xw", function() require("trouble").toggle("workspace_diagnostics") end, desc = "Workspace Diagnostics" },
      { "<leader>xd", function() require("trouble").toggle("document_diagnostics") end, desc = "Document Diagnostics" },
      { "gR", function() require("trouble").toggle("lsp_references") end, desc = "LSP References" },
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

        ["lua_ls"] = function()
          lspconfig.lua_ls.setup({
            on_attach = on_attach,
            capabilities = capabilities,
            settings = {
              Lua = {
                diagnostics = { globals = { "vim" } },
                workspace = {
                  checkThirdParty = false,
                  library = vim.api.nvim_get_runtime_file("", true),
                },
                telemetry = { enable = false },
              },
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
  },
}
