



-- indent width 2 for html, css
vim.api.nvim_create_autocmd("FileType", {
    pattern = {"html", "css"},
    callback = function()
        vim.bo.tabstop = 2
        vim.bo.shiftwidth = 2
        vim.bo.softtabstop = 2
    end,
    desc = "Indent 2 for HTML, CSS",
})


-- highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function ()
        vim.highlight.on_yank()
    end,
    desc = "Highlight on Yank",
})


-- commom lsp keymaps
vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
        local opts = { buffer = args.buf }
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', '<leader>cr', vim.lsp.buf.rename, opts)
        vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', '<leader>cf', vim.lsp.buf.format, opts)
    end,
})


-- Show cmdline when entering command mode
vim.api.nvim_create_autocmd("CmdlineEnter", {
    callback = function()
        vim.o.cmdheight = 1
    end,
    desc = "Show command line on command mode",
})
-- Hide cmdline when leaving command mode
vim.api.nvim_create_autocmd("CmdlineLeave", {
    callback = function()
        vim.o.cmdheight = 0
    end,
    desc = "Hide command line after command mode",
})


