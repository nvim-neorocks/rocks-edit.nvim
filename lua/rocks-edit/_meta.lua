---@mod rocks-edit.nvim See useful diagnostics right from your rocks.toml

---@toc rocks-edit-contents

---@mod rocks-edit.config rocks-edit.nvim configuration
---
---@brief [[
---You can configure rocks-edit.nvim using a `[edit]` table in your rocks.toml.
---
---Example:
--->toml
---     [edit.builtin_sources]
---     unsynced = true
---     updated = true
---
---     [edit]
---     events = [ "TextChanged", "BufWritePost" ]
---<
---
---@brief ]]

---@class rocks-edit.Config
---
---A list of module paths to invoke that act as sources for `rocks-edit.nvim`.
---@field builtin_sources table<builtin_source, boolean>
---
---@alias builtin_source
---| "unsynced"
---| "updates"
---
---A list of events that trigger a refresh.
---@field events string[]

error("Cannot require a meta module")

local M = {}

return M
