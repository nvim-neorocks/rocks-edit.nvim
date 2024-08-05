local config = require("rocks-edit.config")

local health = {}

function health.check()
    config.configure()

    local current_config = config.get()
    local default_config = config.default()

    local has_error = false

    for name, _ in pairs(current_config) do
        if name ~= "builtin_sources" then
            vim.health.warn(string.format("Unknown key '%s' found in the configuration table.", name), {
                "Remove the key from your config, it doesn't serve any function.",
                "If the key was a typo, amend it to get the desired result.",
            })
            has_error = true
        end
    end

    for name, value in pairs(current_config.builtin_sources) do
        if not default_config.builtin_sources[name] then
            vim.health.error(
                string.format("Invalid source '%s' specified.", name),
                "The sources table is designed for builtin sources only. External sources should be enabled automatically."
            )
            has_error = true
        elseif type(value) ~= "boolean" then
            vim.health.error(
                string.format("Invalid value for source '%s'.", name),
                "Set the value either to `true` (to have the source enabled) or `false` (to disable the source)."
            )
            has_error = true
        end
    end

    if not has_error then
        vim.health.ok("No problems found!")
    end
end

return health
