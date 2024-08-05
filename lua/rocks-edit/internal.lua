local internal = {}

local nio = require("nio")

---@type rocks-edit.Source[]
local callbacks = {}

local diagnostics_namespace = vim.api.nvim_create_namespace("rocks-edit/diagnostics")

---@param content string
---@return boolean
---@return RocksToml | string
local function try_parse_toml(content)
    local ok, rocks_toml = pcall(require("toml_edit").parse_as_tbl, content)
    if not ok then
        return ok, rocks_toml and tostring(rocks_toml) or "Could not parse rocks.toml"
    end
    for key, tbl in pairs(rocks_toml) do
        if key == "rocks" or key == "plugins" then
            for name, data in pairs(tbl) do
                if type(data) == "string" then
                    ---@type RockSpec
                    rocks_toml[key][name] = {
                        name = name,
                        version = data,
                    }
                else
                    rocks_toml[key][name].name = name
                end
            end
        end
    end
    return ok, rocks_toml
end

---@param callback rocks-edit.Source
function internal.register(callback)
    table.insert(callbacks, callback)
end

function internal.clear_sources()
    callbacks = {}
end

---Used to abort a running check early if check_rocks_toml is invoked again
local abort_trigger = false
local semaphore = nio.control.semaphore(1)

---@param buffer number The buffer ID.
function internal.check_rocks_toml(buffer)
    nio.run(function()
        abort_trigger = true
        semaphore.with(function()
            abort_trigger = false
            vim.diagnostic.reset(diagnostics_namespace, buffer)

            ---@type rocks-edit.Diagnostic[]
            local diagnostics = {}
            local content = table.concat(vim.api.nvim_buf_get_lines(buffer, 0, -1, false), "\n")
            local parse_ok, toml = try_parse_toml(content)
            if not parse_ok then
                ---@cast toml string
                local lnum, col, msg = string.match(toml, "TOML parse error at line (%d+), column (%d+)%s*\n(.*)")
                lnum = lnum and tonumber(lnum) - 1 or 0
                col = col and tonumber(col) - 1 or 0
                local diagnostic_lines = { "TOML parse error" }
                local lines = vim.split(msg or toml, "\n")
                for _, line in ipairs(lines) do
                    if line:find("stack traceback") ~= nil then
                        break
                    end
                    table.insert(diagnostic_lines, line)
                end
                ---@type vim.Diagnostic[]
                table.insert(diagnostics, {
                    message = table.concat(diagnostic_lines, "\n"),
                    severity = vim.diagnostic.severity.ERROR,
                    col = col,
                    end_col = col,
                    lnum = lnum,
                    end_lnum = lnum,
                })
                vim.diagnostic.set(diagnostics_namespace, buffer, diagnostics, {})
                return
            end
            ---@cast toml RocksToml

            local spanned_toml = require("toml_edit").parse_spanned(content)

            ---@param diagnostic rocks-edit.Diagnostic
            local function set(diagnostic)
                if abort_trigger then
                    error("aborted")
                end
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

            pcall(function()
                nio.gather(vim.iter(callbacks)
                    :map(function(callback)
                        return nio.create(function()
                            callback(toml, set)
                        end)
                    end)
                    :totable())
            end)
        end)
    end)
end

return internal
