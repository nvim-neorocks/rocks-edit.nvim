local internal = require("rocks-edit.internal")

local rocks_edit = {}

--- Displays diagnostics for a given buffer.
---@param buffer number The buffer ID.
function rocks_edit.display_diagnostics(buffer)
    -- TODO(vhyrro): Make configurable
    local sources = { "unsynced", "updates" }

    for _, source in ipairs(sources) do
        require("rocks-edit.sources." .. source)
    end

    internal.check_rocks_toml(buffer)

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

            internal.check_rocks_toml(buffer)
        end,
    })
end

return rocks_edit
