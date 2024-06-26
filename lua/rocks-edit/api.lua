local internal = require("rocks-edit.internal")

local api = {}

--- Registers a source for the `rocks-edit` plugin.
--- A source generates diagnostics to be displayed in the `rocks.toml` file.
---@param callback RocksEditSource
function api.register(callback)
    internal.register(callback)
end

return api
