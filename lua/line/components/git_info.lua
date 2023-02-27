local Component = require("line.component")
local b = vim.b

local types = { "added", "changed", "removed" }

local function compare(j, k)
  j = j or {}
  k = k or {}

  for _, v in ipairs(types) do
    if j[v] ~= k[v] then return false end
  end

  return true
end

local C = Component:new("njeromin.line.components.git_info", {
  lazy = { event = "BufReadPost" },
  init = function (self)
    for _, which in ipairs(types) do
      local hl_name = self.name.."."..which
      local fg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID(self.data.display[which].hl_name)), "fg")
      local bg = vim.fn.synIDattr(vim.fn.hlID(self._hl_name or "StatusLine"), "bg")
      vim.api.nvim_set_hl(0, hl_name, { fg = fg, bg = bg, bold = true })
    end
  end,
  update = function(self)
    ---@diagnostic disable-next-line
    local status = b.gitsigns_status_dict
    if not status then return end
    if compare(status, self.data._last_status) then return end
    self.data._last_status = status

    local val = {}

    for _, which in ipairs(types) do
      local s = status[which]
      if s and s > 0 or self.data.always_show then
        local disp = self.data.display[which]
        local hl_name = self.name.."."..which
        val[#val+1] = string.format("%%#%s#%s%s", hl_name, disp.icon, s)
      end
    end

    self.value = table.concat(val, " ")
  end,
  data = {
    always_show = false,
    display = {
      added = { icon = " ", hl_name = "GitSignsAdd" },
      changed = { icon = " ", hl_name = "GitSignsChange" },
      removed = { icon = " ", hl_name = "GitSignsDelete" },
    },
  },
})

return C
