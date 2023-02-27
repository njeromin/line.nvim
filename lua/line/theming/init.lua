local line = require("line")
local profile = require("line.profile")

---@alias LineHighlight string|{ fg: string, bg: string, special: string, bold: boolean }|table

---@class LineTheme
---@field normal LineHighlight
---@field mode { normal: LineHighlight, insert: LineHighlight, visual: LineHighlight, command: LineHighlight, terminal: LineHighlight, replace: LineHighlight, select: LineHighlight }

---@class LineThemeLoader
---@field get fun(theme_name: string): LineTheme|nil

local M = {}

---@type LineTheme
M.hl = nil

---Load a loader.
---@param loader_name string
---@return LineThemeLoader
M.from = function(loader_name)
  return require(string.format("line.theming.loaders.%s", loader_name))
end

---Load theme.
local function load()
  M.hl = {}

  for _, loader_name in ipairs(line.config.theme.loaders_order) do
    local t = M.from(loader_name)
    local hls = t.get(line.config.theme.name)
    if hls then
      M.hl = hls
      break
    end
  end

  if M.hl.mode and not M.hl.mode.select and M.hl.mode.visual then M.hl.select = M.hl.mode.visual end

  M.hl = setmetatable(M.hl, {
    __index = {
      normal = "StatusLine",
      mode = {
        normal = { bg = "String", fg = "#000000" },
        insert = { bg = "Function", fg = "#000000" },
        visual = { bg = "Identifier", fg = "#000000" },
        command = { bg = "Type", fg = "#000000" },
        terminal = { bg = "Constant", fg = "#000000" },
        replace = { bg = "Identifier", fg = "#000000" },
        select = { bg = "Identifier", fg = "#000000" },
      },
    }
  })

  local normal_hl = M.hl.normal
  if type(normal_hl) == "string" then
    normal_hl = vim.api.nvim_get_hl_by_name(normal_hl, true)
  end
  vim.api.nvim_set_hl(0, "StatusLine", normal_hl)
end

M.load = function()
  profile("Loading theme", load)
end

return M
