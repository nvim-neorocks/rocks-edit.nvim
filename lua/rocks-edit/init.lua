local internal = require("rocks-edit.internal")
local config = require("rocks-edit.config")
local rocks = require("rocks.api")

local rocks_edit = {}

---@param buffer number The buffer ID.
local function is_rocks_toml(buffer)
    local buf_path = vim.uv.fs_realpath(vim.api.nvim_buf_get_name(buffer))
    local rocks_toml_path = vim.uv.fs_realpath(rocks.get_rocks_toml_path())
    return buf_path == rocks_toml_path
end

local function attach_callbacks(buffer)
    local group = vim.api.nvim_create_augroup("rocks-edit.nvim-callbacks", { clear = true })

    vim.api.nvim_create_autocmd(config.get().events, {
        buffer = buffer,
        group = group,
        callback = function()
            rocks_edit.display_diagnostics(buffer)
        end,
    })
end

--- Configures `rocks-edit.nvim` by:
--- - Reading the `rocks.toml` for an `[edit]` section
--- - Parsing the values of `vim.g.rocks_nvim.edit`
function rocks_edit.configure()
    config.configure()
end

--- Displays diagnostics for a given buffer.
---@param buffer? number The buffer ID.
function rocks_edit.display_diagnostics(buffer)
    buffer = buffer or vim.api.nvim_get_current_buf()
    if not is_rocks_toml(buffer) then
        return
    end
    -- Implictly read dynamic configuration (allows for hot-reloading of settings
    -- creating in rocks.toml)
    local ok = pcall(rocks_edit.configure)

    internal.clear_sources()

    local sources = config.get().builtin_sources

    for source, enabled in pairs(sources) do
        if enabled then
            local package_path = "rocks-edit.sources." .. source
            package.loaded[package_path] = nil
            require(package_path)
        end
    end

    if ok then
        attach_callbacks(buffer)
    end
    internal.check_rocks_toml(buffer)
end

return rocks_edit
