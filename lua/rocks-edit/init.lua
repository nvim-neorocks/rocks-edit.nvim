local internal = require("rocks-edit.internal")
local config = require("rocks-edit.config")

local rocks_edit = {}

local function attach_callbacks(buffer)
    local group = vim.api.nvim_create_augroup("rocks-edit.nvim", { clear = true })
    local modified

    vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = buffer,
        group = group,
        callback = function()
            -- The `modified` variable cannot be checked after
            -- the buffer has been written, so we check here instead.
            modified = vim.bo[buffer].modified
        end,
    })

    vim.api.nvim_create_autocmd("BufWritePost", {
        buffer = buffer,
        group = group,
        callback = function()
            if not modified then
                return
            end

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
---@param buffer number The buffer ID.
function rocks_edit.display_diagnostics(buffer)
    -- Implictly read dynamic configuration (allows for hot-reloading of settings
    -- creating in rocks.toml)
    rocks_edit.configure()

    internal.clear_sources()

    local sources = config.get().builtin_sources

    for source, enabled in pairs(sources) do
        if enabled then
            local package_path = "rocks-edit.sources." .. source
            package.loaded[package_path] = nil
            require(package_path)
        end
    end

    attach_callbacks(buffer)
    internal.check_rocks_toml(buffer)
end

return rocks_edit
