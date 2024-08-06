---@mod rocks-edit.api rocks-edit.nvim Lua API

local api = {}

local internal = require("rocks-edit.internal")

--- Registers a source for the `rocks-edit` plugin.
--- A source generates diagnostics to be displayed in the `rocks.toml` file.
---@param callback rocks-edit.Source
function api.register(callback)
    internal.register(callback)
end

---@alias rocks-edit.diagnostic.Type vim.diagnostic.Severity

---@alias rocks-edit.diagnostic.Selector
---|"key"
---|"value"
---|number

---@class (exact) rocks-edit.Diagnostic
---@field severity rocks-edit.diagnostic.Type
---@field path string[] A path to the object where the error is occuring. For example: `{ "plugins", "neorg" }`.
---@field selector rocks-edit.diagnostic.Selector What to select from the given path. When `"key"`, the diagnostic will affect the name. When "value", the value is highlighted. A number can be given to select an element from an array via an index.
---@field message string The message to display in the diagnostic.

---@alias rocks-edit.Source fun(toml: RocksToml, set: fun(diagnostic: rocks-edit.Diagnostic))

---@class rocks-edit.Config
---@field builtin_sources table<string, boolean> A list of module paths to invoke that act as sources for `rocks-edit.nvim`.

return api
