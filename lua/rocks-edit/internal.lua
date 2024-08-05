local internal = {}

---@type rocks-edit.Source[]
local callbacks = {}

local diagnostics_namespace = vim.api.nvim_create_namespace("rocks-edit/diagnostics")

function internal.rocks_toml_content()
    -- TODO(vhyrro): Refactor to use the path of the current buffer instead -
    -- no need to check the toml path twice.
    return table.concat(vim.fn.readfile(require("rocks.api").get_rocks_toml_path()), "\n")
end

function internal.get_toml()
    return require("rocks.api").get_rocks_toml()
end

---@param callback rocks-edit.Source
function internal.register(callback)
    table.insert(callbacks, callback)
end

function internal.clear_sources()
    callbacks = {}
end

---@param buffer number The buffer ID.
function internal.check_rocks_toml(buffer)
    vim.diagnostic.reset(diagnostics_namespace, buffer)

    local toml = internal.get_toml()

    local spanned_toml = require("toml_edit").parse_spanned(internal.rocks_toml_content())
    ---@type rocks-edit.Diagnostic[]
    local diagnostics = {}

    ---@param diagnostic rocks-edit.Diagnostic
    local function set(diagnostic)
        local diagnostic_range = spanned_toml.span_of(diagnostic.path, diagnostic.selector)

        if not diagnostic_range then
            return
        end

        vim.api.nvim_buf_call(buffer, function()
            local range_start = vim.fn.byte2line(diagnostic_range.start + 1)
            local range_end = vim.fn.byte2line(diagnostic_range["end"] + 1)

            local col_start = diagnostic_range.start - vim.fn.line2byte(range_start)
            local col_end = diagnostic_range["end"] - vim.fn.line2byte(range_end)

            table.insert(diagnostics, {
                message = diagnostic.message,
                severity = diagnostic.severity,
                col = col_start + 1,
                end_col = col_end + 1,
                lnum = range_start - 1,
                end_lnum = range_end - 1,
            })

            vim.diagnostic.set(diagnostics_namespace, buffer, diagnostics, {})
        end)
    end

    for _, callback in ipairs(callbacks) do
        callback(toml, set)
    end
end

return internal
