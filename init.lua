-------------------
-- P L U G I N S --
-------------------
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  use { 'nvim-telescope/telescope.nvim', tag='0.1.0', requires='nvim-lua/plenary.nvim' }
  use { "akinsho/toggleterm.nvim", tag='*' }
  use 'lewis6991/gitsigns.nvim'
  use 'neovim/nvim-lspconfig'
  use 'feline-nvim/feline.nvim'
  use 'nvim-tree/nvim-web-devicons'
  use { 'nvim-tree/nvim-tree.lua', requires={ 'nvim-tree/nvim-web-devicons' } }

  -- TODO: Figure out why all this is here
  use { "L3MON4D3/LuaSnip", tag="v<CurrentMajor>.*" }
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-cmdline'
  use 'hrsh7th/nvim-cmp'
  use 'saadparwaiz1/cmp_luasnip'
  -- end (figure out)

  use 'mileszs/ack.vim'
  use { "catppuccin/nvim", as="catppuccin" }

  if packer_bootstrap then
    require('packer').sync()
  end
end)

---------------------
-- S E T T I N G S --
---------------------
-------------
-- general --
-------------
vim.cmd("colorscheme catppuccin-macchiato")

-- Fix magenta floating windows
-- TODO: Look into better fix for this
vim.api.nvim_set_hl(0, 'FloatBorder', {bg='#3B4252', fg='#5E81AC'})
vim.api.nvim_set_hl(0, 'NormalFloat', {bg='#3B4252'})
vim.api.nvim_set_hl(0, 'TelescopeNormal', {bg='#3B4252'})
vim.api.nvim_set_hl(0, 'TelescopeBorder', {bg='#3B4252'})

-- TODO: Figure out what this does
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.breakindent = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.number = true
vim.opt.relativenumber = true

-- TODO: Figure out what this does
vim.opt.termguicolors = true

-- TODO: Figure out what this does
vim.opt.completeopt = {'menu', 'menuone', 'noselect'}

-------------
-- keybinds --
-------------
vim.g.mapleader = ' '
vim.keymap.set('n', '<leader>w', ':w<cr>')
vim.keymap.set('i', '<c-c>', '<esc>')
vim.keymap.set('n', '<c-c>', ':noh<cr>')

-------------------------------
-- P L U G I N   C O N F I G --
-------------------------------
---------------
-- telescope --
---------------
-- TODO: Figure out why '+' char appears when tabbing through results
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
require('telescope').setup()

----------------
-- toggleterm --
----------------
require('toggleterm').setup{
  open_mapping=[[<c-l>]],
  direction='float'
}

--------------
-- gitsigns --
--------------
require('gitsigns').setup()

-------------
-- luansip --
-------------
-- TODO: Figure out what luasnip is doing
luasnip = require('luasnip')
require("luasnip.loaders.from_vscode").lazy_load()

--------------
-- nvim-cmp --
--------------
-- TODO: Figoure what this function is for
local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local cmp = require('cmp')
cmp.setup({
  snippet={
    -- TODO: What does this do?
    expand=function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  window={
    completion=cmp.config.window.bordered(),
    documentation=cmp.config.window.bordered(),
  },
  completion={
    -- TODO: What is this for?
    completeopt='menu,menuone,noinsert'
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4)),
    ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4)),
    -- TODO: What does this do?
    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete()),
    -- TODO: What does this do?
    ['<C-e>'] = cmp.mapping.abort(),
    ['<C-n>'] = {
        c = function(fallback)
            local cmp = require('cmp')
            if cmp.visible() then
                cmp.select_next_item()
            else
                fallback()
            end
        end,
    },
    ['<C-p>'] = {
        c = function(fallback)
            local cmp = require('cmp')
            if cmp.visible() then
                cmp.select_prev_item()
            else
                fallback()
            end
        end,
    },
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Tab>'] = function(fallback)
        if cmp.visible() then
            cmp.select_next_item()
        elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
        else
            fallback()
        end
    end,
    ['<S-Tab>'] = function(fallback)
        if cmp.visible() then
            cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
        else
            fallback()
        end
    end,
  }),
  -- TODO: What is this?
  sources=cmp.config.sources({
    { name='nvim_lsp' },
    { name='luasnip' },
  }, {
    { name='buffer' },
  }),
})

---------------
-- lspconfig --
---------------
-- TODO: noremap? silent?
local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)

local on_attach = function(client, bufnr)
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workleader_folders()))
  end, bufopts)
  vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, bufopts)
end

-- TODO: What is this (capabilities)?
local capabilities = require('cmp_nvim_lsp').default_capabilities()

require('lspconfig')['clangd'].setup({
  capabilities=capabilities,
  on_attach=on_attach,
  cmd={ "clangd-12" },
})

require'lspconfig'.sumneko_lua.setup {
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = {'vim'},
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true),
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
    },
  },
  capabilities=capabilities,
  on_attach=on_attach,
}

require('lspconfig')['pyright'].setup({
  capabilities=capabilities,
  on_attach=on_attach,
})

------------
-- feline --
------------
require('feline').setup()

---------------
-- nvim-tree --
---------------
vim.keymap.set('n', 'tt', ':NvimTreeToggle<cr>')
vim.keymap.set('n', 'tf', ':NvimTreeFocus<cr>')
require("nvim-tree").setup()

-------------
-- ack.vim --
-------------
vim.keymap.set('n', '<leader>fa', ':Ack! ')
