local utils = require("line.utils")
local Component = require("line.component")

local C = Component:new("njeromin.line.components.mode", {
  update = function(self)
    local mode = vim.fn.mode()
    if mode == self._mode then return end
    self._mode = mode
    if not self.data.colours then self.data.colours = require("line.theming").hl.mode end
    local mode_name = self.data.names[mode] or self.data.names["n"]
    utils.parse_hl(self, self.data.colours[string.lower(mode_name)])
    self.value = mode_name
  end,
  hl = "njeromin.line.components.mode",
  padding = { left = 1, right = 1 },
  margin = { right = 1 },
  data = {
    names = {
      n = "NORMAL",
      c = "COMMAND",
      i = "INSERT",
      v = "VISUAL",
      V = "VISUAL",
      s = "SELECT",
      S = "SELECT",
      R = "REPLACE",
      t = "TERMINAL",
      ["v:null"] = "NORMAL",
    },
    colours = nil,
  }
})

return C
