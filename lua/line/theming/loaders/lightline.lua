local u = require("line.theming.utils")

---@type LineThemeLoader
local M = {}

-- FIX: command being missing breaks statusline
M.get = function(theme_name)
  local ok, theme = pcall(require, string.format("lightline.colorscheme.%s", theme_name))
  if not ok then return end

  local theme_mode = {}
  for _, v in ipairs(u.mode_names) do
    local a = theme[v]
    if a and #a.left > 0 then
      local t = a.left[1] or {}
      theme_mode[v] = { fg = t[1], bg = t[2] }
    end
  end

  local normal = nil
  if theme.normal and #theme.normal.middle > 0 then
    local t = theme.normal.middle[1] or {}
    normal = { fg = t[1], bg = t[2] }
  end

  return {
    normal = normal,
    mode = theme_mode,
  }
end

return M
