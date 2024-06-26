local ok, rocks = pcall(require, "rocks.api")

assert(ok, "rocks.nvim is required for `rocks-edit.nvim` to function, please install it!")

if vim.fn.expand("%") == rocks.get_rocks_toml_path() then
    local toml_buffer = vim.api.nvim_get_current_buf()

    require("rocks-edit").display_diagnostics(toml_buffer)
end
