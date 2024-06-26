-- NOTE: This rockspec is used for running busted tests only,
-- not for publishing to LuaRocks.org

local _MODREV, _SPECREV = 'scm', '-1'
rockspec_format = '3.0'
package = 'rocks-edit.nvim'
version = _MODREV .. _SPECREV

dependencies = {
  'lua >= 5.1',
  'toml-edit >= 4.0',
}

test_dependencies = {
  'lua >= 5.1',
}

source = {
  url = 'git://github.com/nvim-neorocks/' .. package,
}

build = {
  type = 'builtin',
  -- TODO: Add runtime diretories here
  -- copy_directories = {
      -- 'doc',
      -- "plugin",
  -- },
}
