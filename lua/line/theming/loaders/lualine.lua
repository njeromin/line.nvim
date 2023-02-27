local u = require("line.theming.utils")

---@type LineThemeLoader
local M = {}

M.get = function(theme_name)
  local ok, theme = pcall(require, string.format("lualine.themes.%s", theme_name))
  if not ok then return end

  local theme_mode = {}
  for _, v in ipairs(u.mode_names) do
    if type(theme[v]) == "table" then
      theme_mode[v] = theme[v].a
    end
  end

  return {
    normal = theme.normal.c,
    mode = theme_mode,
  }
end

return M
