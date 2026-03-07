-- NeoVim offline config
-- Vanilla settings inspired by kickstart.nvim, no plugins required

-- Leader
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Options
vim.o.number = true
vim.o.mouse = 'a'
vim.o.showmode = false
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 500
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.o.inccommand = 'split'
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

-- Use ripgrep for :grep
vim.o.grepprg = 'rg --vimgrep --smart-case'
vim.o.grepformat = '%f:%l:%c:%m'

-- Colorscheme
vim.cmd.colorscheme 'slate'

-- Keymaps
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic quickfix list' })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Split navigation with Ctrl+hjkl
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left split' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower split' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper split' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right split' })

-- Search: grep in cwd (like Telescope <leader>sg)
vim.keymap.set('n', '<leader>sg', function()
  vim.ui.input({ prompt = 'Grep > ' }, function(input)
    if input and input ~= '' then
      vim.cmd('silent! grep! ' .. vim.fn.shellescape(input))
      vim.cmd 'copen'
    end
  end)
end, { desc = 'Search by grep' })

-- Search: find files in cwd (like Telescope <leader>sf)
vim.keymap.set('n', '<leader>sf', function()
  local tmpfile = vim.fn.tempname()

  vim.cmd 'botright new'
  local buf = vim.api.nvim_get_current_buf()
  vim.fn.termopen('rg --files | fzf > ' .. vim.fn.shellescape(tmpfile), {
    on_exit = function(_, code)
      vim.api.nvim_buf_delete(buf, { force = true })
      if code == 0 then
        local result = vim.fn.readfile(tmpfile)
        if #result > 0 and result[1] ~= '' then
          vim.cmd('edit ' .. vim.fn.fnameescape(result[1]))
        end
      end
      vim.fn.delete(tmpfile)
    end,
  })
  vim.cmd 'startinsert'
end, { desc = 'Search files' })

-- Move splits with Ctrl+W+Shift+Arrows
vim.keymap.set('n', '<C-w><S-Up>', '<C-w>K', { desc = 'Move split up' })
vim.keymap.set('n', '<C-w><S-Down>', '<C-w>J', { desc = 'Move split down' })
vim.keymap.set('n', '<C-w><S-Left>', '<C-w>H', { desc = 'Move split left' })
vim.keymap.set('n', '<C-w><S-Right>', '<C-w>L', { desc = 'Move split right' })

-- Diagnostics
vim.diagnostic.config {
  update_in_insert = false,
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = { min = vim.diagnostic.severity.WARN } },
  virtual_text = true,
  virtual_lines = false,
  jump = { float = true },
}

-- Autocommands

-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Restore cursor position
vim.api.nvim_create_autocmd('BufReadPost', {
  desc = 'Restore cursor position',
  group = vim.api.nvim_create_augroup('restore-cursor', { clear = true }),
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Filetype detection
vim.filetype.add {
  filename = {
    ['docker-compose.yml'] = 'yaml.docker-compose',
    ['docker-compose.yaml'] = 'yaml.docker-compose',
    ['compose.yml'] = 'yaml.docker-compose',
    ['compose.yaml'] = 'yaml.docker-compose',
    ['.gitlab-ci.yml'] = 'yaml.gitlab',
  },
  pattern = {
    ['docker%-compose%..*%.yml'] = 'yaml.docker-compose',
    ['docker%-compose%..*%.yaml'] = 'yaml.docker-compose',
    ['compose%..*%.yml'] = 'yaml.docker-compose',
    ['compose%..*%.yaml'] = 'yaml.docker-compose',
    ['.*%.gitlab%-ci%.yml'] = 'yaml.gitlab',
    ['values.*%.yml'] = 'helm',
    ['values.*%.yaml'] = 'helm',
    ['.*%.mdx'] = 'markdown',
  },
}
