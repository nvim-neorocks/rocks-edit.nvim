---@meta

---@module "rocks.api"

---@alias RocksEditDiagnosticType vim.diagnostic.Severity

---@alias RocksEditDiagnosticSelector
---|"name"
---|"value"
---|number

---@class (exact) RocksEditDiagnostic
---@field severity RocksEditDiagnosticType
---@field path string[] A path to the object where the error is occuring. For example: `{ "plugins", "neorg" }`.
---@field selector RocksEditDiagnosticSelector What to select from the given path. When `"name"`, the diagnostic will affect the name. When "value", the value is highlighted. A number can be given to select an element from an array via an index.
---@field message string The message to display in the diagnostic.

---@alias RocksEditSource fun(toml: RocksToml, set: fun(RocksEditDiagnostic))

---@class RocksEditConfig
---@field sources table<string, boolean> A list of module paths to invoke that act as sources for `rocks-edit.nvim`.
