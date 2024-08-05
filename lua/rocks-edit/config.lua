local config = {}

---@type rocks-edit.Config
local default_config = {
    builtin_sources = {
        unsynced = true,
        updates = true,
    },
    events = {
        "BufWritePost",
        "TextChanged",
    },
}

local current_config = vim.deepcopy(default_config)

function config.configure_from_table(tbl)
    current_config = vim.tbl_deep_extend("force", default_config, tbl)
end

function config.validate_sources(sources)
    for name, value in pairs(sources) do
        if type(name) ~= "string" or type(value) ~= "boolean" or not default_config.builtin_sources[name] then
            return false
        end
    end

    return true
end

--- Quickly verifies a configuration. Full checks are performed in the healthcheck.
---@param conf rocks-edit.Config
function config.validate(conf)
    vim.validate({
        sources = {
            conf.builtin_sources,
            config.validate_sources,
            "invalid list of sources provided. Run `:checkhealth rocks-edit.nvim` for more information.",
        },
    })
end

function config.configure()
    local toml = require("rocks.api").get_rocks_toml()

    if toml.edit then
        config.configure_from_table(toml.edit)
    end

    if vim.g.rocks_nvim.edit then
        config.configure_from_table(vim.g.rocks_nvim.edit)
    end

    config.validate(current_config)
end

function config.default()
    return default_config
end

function config.get()
    return current_config
end

return config
