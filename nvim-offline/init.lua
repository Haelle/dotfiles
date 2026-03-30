-- NeoVim offline config
-- Vanilla settings inspired by kickstart.nvim, no plugins required

-- Leader
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Options
vim.o.termguicolors = true
vim.o.number = true
vim.o.mouse = 'a'
vim.o.showmode = false
vim.o.laststatus = 2
vim.o.statusline = '%{%v:lua.Statusline()%}'

function Statusline()
  local modes = {
    n = { '  NORMAL ', 'StatusNormal' },
    i = { '  INSERT ', 'StatusInsert' },
    v = { '  VISUAL ', 'StatusVisual' },
    V = { '  V-LINE ', 'StatusVisual' },
    ['\22'] = { '  V-BLOCK ', 'StatusVisual' },
    c = { '  COMMAND ', 'StatusCommand' },
    t = { '  TERMINAL ', 'StatusTerminal' },
    R = { '  REPLACE ', 'StatusReplace' },
  }
  local mode = vim.fn.mode()
  local m = modes[mode] or { '  ' .. mode .. ' ', 'StatusNormal' }
  return '%#' .. m[2] .. '#' .. m[1] .. '%#StatusLine# %f %m%r%= %l:%c  %p%% '
end

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
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)

-- Use ripgrep for :grep
vim.o.grepprg = 'rg --vimgrep --smart-case'
vim.o.grepformat = '%f:%l:%c:%m'

-- Colorscheme
vim.cmd.colorscheme 'slate'

-- Statusline highlights (after colorscheme to avoid being overwritten)
vim.api.nvim_set_hl(0, 'StatusNormal', { fg = '#1e1e2e', bg = '#89b4fa', ctermfg = 0, ctermbg = 12, bold = true })
vim.api.nvim_set_hl(0, 'StatusInsert', { fg = '#1e1e2e', bg = '#a6e3a1', ctermfg = 0, ctermbg = 10, bold = true })
vim.api.nvim_set_hl(0, 'StatusVisual', { fg = '#1e1e2e', bg = '#cba6f7', ctermfg = 0, ctermbg = 13, bold = true })
vim.api.nvim_set_hl(0, 'StatusCommand', { fg = '#1e1e2e', bg = '#fab387', ctermfg = 0, ctermbg = 11, bold = true })
vim.api.nvim_set_hl(0, 'StatusTerminal', { fg = '#1e1e2e', bg = '#94e2d5', ctermfg = 0, ctermbg = 14, bold = true })
vim.api.nvim_set_hl(0, 'StatusReplace', { fg = '#1e1e2e', bg = '#f38ba8', ctermfg = 0, ctermbg = 9, bold = true })

-- File explorer (netrw as sidebar tree)
vim.g.netrw_banner = 1
vim.g.netrw_liststyle = 3
vim.g.netrw_winsize = 25
vim.o.focusevents = false

-- Keymaps
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })
vim.keymap.set('n', '<C-s>', '<cmd>w<CR>', { desc = 'Quick save file [N]ormal mode' })
vim.keymap.set('i', '<C-s>', '<cmd>w<CR>', { desc = 'Quick save file [I]nsert mode' })
vim.keymap.set('n', '\\', function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == 'netrw' then
      vim.api.nvim_win_close(win, true)
      return
    end
  end
  vim.cmd '20Lexplore'
end, { desc = 'Toggle file explorer' })
vim.keymap.set('n', '<leader>sn', '<cmd>vsplit $MYVIMRC<CR>', { desc = 'Open neovim config' })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Split navigation with Ctrl+hjkl
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left split' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower split' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper split' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right split' })

-- Search: keymaps via fzf (only custom keymaps with descriptions)
vim.keymap.set('n', '<leader>sk', function()
  local tmpfile = vim.fn.tempname()
  local srcfile = vim.fn.tempname()

  local lines = {}
  for _, mode in ipairs { 'n', 'i', 'v', 't' } do
    for _, km in ipairs(vim.api.nvim_get_keymap(mode)) do
      if km.desc and km.desc ~= '' and not km.desc:match '^Nvim builtin' then
        local lhs = km.lhs:gsub(' ', '<Space>')
        table.insert(lines, string.format('[%s] %-20s %s', mode, lhs, km.desc))
      end
    end
  end
  vim.fn.writefile(lines, srcfile)

  vim.cmd 'botright new'
  local buf = vim.api.nvim_get_current_buf()
  vim.fn.termopen('cat ' .. vim.fn.shellescape(srcfile) .. ' | fzf > ' .. vim.fn.shellescape(tmpfile), {
    on_exit = function(_, _)
      vim.api.nvim_buf_delete(buf, { force = true })
      vim.fn.delete(srcfile)
      vim.fn.delete(tmpfile)
    end,
  })
  vim.cmd 'startinsert'
end, { desc = 'Search keymaps' })

