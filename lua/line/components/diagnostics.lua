local utils = require("line.utils")
local Component = require("line.component")

local severity = vim.diagnostic.severity

local sign_names = {
  [severity.ERROR] = "Error",
  [severity.WARN] = "Warn",
  [severity.HINT] = "Hint",
  [severity.INFO] = "Info",
}

---Get sign from severity.
---@param self Component
---@param s DiagnosticSeverity
---@return { icon: string, hl: string }
local function get_sign(self, s)
  local name = sign_names[s]
  local sign = vim.fn.sign_getdefined("DiagnosticSign"..name)[1]
  local hl_name = "njeromin.line.diagnostics."..name
  local hl = {
    fg = utils.get_hl_attr(sign.texthl, "fg"),
    bg = utils.get_hl_attr({ self._hl_name or "StatusLine", "StatusLine" }, "bg")
  }
  vim.api.nvim_set_hl(0, hl_name, hl)
  return {
    icon = sign.text,
    hl = "%#"..hl_name.."#",
  }
end

local C = Component:new("njeromin.line.components.diagnostics", {
  autocmd = {
    event = { "BufEnter", "DiagnosticChanged" },
    update = function(self)
      local v = {}

      for _, s in ipairs({ severity.ERROR, severity.WARN, severity.HINT, severity.INFO }) do
        local amount = #(vim.diagnostic.get(self.data.workspace and nil or 0, { severity = s }) or 0)
        if self.data.always_show_diagnostics or amount > 0 then
          local sign = get_sign(self, s)
          v[#v+1] = string.format("%s%s%s", sign.hl, sign.icon, amount)
        end
      end

      self.value = table.concat(v, " ")
    end
  },
  data = {
    always_show_diagnostics = false,
    workspace = false,
  },
})



return C
