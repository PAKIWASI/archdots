
-- Floating terminal window config
local Win = {
    style = "terminal",
    position = "float",
    backdrop = 60,
    border = "rounded",
    width = 0.5,
    height = 0.7,
}

-- Clangd LSP config
return {
    mason = false,  -- we handle clangd manually
    cmd = {
        "clangd",
        "--enable-config",
        "--background-index",
        "--clang-tidy",
        "--header-insertion=iwyu",
        "--completion-style=detailed",
        "--fallback-style=llvm",
        "--query-driver=/usr/bin/clang",
    },
    filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
    capabilities = {
        offsetEncoding = { "utf-8", "utf-16" },
    },
    single_file_support = true,

    -- Custom keymaps for clangd
    keys = {
        -- Switch between source/header
        { "<leader>ch", "<cmd>ClangdSwitchSourceHeader<CR>", desc = "Switch Source/Header" },

        -- Create source/header file pair
        {
            "<leader>cc",
            function()
                local ft = vim.bo.filetype
                vim.ui.input({ prompt = "File Name/Class Name: " }, function(input)
                    if input and input ~= "" then
                        if ft == "c" or ft == "h" then
                            Snacks.terminal("Cpair " .. input, { win = Win })
                        else
                            Snacks.terminal("CPPpair " .. input, { win = Win })
                        end
                    end
                end)
            end,
            desc = "Create Source/Header File Pair",
        },

        -- Build project with Ninja
        {
            "<leader>cb",
            function()
                Snacks.terminal("ninja -C build; exec $SHELL", { win = Win })
            end,
            desc = "Build Project (Ninja)",
        },

        -- Run project executable
        {
            "<leader>cx",
            function()
                Snacks.terminal("./build/main; exec $SHELL", { win = Win })
            end,
            desc = "Run Project",
        },

        -- Build and run in one terminal
        {
            "<leader>cX",
            function()
                Snacks.terminal("ninja -C build && ./build/main; exec $SHELL", { win = Win })
            end,
            desc = "Build and Run",
        },
    },
}

