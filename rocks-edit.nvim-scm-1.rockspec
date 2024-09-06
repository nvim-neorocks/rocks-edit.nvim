-- NOTE: This rockspec is used for running busted tests only,
-- not for publishing to LuaRocks.org

local _MODREV, _SPECREV = "scm", "-1"
rockspec_format = "3.0"
package = "rocks-edit.nvim"
version = _MODREV .. _SPECREV

dependencies = {
    "lua >= 5.1",
    "nvim-nio ~> 1",
    "rocks.nvim >= 2.35.0",
    "toml-edit >= 0.4.1",
}

test_dependencies = {
    "lua >= 5.1",
    "nlua",
}

source = {
    url = "git://github.com/nvim-neorocks/" .. package,
}

build = {
    type = "builtin",
    copy_directories = {
        "ftplugin",
    },
}
