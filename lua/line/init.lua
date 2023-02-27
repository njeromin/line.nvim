local profile = require("line.profile")

local M = {}

---@alias LineStatuslineFunction fun(): (Component|string)[]

---@class LineConfig
---@field profile boolean
---@field statusline LineStatuslineFunction
---@field builder ComponentsBuilder
---@field theme { name: string, loaders_order: string[] }
M.config = {}

---@type LineConfig
local default_config = {
  profile = false,
  theme = {
    name = vim.g.colors_name,
    loaders_order = { "lualine", "lightline" },
  }
}

M.build = function()
  profile("Running component provider function", function()
    M.components = M.config.statusline()
  end)

  profile("Running builder", function()
    local built = M.config.builder()
    vim.o.statusline = built
  end)
end

---Set up the plugin.
---@param config? LineConfig
M.setup = function(config)
  M.config = setmetatable(config or {}, { __index = default_config })

  if M.config.theme then require("line.theming").load() end

  ---@diagnostic disable-next-line
  if not M.config.statusline then M.config.statusline = require("line.default_statusline") end

  if not M.config.builder then
    M.config.builder = require("line.builders").default
  end
  vim.o.laststatus = 3
  M.build()
end

return M
