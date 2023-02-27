local utils = require("line.utils")

---@alias ComponentHighlight string|string[]|{ name: string, bg: string|table, fg: string|table, sp: string|table }|table

---@class ComponentAutocmd
---@field event?    table|string
---@field desc?     string
---@field pattern?  string
---@field update?   fun(self: Component, event: table)

---@class ComponentPaddingOrMargin
---@field left?         integer
---@field right?        integer
---@field _last_left?   string
---@field _last_right?  string

---@class Component
---@field extend              fun(self: Component, extension: Component): Component
---@field name                string
---@field hl?                 ComponentHighlight
---@field lazy?               boolean|{ event: string|string[], pattern: string }
---@field init?               fun(self: Component)
---@field update?             fun(self: Component)
---@field autocmd_on_init?    boolean
---@field autocmd?            ComponentAutocmd
---@field icon?               { text: string, hl: ComponentHighlight }
---@field value               string
---@field padding?            ComponentPaddingOrMargin
---@field margin?             ComponentPaddingOrMargin
---@field visible?            boolean
---@field _hl_name?           string
---@field _evaluate           fun(self: Component): string
---@field _setup_autocmd      fun(self: Component)
---@field _setup_lazy         fun(self: Component)
---@field _components_index   integer
---@field _lazy_initialised?  boolean
---@field _lazy_stop_load?    boolean
---@field _has_initialised    boolean
---@field data?               table
local Component = {}

---Generate padding or margin from size.
---@param component Component
---@param t "padding"|"margin"
---@param side "left"|"right"
---@return string
local function gen_padding_or_margin(component, t, side)
  local p = component[t]
  if not p then return "" end
  local size = p[side]
  local last_padding = p["_last_"..side] or ""
  if not size then return "" end
  if size == #last_padding then return last_padding end

  local ret = ""

  for _ = 1, size, 1 do
    ret = ret.." "
  end

  p = ret

  return ret
end

---Generate an icon from an icon object
---@param self Component
---@return string
local function get_icon(self)
  local i = self.icon or {}
  if not i.text then return "" end
  if type(i.hl) == "table" then i.hl.name = self.name..".icon" end
  local icon_hl = utils.parse_hl(self, i.hl, "icon")
  if icon_hl then
    icon_hl = "%#"..icon_hl.."#"
  else
    icon_hl = ""
  end

  local end_hl = "%*"
  if self._hl_name then end_hl = "%#"..self._hl_name.."#" end

  return table.concat({
    icon_hl,
    i.text,
    end_hl,
  })
end

---Get a component's value.
---@param self Component
local function get_value(self)
  if not self.value or self.value == "" then return "" end

  local margin_left = gen_padding_or_margin(self, "margin", "left")
  local margin_right = gen_padding_or_margin(self, "margin", "right")
  local padding_left = gen_padding_or_margin(self, "padding", "left")
  local padding_right = gen_padding_or_margin(self, "padding", "right")
  local icon = ""
  if self.value and self.icon then
    icon = get_icon(self)
  end

  return table.concat({
    margin_left,
    self._hl_name and "%#"..self._hl_name.."#" or "",
    padding_left,
    icon,
    self.value,
    padding_right,
    "%*",
    margin_right,
  })
end

---Add to an existing component.
---@param extension Component
---@return Component
function Component:extend(extension)
  return Component:new(extension.name or self.name, vim.tbl_deep_extend("force", self, extension))
end

---Create a new statusline component.
---@param name string
---@param o? Component
function Component:new(name, o)
  o = o or {}
  o.name = name
  o.data = o.data or {}
  if type(o.visible) == "nil" then o.visible = true end
  setmetatable(o, self)
  self.__index = self

  return o
end

function Component:_evaluate()
  -- lazy
  if self._lazy_stop_load then return "" end

  -- init
  if not self._has_initialised then
    if type(self.init) == "function" then self:init() end

    self._hl_name = utils.parse_hl(self, self.hl)

    if self.autocmd and self.autocmd_on_init then
      if type(self.autocmd.update) == "function" then self.autocmd.update(self, {}) end
    end

    self._has_initialised = true
  end

  -- component updating
  if not self.visible then return "" end

  if type(self.update) == "function" then self:update() end

  return self.value and get_value(self) or ""
end

function Component:_setup_lazy()
  if self.lazy then
    self._lazy_stop_load = true

    local e
    local p

    if type(self.lazy) == "boolean" and self.autocmd then
      e = self.autocmd.event
      p = self.autocmd.pattern
    elseif type(self.lazy) == "table" then
      e = self.lazy.event
      p = self.lazy.pattern
    end

    if e then
      self._lazy_autocmd = vim.api.nvim_create_autocmd(e, {
        pattern = p,
        callback = function()
          self._lazy_stop_load = false
          vim.api.nvim_del_autocmd(self._lazy_autocmd)
          self._lazy_autocmd = nil
        end,
      })
    else
      vim.notify(string.format("Cannot get autocmd options for component with name '%s'.", self.name), nil, { title = "line.nvim" })
    end

    self._lazy_initialised = true
  end
end

function Component:_setup_autocmd()
  if not self.autocmd then return end

  if not self.autocmd.desc then self.autocmd.desc = self.name..".autocmd" end

  vim.api.nvim_create_autocmd(self.autocmd.event, {
    desc = self.autocmd.desc,
    pattern = self.autocmd.pattern,
    callback = function(e)
      if type(self.autocmd.update) == "function" then self.autocmd.update(self, e) end
    end,
  })
end

return Component
