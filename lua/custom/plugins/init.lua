-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information

-- From @bdub
local function is_previous_char_whitespace()
  -- get the current cursor position
  local _, col = unpack(vim.api.nvim_win_get_cursor(0))
  if col == 0 then
    return false
  end
  -- get the previous character
  local line = vim.api.nvim_get_current_line()
  local prev_char = line:sub(col, col)
  -- Check if the previous character is a whitespace
  return prev_char:match '%s' ~= nil
end

local highlight_under_cursor = function()
  local current_word = vim.fn.expand '<cword>'
  local found = vim.fn.search(current_word, 'nw')

  if found == 0 then
    error 'word not found'
  else
    -- highlight the word and set as search register
    vim.fn.setreg('/', current_word)
    vim.cmd 'set hlsearch'
    require('hlslens').start()

    -- if previous character is alphaneueric, hit the "b" key to go back one word
    local isPreviousCharWhitespace = is_previous_char_whitespace()
    if not isPreviousCharWhitespace then
      vim.cmd 'normal! b'
    end
  end
end

local nvim_lsp = require 'lspconfig'

vim.g.markdown_fenced_languages = { 'ts=typescript' }
nvim_lsp.denols.setup {
  on_attach = on_attach,
  root_dir = nvim_lsp.util.root_pattern('deno.json', 'deno.jsonc'),
}

nvim_lsp.pyright.setup {
  settings = {
    python = {
      analysis = {
        typeCheckingMode = 'basic',
        autoSeachPaths = true,
        useLibraryCodeForTypes = true,
      },
    },
  },
}

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

vim.keymap.set('n', '<leader>gd', vim.lsp.buf.definition, { desc = '[G]oto [D]efinition' })
vim.keymap.set('n', '<leader>gi', vim.lsp.buf.implementation, { desc = '[G]oto [I]mplementation' })
vim.keymap.set('n', '<leader>gt', vim.lsp.buf.type_definition, { desc = '[G]oto [T]ype Definition' })
vim.keymap.set('n', '<leader>gr', vim.lsp.buf.references, { desc = '[G]oto [R]eferences' })
vim.keymap.set('n', '*', highlight_under_cursor, { desc = 'Highlight word under cursor' })

-- Iterate over all Lua files in the plugins directory and load them
local plugins_dir = vim.fs.joinpath(vim.fn.stdpath 'config', 'lua', 'custom', 'plugins')
for file_name, type in vim.fs.dir(plugins_dir, { follow = true }) do
  if (type == 'file' or type == 'link') and file_name:match '%.lua$' and file_name ~= 'init.lua' then
    local module = file_name:gsub('%.lua$', '')
    require('custom.plugins.' .. module)
  end
end

return {}
