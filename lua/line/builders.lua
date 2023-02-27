local line = require("line")

---@alias ComponentsBuilder fun(): string

local M = {}

M.full_lua_run = function()
  local components = line.components
  local r = {}

  for _, c in ipairs(components) do
    local str = ""

    if type(c) == "table" then
      ---@cast c Component
      str = c:_evaluate()
    elseif type(c) == "string" then
      str = c
    end

    r[#r + 1] = str
  end

  return table.concat(r)
end

---Builds a string which calls each component completely through lua.
---@type ComponentsBuilder
M.full_lua = function()
  local components = line.components
  for _, c in ipairs(components) do
    if type(c) == "table" then
      ---@cast c Component
      c:_setup_lazy()
      c:_setup_autocmd()
    end
  end

  return "%{%luaeval('require(\"line.builders\").full_lua_run()')%}"
end

---Builds a string containing luaevals every component.
---@type ComponentsBuilder
M.default = function()
  local components = line.components
  local r = {}

  for i, c in ipairs(components) do
    local str = ""

    if type(c) == "table" then
      ---@cast c Component
      c:_setup_lazy()
      c:_setup_autocmd()
      local e = string.format("require(\"line\").components[%s]:_evaluate()", i)
      str = "%{%luaeval('"..e.."')%}"
    elseif type(c) == "string" then
      str = c
    end

    r[#r + 1] = str
  end

  return table.concat(r)
end

return M
