require("rocks-edit.api").register(function(toml, diagnostic)
    require("rocks.api").query_installed_rocks(function(rocks)
        for name, data in pairs(rocks) do
            if not toml.plugins[name] then
                goto continue
            end

            local target_version = toml.plugins[name].version
            local current_version = data.version

            if target_version and target_version ~= current_version then
                diagnostic({
                    message = string.format("still on version `%s`. Run `:Rocks sync` to install version `%s`", current_version, target_version),
                    path = { "plugins", name },
                    selector = "key",
                    severity = vim.diagnostic.severity.WARN,
                })
            end

            ::continue::
        end
    end)
end)
