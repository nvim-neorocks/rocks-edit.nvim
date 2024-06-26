local nio = require("nio")

require("rocks-edit.api").register(function(_, diagnostic)
    nio.run(function()
        local updates = require("rocks.state").outdated_rocks()

        for name, data in pairs(updates) do
            diagnostic({
                message = string.format("update available: `%s` -> `%s`", data.version, data.target_version),
                path = { "plugins", name },
                selector = "key",
                severity = vim.diagnostic.severity.INFO,
            })
        end
    end)
end)
