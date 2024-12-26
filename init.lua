vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.guicursor = ""
vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.smartindent = true
vim.opt.clipboard = "unnamedplus"
vim.opt.undofile = true

vim.cmd [[packadd packer.nvim]]

require('packer').startup(function(use)
        use {"windwp/nvim-autopairs", as = 'nvim-autopair'} 
        use { 'wbthomason/packer.nvim'}
        use { 'rose-pine/neovim', as = 'rose-pine' }
        use 'nvim-treesitter/nvim-treesitter' 
        use 'unblevable/quick-scope'
        use {'nvim-telescope/telescope.nvim', tag = '0.1.3', requires = { {'nvim-lua/plenary.nvim'} } }
        use 'neovim/nvim-lspconfig'

        -- Autocomplete
        use 'hrsh7th/nvim-cmp'
        use 'hrsh7th/cmp-nvim-lsp'
        -- Snippets
        use 'L3MON4D3/LuaSnip'
end)


-- Autopairs config
local npairs = require("nvim-autopairs")
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
local cmp = require("cmp")
npairs.setup {}
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())


-- Treesitter config
require('nvim-treesitter.configs').setup({
        ensure_installed = { "lua", "javascript", "html", "css", "rust" }, -- Adicione suas linguagens
        highlight = { enable = true }, -- Ativa destaque de sintaxe
        indent = { enable = true }     -- Ativa indentação baseada em sintaxe
})


-- Rose pine config
require('rose-pine').setup({
        disable_background = true,
        disable_float_background = true,
        variant = 'moon'
})
vim.cmd('colorscheme rose-pine')


-- QuickScope config
vim.g.qs_enable = 1 -- Ativa o QuickScope por padrão
vim.g.qs_highlight_on_keys = { 'f', 'F', 't', 'T' } -- Realça ao pressionar estas teclas
vim.cmd [[
  highlight QuickScopePrimary guifg='#afff5f' gui=bold ctermfg=155 cterm=bold
  highlight QuickScopeSecondary guifg='#5fffff' gui=bold ctermfg=81 cterm=bold
]]


-- Telescope config
require('telescope').setup({
        defaults = {
                file_ignore_patterns = { "node_modules", ".git/" }, -- Ignorar arquivos/pastas
                layout_config = {
                        prompt_position = "top",
                },
                sorting_strategy = "ascending", -- Resultados ordenados
        }
})
-- Mapeamentos básicos
vim.api.nvim_set_keymap('n', '<leader>ff', "<cmd>Telescope find_files<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>fg', "<cmd>Telescope live_grep<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>fb', "<cmd>Telescope buffers<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>fh', "<cmd>Telescope help_tags<cr>", { noremap = true, silent = true })


-- Lsp config
local lspconfig = require('lspconfig')

-- Lua-language-server
lspconfig.lua_ls.setup {
    settings = {
        Lua = {
            runtime = {
                -- Reconhece Lua 5.1 (ou mude para a versão que você usa)
                version = 'LuaJIT',
                path = vim.split(package.path, ';'),
            },
            diagnostics = {
                -- Reconhece o `vim` como uma variável global
                globals = { 'vim' },
            },
            workspace = {
                -- Faz o servidor reconhecer o Neovim runtime files
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false, -- Evita mensagens de pacote 3rd-party
            },
            telemetry = {
                enable = false, -- Desabilita o envio de dados para o servidor
            },
        },
    },
}


-- Rust language-server
lspconfig.rust_analyzer.setup({
    on_attach = function(client, bufnr)
        -- Set LSP-specific keybindings
        local opts = { noremap = true, silent = true }
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>rn', '<Cmd>lua vim.lsp.buf.rename()<CR>', opts)
    end,
    settings = {
        ["rust-analyzer"] = {
            cargo = {
                allFeatures = true, -- Build with all Cargo features enabled
            },
            checkOnSave = {
                command = "clippy", -- Run `cargo clippy` for linting on save
            },
        },
    },
})

-- Autocomplete config
local cmp = require('cmp')
cmp.setup({
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
    }),
})

-- keymaps
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to definition' })
vim.keymap.set('n', 'gr', vim.lsp.buf.references, { desc = 'Find references' })
vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'Hover documentation' })
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'Rename symbol' })
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code action' })

