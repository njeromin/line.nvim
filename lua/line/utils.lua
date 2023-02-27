local M = {}

---Get a highlight attribute.
---@param names string|string[]
---@param attr "bg"|"fg"|string
---@return string|nil
M.get_hl_attr = function(names, attr)
  if type(names) == "string" then names = { names } end
  for _, n in ipairs(names) do
    local id = vim.fn.hlID(n)
    local val = vim.fn.synIDattr(vim.fn.synIDtrans(id), attr)
    if val then
      return val
    end
  end
end

---Returns the first highlight name that exists.
---@param names string[]
---@return string|nil
M.hl_link_fallback = function(names)
  for _, name in ipairs(names) do
    if vim.fn.hlexists(name) then return name end
  end
end

---Parse a string for highlighting.
---@param self Component
---@param str string
local function parse_hl_string(self, str)
  str = str:gsub("{self}", self._hl_name or "StatusLine")

  local split = vim.split(str, " or ")
  if #split > 1 then
    for _, v in ipairs(split) do
      if vim.fn.hlexists(v) then return v end
    end
  else
    return str
  end
end

---Parse a hl table into a highlight group name. 
---@param self Component
---@param hl_info ComponentHighlight
---@param fallback_suffix? string
---@return string|nil
M.parse_hl = function(self, hl_info, fallback_suffix)
  if not hl_info then return end
  if not fallback_suffix then fallback_suffix = "" end
  if type(hl_info) == "string" then
    return parse_hl_string(self, hl_info)
  elseif type(hl_info) == "table" and #hl_info > 0 then
    ---@cast hl_info string[]
    return M.hl_link_fallback(hl_info)
  elseif type(hl_info) == "table" then
    ---@cast hl_info table
    local hl = {}
    for k, v in pairs(hl_info) do
      -- ensure name is not put into highlight
      if k ~= "name" then
        -- highlight is a link
        if type(v) == "table" then
          local val = M.get_hl_attr(v, k)
          hl[k] = val
        -- highlight is string
        elseif type(v) == "string" then
          hl[k] = parse_hl_string(self, v)
          if not vim.startswith(hl[k], "#") then hl[k] = M.get_hl_attr(hl[k], k) end
        -- highlight is anything else
        else
          hl[k] = v
        end
      end
    end
    hl_info.name = hl_info.name or self.name..fallback_suffix
    vim.api.nvim_set_hl(0, hl_info.name, hl)
    return hl_info.name
  end
end

M.get_component_names = function()
  local components = require("line").components
  local ret = {}
  for _, c in ipairs(components) do
    if type(c) == "table" then
      ---@cast c Component
      ret[#ret+1] = c.name
    end
  end
  return ret
end

M.list_components = function()
  local components = require("line").components
  vim.ui.select(
    components,
    {
      prompt = "line.nvim - components",
      format_item = function(item)
        if type(item) == "table" then
          ---@cast item Component
          return string.format("[%s] %s", item.visible and "shown" or "hidden", item.name)
        else
          return "[shown] "..item
        end
      end,
    },
    function(choice)
      if type(choice) == "table" then
        ---@cast choice Component
        choice.visible = not choice.visible
        vim.notify("Toggled visibility for "..choice.name..".", nil, { title = "line.nvim" })
      else
        vim.notify(choice.." can not be toggled.", nil, { title = "line.nvim" })
      end
    end
  )
end

---@type function[]
M.click_handlers = {}

---WIP broken clickable
---@param fn function
---@param text string
---@param i? integer
---@return { text: string, index: integer }
M.clickable = function(fn, text, i)
  local next_cl = i or #M.click_handlers+1
  M.click_handlers[next_cl] = fn
  return {
    text = table.concat({ "%@v:lua.require('line.utils').click_handlers[", next_cl, "]@", text, "%X" }),
    index = next_cl
  }
end

return M
