



-- commom write/quit
vim.keymap.set( {'n','v'},     '<leader>q',  '<cmd>q<CR>',  { desc = 'Quit Buffer'   } )
vim.keymap.set( {'n','v'},     '<leader>qq', '<cmd>q!<CR>', { desc = 'Force Quit'    } )
vim.keymap.set( {'n','v','i'}, '<C-s>', function ()
        if vim.bo.modified then
            vim.cmd("write")
        end
    end,
    { desc = 'Write Changes' }
)


-- split
-- C-w v vertical
-- C-w s horizontal
-- C-w = equalize

-- split navigation
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")


-- clear search highlight
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')



-- terminal
--vim.keymap.set({'n', 'v'}, "<C-/>", function () Snacks.terminal() end, { desc = "Open Floating Terminal"})
--map("n", "<leader>fT", function() Snacks.terminal() end, { desc = "Terminal (cwd)" })
--map("n", "<leader>ft", function() Snacks.terminal(nil, { cwd = LazyVim.root() }) end, { desc = "Terminal (Root Dir)" })
--map({"n","t"}, "<c-/>",function() Snacks.terminal(nil, { cwd = LazyVim.root() }) end, { desc = "Terminal (Root Dir)" })

-- Stay in visual mode after indenting
vim.keymap.set('v', '<', '<gv', { desc = 'Indent left and reselect' })
vim.keymap.set('v', '>', '>gv', { desc = 'Indent right and reselect' })

