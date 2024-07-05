local nio = require("nio")

require("rocks-edit.api").register(function(toml, diagnostic)
    nio.run(function()
        local updates = require("rocks.state").outdated_rocks()

        for name, data in pairs(updates) do
            if toml.plugins[name] then
                -- Compare the versions to see if there was a breaking change.
                -- If the major version was bumped, display the diangnostic as a warning instead.

                local severity = vim.diagnostic.severity.INFO
                local message = string.format("update available: `%s` -> `%s`", data.version, data.target_version)

                local ok_1, old_version = pcall(vim.version.parse, toml.plugins[name].version)
                local ok_2, new_version = pcall(vim.version.parse, data.target_version)

                if ok_1 and ok_2 and assert(new_version).major > assert(old_version).major then
                    severity = vim.diagnostic.severity.WARN
                    message = message .. " (breaking)"
                end

                diagnostic({
                    message = message,
                    path = { "plugins", name },
                    selector = "key",
                    severity = severity,
                })
            end
        end
    end)
end)
