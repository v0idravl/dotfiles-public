-- ── Options ────────────────────────────────────────────────────
vim.opt.number         = true
vim.opt.relativenumber = true
vim.opt.cursorline     = true
vim.opt.showcmd        = true
vim.opt.wildmenu       = true
vim.opt.scrolloff      = 5
vim.opt.colorcolumn    = '80'

vim.opt.tabstop        = 4
vim.opt.shiftwidth     = 4
vim.opt.expandtab      = true
vim.opt.autoindent     = true

vim.opt.ignorecase     = true
vim.opt.smartcase      = true
vim.opt.incsearch      = true
vim.opt.hlsearch       = true

vim.opt.wrap           = false
vim.opt.backspace      = 'indent,eol,start'
vim.opt.clipboard      = 'unnamedplus'
vim.opt.mouse          = 'a'

vim.opt.hidden         = true
vim.opt.backup         = false
vim.opt.writebackup    = false
vim.opt.updatetime     = 300
vim.opt.undofile       = true
local undodir          = vim.fn.stdpath('data') .. '/undo'
vim.fn.mkdir(undodir, 'p')
vim.opt.undodir        = undodir

vim.opt.laststatus     = 2
vim.opt.termguicolors  = true

-- ── Keymaps ────────────────────────────────────────────────────
vim.g.mapleader = ' '

vim.keymap.set('n', '<leader>w',  ':w<CR>')
vim.keymap.set('n', '<leader>q',  ':q<CR>')
vim.keymap.set('n', '<leader>/',  ':nohlsearch<CR>')
vim.keymap.set('i', 'jk',         '<Esc>')

-- Telescope
vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<CR>')
vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<CR>')
vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<CR>')
vim.keymap.set('n', '<leader>fr', '<cmd>Telescope oldfiles<CR>')

-- LSP — buffer-local once a server attaches, so no-LSP buffers stay clean
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local map = function(lhs, rhs, desc)
      vim.keymap.set('n', lhs, rhs, { buffer = ev.buf, desc = desc })
    end
    map('gd',         vim.lsp.buf.definition,  'definition')
    map('K',          vim.lsp.buf.hover,       'hover')
    map('<leader>rn', vim.lsp.buf.rename,      'rename')
    map('<leader>ca', vim.lsp.buf.code_action, 'code action')
    map('[d',         vim.diagnostic.goto_prev, 'prev diagnostic')
    map(']d',         vim.diagnostic.goto_next, 'next diagnostic')
  end,
})

-- ── lazy.nvim bootstrap ────────────────────────────────────────
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({ 'git', 'clone', '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- ── Plugins ────────────────────────────────────────────────────
require('lazy').setup({

  -- colorscheme — swap theme: wave / dragon / lotus
  {
    'rebelot/kanagawa.nvim',
    lazy     = false,
    priority = 1000,
    -- dragon palette with the background floor lowered to the terminal's
    -- near-black (#0d0d0d) so nvim, alacritty, tmux, and waybar are one surface.
    -- transparent: no painted bg — alacritty's 0.95 opacity shows through
    opts     = {
      theme       = 'dragon',
      transparent = true,
      colors = { theme = { dragon = { ui = { bg = '#0d0d0d' } } } },
    },
  },

  -- fuzzy finder
  {
    'nvim-telescope/telescope.nvim', tag = '0.1.8',
    dependencies = { 'nvim-lua/plenary.nvim' },
  },

  -- LSP server UI (:Mason) — install servers interactively
  { 'williamboman/mason.nvim', config = true },

  -- keybinding popup — pause after <leader> to see available keys
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    config = function()
      local wk = require('which-key')
      wk.setup({ delay = 500 })
      wk.add({
        { '<leader>f', group = 'find' },
        { '<leader>ff', desc = 'files' },
        { '<leader>fg', desc = 'grep' },
        { '<leader>fb', desc = 'buffers' },
        { '<leader>fr', desc = 'recent' },
        { '<leader>w',  desc = 'write' },
        { '<leader>q',  desc = 'quit' },
        { '<leader>/',  desc = 'clear search' },
        { '<leader>rn', desc = 'lsp rename' },
        { '<leader>ca', desc = 'lsp code action' },
      })
    end,
  },

  -- completion
  {
    'hrsh7th/nvim-cmp',
    lazy         = false,
    dependencies = {
      { 'hrsh7th/cmp-nvim-lsp', lazy = false },
      'hrsh7th/cmp-buffer',
    },
    config = function()
      local cmp  = require('cmp')
      local caps = require('cmp_nvim_lsp').default_capabilities()

      vim.lsp.config.pylsp = {
        cmd          = { 'pylsp' },
        filetypes    = { 'python' },
        root_markers = { 'pyproject.toml', 'setup.py', 'requirements.txt', '.git' },
        capabilities = caps,
      }
      vim.lsp.enable('pylsp')

      cmp.setup({
        completion = { autocomplete = false }, -- manual only: <C-Space>
        mapping = cmp.mapping.preset.insert({
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>']      = cmp.mapping.confirm({ select = true }),
          ['<Tab>']     = cmp.mapping.select_next_item(),
          ['<S-Tab>']   = cmp.mapping.select_prev_item(),
        }),
        sources = {
          { name = 'nvim_lsp' },
          { name = 'buffer' },
        },
      })
    end,
  },

}, {})

-- theme mode: theme-set writes dragon/redlight to ~/.local/state/theme/mode
-- and live-switches running instances over their sockets; this picks the
-- right scheme at startup. redlight.vim (colors/) is plugin-free, so it
-- works even if lazy.nvim hasn't installed kanagawa yet.
local mode_file = (vim.env.XDG_STATE_HOME or (vim.fn.expand('~/.local/state'))) .. '/theme/mode'
local f = io.open(mode_file, 'r')
local mode = f and f:read('*l') or 'dragon'
if f then f:close() end
if mode == 'redlight' then
  vim.cmd.colorscheme('redlight')
else
  vim.cmd.colorscheme('kanagawa-dragon')
end
