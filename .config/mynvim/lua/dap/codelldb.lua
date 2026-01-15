
local dap = require("dap")

-- ----------------------
-- Adapter
-- ----------------------
dap.adapters.codelldb = {
    type = "server",
    port = "${port}",
    executable = {
        command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
        args = { "--port", "${port}" },
    },
}

-- ----------------------
-- Default C/C++/Rust Configs
-- ----------------------
local default_cpp_rust = {
    {
        name = "Launch",
        type = "codelldb",
        request = "launch",
        program = function()
            return vim.fn.input("Path to executable: ", vim.loop.cwd() .. "/build/main", "file")
        end,
        cwd = vim.loop.cwd(),
        stopOnEntry = false,
        args = function()
            return vim.split(vim.fn.input("Program arguments: "), " ", { trimempty = true })
        end,
    },
    {
        name = "Launch with AddressSanitizer",
        type = "codelldb",
        request = "launch",
        program = function()
            return vim.fn.input("Path to executable: ", vim.loop.cwd() .. "/build/main", "file")
        end,
        cwd = vim.loop.cwd(),
        stopOnEntry = false,
        args = function()
            return vim.split(vim.fn.input("Program arguments: "), " ", { trimempty = true })
        end,
        env = {
            ASAN_OPTIONS = "detect_leaks=1:halt_on_error=1:abort_on_error=1:detect_stack_use_after_return=1",
        },
    },
    {
        name = "Attach to Process",
        type = "codelldb",
        request = "attach",
        pid = require("dap.utils").pick_process,
        cwd = vim.loop.cwd(),
    },
}

dap.configurations.cpp = default_cpp_rust
dap.configurations.c = default_cpp_rust
dap.configurations.rust = default_cpp_rust

-- ----------------------
-- ASM Configs
-- ----------------------
dap.configurations.asm = {
    {
        name = "Launch ASM (Current File)",
        type = "codelldb",
        request = "launch",
        program = function()
            local fname = vim.fn.expand("%:t:r")
            return vim.loop.cwd() .. "/" .. fname
        end,
        cwd = vim.loop.cwd(),
        stopOnEntry = true,
        args = function()
            return vim.split(vim.fn.input("Program arguments: "), " ", { trimempty = true })
        end,
    },
    {
        name = "Launch ASM (Custom Binary)",
        type = "codelldb",
        request = "launch",
        program = function()
            return vim.fn.input("Path to executable: ", vim.loop.cwd() .. "/", "file")
        end,
        cwd = vim.loop.cwd(),
        stopOnEntry = true,
        args = function()
            return vim.split(vim.fn.input("Program arguments: "), " ", { trimempty = true })
        end,
    },
}

-- ----------------------
-- DAP UI Setup (ENHANCED)
-- ----------------------
local dapui_ok, dapui = pcall(require, "dapui")
if dapui_ok then
    dapui.setup({
        icons = { 
            expanded = "▾", 
            collapsed = "▸",
            current_frame = "▸"
        },
        mappings = {
            -- Use a table to apply multiple mappings
            expand = { "<CR>", "<2-LeftMouse>" },
            open = "o",
            remove = "d",
            edit = "e",
            repl = "r",
            toggle = "t",
        },
        element_mappings = {},
        expand_lines = true,
        layouts = {
            {
                elements = {
                    { id = "scopes", size = 0.4 },
                    { id = "breakpoints", size = 0.2 },
                    { id = "stacks", size = 0.2 },
                    { id = "watches", size = 0.2 },
                },
                size = 50,
                position = "left",
            },
            {
                elements = {
                    { id = "repl", size = 0.5 },
                    { id = "console", size = 0.5 },
                },
                size = 12,
                position = "bottom",
            },
        },
        controls = {
            enabled = true,
            element = "repl",
            icons = {
                pause = "⏸",
                play = "▶",
                step_into = "⬇",
                step_over = "⬆",
                step_out = "⬅",
                step_back = "↶",
                run_last = "🔁",
                terminate = "⏹",
                disconnect = "⏏",
            },
        },
        floating = { 
            border = "rounded",
            mappings = {
                close = { "q", "<Esc>" },
            },
        },
        windows = { indent = 1 },
        render = {
            max_type_length = nil,
            max_value_lines = 100,
        },
    })

    -- Auto open/close DAP UI
    dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
    end