-- Grep via rg + fzf, then jump to selected result
-- utility function for Go to Reference and Search Grep
local function fzf_grep(query)
  local tmpfile = vim.fn.tempname()

  vim.cmd 'botright new'
  local buf = vim.api.nvim_get_current_buf()
  vim.fn.termopen('rg --vimgrep --smart-case ' .. vim.fn.shellescape(query) .. ' | fzf > ' .. vim.fn.shellescape(tmpfile), {
    on_exit = function(_, code)
      vim.api.nvim_buf_delete(buf, { force = true })
      if code == 0 then
        local result = vim.fn.readfile(tmpfile)
        if #result > 0 and result[1] ~= '' then
          local file, line, col = result[1]:match '^(.+):(%d+):(%d+):'
          if file then
            vim.cmd('edit +' .. line .. ' ' .. vim.fn.fnameescape(file))
            pcall(vim.api.nvim_win_set_cursor, 0, { tonumber(line), tonumber(col) - 1 })
          end
        end
      end
      vim.fn.delete(tmpfile)
    end,
  })
  vim.cmd 'startinsert'
end

-- Go to references / search word under cursor
local function grep_cword()
  local word = vim.fn.expand '<cword>'
  if word ~= '' then fzf_grep(word) end
end
vim.keymap.set('n', 'gr', grep_cword, { desc = 'Go to references' })
vim.keymap.set('n', '<leader>sw', grep_cword, { desc = 'Search word under cursor' })

-- Search: grep with prompt
vim.keymap.set('n', '<leader>sg', function()
  vim.ui.input({ prompt = 'Grep > ' }, function(input)
    if input and input ~= '' then fzf_grep(input) end
  end)
end, { desc = 'Search by grep' })

-- Search: TODOs in cwd
vim.keymap.set('n', '<leader>st', function()
  local tmpfile = vim.fn.tempname()

  vim.cmd 'botright new'
  local buf = vim.api.nvim_get_current_buf()
  vim.fn.termopen('rg --vimgrep "TODO|FIXME|HACK|NOTE" | fzf > ' .. vim.fn.shellescape(tmpfile), {
    on_exit = function(_, code)
      vim.api.nvim_buf_delete(buf, { force = true })
      if code == 0 then
        local result = vim.fn.readfile(tmpfile)
        if #result > 0 and result[1] ~= '' then
          local file, line, col = result[1]:match '^(.+):(%d+):(%d+):'
          if file then
            vim.cmd('edit +' .. line .. ' ' .. vim.fn.fnameescape(file))
            pcall(vim.api.nvim_win_set_cursor, 0, { tonumber(line), tonumber(col) - 1 })
          end
        end
      end
      vim.fn.delete(tmpfile)
    end,
  })
  vim.cmd 'startinsert'
end, { desc = 'Search TODOs' })

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
        if #result > 0 and result[1] ~= '' then vim.cmd('edit ' .. vim.fn.fnameescape(result[1])) end
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

-- Autocompletion (buffer words)
vim.o.completeopt = 'menuone,noselect'
vim.keymap.set('i', '<C-Space>', '<C-x><C-n>', { desc = 'Complete buffer words' })
vim.keymap.set('i', '<Tab>', function() return vim.fn.pumvisible() == 1 and '<C-n>' or '<Tab>' end, { expr = true, desc = 'Next completion item' })
vim.keymap.set('i', '<S-Tab>', function() return vim.fn.pumvisible() == 1 and '<C-p>' or '<S-Tab>' end, { expr = true, desc = 'Previous completion item' })
vim.keymap.set('i', '<Right>', function() return vim.fn.pumvisible() == 1 and '<C-n>' or '<Right>' end, { expr = true, desc = 'Next completion item' })
vim.keymap.set('i', '<Left>', function() return vim.fn.pumvisible() == 1 and '<C-p>' or '<Left>' end, { expr = true, desc = 'Previous completion item' })

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

