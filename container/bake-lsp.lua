-- Bake des serveurs Mason en headless : installe chaque paquet et attend la
-- fin réelle via les events par paquet (mason n'a pas d'install bloquant officiel).
-- Le registre doit être rafraîchi avant get_package, d'où le wrap dans refresh().
local reg = require 'mason-registry'

local pkgs = {
  'bash-language-server',
  'docker-language-server',
  'dockerfile-language-server',
  'yaml-language-server',
  'pyright',
  'svelte-language-server',
  'typescript-language-server',
  'marksman',
  'stylua',
  'lua-language-server',
  'markdownlint',
  'prettier',
  'tree-sitter-cli',
  'roslyn',
  'netcoredbg',
}

local pending = 1 -- garde tant que le refresh n'a pas peuplé la liste
local refreshed = false

local function done() pending = pending - 1 end

reg.refresh(vim.schedule_wrap(function()
  for _, name in ipairs(pkgs) do
    local ok, p = pcall(reg.get_package, name)
    if not ok then
      io.stderr:write('WARN paquet mason inconnu: ' .. name .. '\n')
    elseif not p:is_installed() then
      pending = pending + 1
      p:once('install:success', done)
      p:once('install:failed', function()
        io.stderr:write('ECHEC install: ' .. name .. '\n')
        done()
      end)
      p:install()
    end
  end
  done() -- libère la garde
  refreshed = true
  print('mason: ' .. pending .. ' installation(s) en cours')
end))

vim.wait(900000, function() return refreshed and pending == 0 end, 500)
print 'mason: termine'
vim.cmd 'qa!'
