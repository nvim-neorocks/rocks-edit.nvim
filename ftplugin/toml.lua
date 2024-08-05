local rocks_edit = require("rocks-edit")

if not vim.g.rocks_edit_nvim_loaded then
    local group = vim.api.nvim_create_augroup("rocks-edit.nvim", { clear = true })
    rocks_edit.configure()
    -- one-time initialisation logic
    vim.api.nvim_create_autocmd("User", {
        pattern = "RocksCachePopulated",
        group = group,
        callback = function()
            rocks_edit.display_diagnostics()
        end,
    })
    vim.g.rocks_edit_nvim_loaded = true
end

rocks_edit.display_diagnostics()