-- Toggle comment (gcc for line, gc for visual selection)
local function toggle_comment(line, cs)
  local prefix, suffix = cs:match '^(.-)%%s(.-)$'
  prefix, suffix = vim.trim(prefix), vim.trim(suffix)
  local pat = '^(%s*)' .. vim.pesc(prefix) .. ' ?(.*)'
  if suffix ~= '' then pat = '^(%s*)' .. vim.pesc(prefix) .. ' ?(.*)%s?' .. vim.pesc(suffix) end
  local indent, rest = line:match(pat)
  if indent then
    return indent .. rest
  else
    local ws, content = line:match '^(%s*)(.*)'
    if suffix ~= '' then
      return ws .. prefix .. ' ' .. content .. ' ' .. suffix
    else
      return ws .. prefix .. ' ' .. content
    end
  end
end

vim.keymap.set('n', 'gcc', function()
  local cs = vim.bo.commentstring
  if cs == '' or not cs:find '%%s' then return end
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
  vim.api.nvim_buf_set_lines(0, row - 1, row, false, { toggle_comment(line, cs) })
end, { desc = 'Toggle comment line' })

vim.keymap.set('v', 'gc', function()
  local cs = vim.bo.commentstring
  if cs == '' or not cs:find '%%s' then return end
  local start = vim.fn.line 'v'
  local finish = vim.fn.line '.'
  if start > finish then
    start, finish = finish, start
  end
  local lines = vim.api.nvim_buf_get_lines(0, start - 1, finish, false)
  for i, line in ipairs(lines) do
    lines[i] = toggle_comment(line, cs)
  end
  vim.api.nvim_buf_set_lines(0, start - 1, finish, false, lines)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)
end, { desc = 'Toggle comment selection' })

-- Git signs (added/modified/deleted lines in sign column)
vim.fn.sign_define('GitAdded', { text = '+', texthl = 'GitAdded' })
vim.fn.sign_define('GitChanged', { text = '~', texthl = 'GitChanged' })
vim.fn.sign_define('GitDeleted', { text = '-', texthl = 'GitDeleted' })
vim.api.nvim_set_hl(0, 'GitAdded', { fg = '#a6e3a1', ctermfg = 10 })
vim.api.nvim_set_hl(0, 'GitChanged', { fg = '#89b4fa', ctermfg = 12 })
vim.api.nvim_set_hl(0, 'GitDeleted', { fg = '#f38ba8', ctermfg = 9 })

local function update_git_signs(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  vim.fn.sign_unplace('gitsigns', { buffer = buf })
  local filepath = vim.api.nvim_buf_get_name(buf)
  if filepath == '' then return end

  vim.fn.jobstart({ 'git', 'diff', '--no-color', '-U0', '--', filepath }, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if not data then return end
      local id = 1
      for _, line in ipairs(data) do
        -- Parse hunk headers: @@ -old,count +new,count @@
        local new_start, new_count = line:match '^@@ %-%d+,?%d* %+(%d+),?(%d*) @@'
        if new_start then
          new_start = tonumber(new_start)
          new_count = tonumber(new_count) or 1
          -- Check if old side has 0 lines (pure addition) or new side has 0 lines (pure deletion)
          local old_count = line:match '^@@ %-(%d+),?(%d*)'
          old_count = tonumber(select(2, line:match '^@@ %-(%d+),?(%d*)')) or 1
          if new_count == 0 then
            -- Pure deletion: mark the line just before
            local mark_line = math.max(1, new_start)
            vim.fn.sign_place(id, 'gitsigns', 'GitDeleted', buf, { lnum = mark_line })
            id = id + 1
          elseif old_count == 0 then
            -- Pure addition
            for i = 0, new_count - 1 do
              vim.fn.sign_place(id, 'gitsigns', 'GitAdded', buf, { lnum = new_start + i })
              id = id + 1
            end
          else
            -- Modification
            for i = 0, new_count - 1 do
              vim.fn.sign_place(id, 'gitsigns', 'GitChanged', buf, { lnum = new_start + i })
              id = id + 1
            end
          end
        end
      end
    end,
  })
end

vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufWritePost' }, {
  desc = 'Update git diff signs',
  group = vim.api.nvim_create_augroup('git-signs', { clear = true }),
  callback = function(args) update_git_signs(args.buf) end,
})

-- Autocommands

-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function() vim.highlight.on_yank() end,
})

-- Restore cursor position
vim.api.nvim_create_autocmd('BufReadPost', {
  desc = 'Restore cursor position',
  group = vim.api.nvim_create_augroup('restore-cursor', { clear = true }),
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= line_count then pcall(vim.api.nvim_win_set_cursor, 0, mark) end
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
