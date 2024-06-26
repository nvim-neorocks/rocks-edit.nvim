local internal = {}

---@type RocksEditSource[]
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

---@param callback RocksEditSource
function internal.register(callback)
    table.insert(callbacks, callback)
end

---@param buffer number The buffer ID.
function internal.check_rocks_toml(buffer)
    local toml = internal.get_toml()

    local spanned_toml = require("toml_edit").parse_spanned(internal.rocks_toml_content())
    ---@type RocksEditDiagnostic[]
    local diagnostics = {}

    ---@param diagnostic RocksEditDiagnostic
    local function set(diagnostic)
        local diagnostic_range = spanned_toml.span_of(diagnostic.path, diagnostic.selector)

        if not diagnostic_range then
            return
        end

        vim.api.nvim_buf_call(buffer, function()
            local range_start = vim.fn.byte2line(diagnostic_range.start)
            local range_end = vim.fn.byte2line(diagnostic_range["end"])

            -- TODO(vhyrro): Calculate remaining bytes to calculate column offsets.
            table.insert(diagnostics, {
                message = diagnostic.message,
                severity = diagnostic.severity,
                col = 0,
                lnum = range_start,
                end_lnum = range_end,
            })

            vim.diagnostic.set(diagnostics_namespace, buffer, diagnostics, {})
        end)

    end

    for _, callback in ipairs(callbacks) do
       callback(toml, set)
    end
end

return internal