end

-- ----------------------
-- Virtual Text (inline values)
-- ----------------------
local dap_virtual_text_ok, dap_virtual_text = pcall(require, "nvim-dap-virtual-text")
if dap_virtual_text_ok then
    dap_virtual_text.setup({
        enabled = true,
        enabled_commands = true,
        highlight_changed_variables = true,
        highlight_new_as_changed = false,
        show_stop_reason = true,
        commented = false,
        only_first_definition = true,
        all_references = false,
        clear_on_continue = false,
        display_callback = function(variable, _, _, _, options)
            if options.virt_text_pos == 'inline' then
                return ' = ' .. variable.value
            else
                return variable.name .. ' = ' .. variable.value
            end
        end,
        virt_text_pos = vim.fn.has 'nvim-0.10' == 1 and 'inline' or 'eol',
        all_frames = false,
        virt_lines = false,
        virt_text_win_col = nil
    })
end

-- ----------------------
-- Better Breakpoint Signs
-- ----------------------
vim.fn.sign_define('DapBreakpoint', {
    text = '●',
    texthl = 'DapBreakpoint',
    linehl = '',
    numhl = 'DapBreakpoint'
})

vim.fn.sign_define('DapBreakpointCondition', {
    text = '◆',
    texthl = 'DapBreakpoint',
    linehl = '',
    numhl = 'DapBreakpoint'
})

vim.fn.sign_define('DapBreakpointRejected', {
    text = '○',
    texthl = 'DapBreakpoint',
    linehl = '',
    numhl = 'DapBreakpoint'
})

vim.fn.sign_define('DapLogPoint', {
    text = '◉',
    texthl = 'DapLogPoint',
    linehl = '',
    numhl = 'DapLogPoint'
})

vim.fn.sign_define('DapStopped', {
    text = '▶',
    texthl = 'DapStopped',
    linehl = 'DapStoppedLine',
    numhl = 'DapStopped'
})

-- ----------------------
-- Highlight Groups
-- ----------------------
vim.api.nvim_set_hl(0, 'DapBreakpoint', { fg = '#e51400' })
vim.api.nvim_set_hl(0, 'DapLogPoint', { fg = '#61afef' })
vim.api.nvim_set_hl(0, 'DapStopped', { fg = '#98c379' })
vim.api.nvim_set_hl(0, 'DapStoppedLine', { bg = '#2e3440' })

-- ----------------------
-- Enhanced Keymaps
-- ----------------------
local map = function(lhs, rhs, desc)
    vim.keymap.set("n", "<leader>d" .. lhs, rhs, { silent = true, desc = desc })
end

-- Session control
map("c", dap.continue, "Continue/Start")
map("s", dap.terminate, "Stop/Terminate")
map("r", dap.restart, "Restart")
map("p", dap.pause, "Pause")

-- Stepping
map("n", dap.step_over, "Step Over")
map("i", dap.step_into, "Step Into")
map("o", dap.step_out, "Step Out")
map("O", dap.step_back, "Step Back")

-- Breakpoints
map("b", dap.toggle_breakpoint, "Toggle Breakpoint")
map("B", function() 
    dap.set_breakpoint(vim.fn.input("Breakpoint condition: ")) 
end, "Conditional Breakpoint")
map("L", function() 
    dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: ")) 
end, "Log Point")
map("x", dap.clear_breakpoints, "Clear All Breakpoints")

-- UI
map("u", function() 
    if dapui_ok then dapui.toggle() end 
end, "Toggle DAP UI")
map("e", function() 
    if dapui_ok then dapui.eval() end 
end, "Eval Expression")
map("E", function() 
    if dapui_ok then dapui.eval(vim.fn.input("Expression: ")) end 
end, "Eval Custom Expression")
map("h", function() 
    if dapui_ok then require("dap.ui.widgets").hover() end 
end, "Hover Variables")

-- Session
map("l", dap.run_last, "Run Last Session")
map("R", function() 
    if dapui_ok then dapui.open({reset = true}) end 
end, "Reset UI")

-- REPL
map("t", dap.repl.toggle, "Toggle REPL")

-- Process
map("P", require("dap.utils").pick_process, "Pick Process")



