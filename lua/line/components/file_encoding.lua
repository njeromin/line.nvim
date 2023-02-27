local Component = require "line.component"

local C = Component:new("njeromin.line.components.file_encoding", {
  autocmd = {
    event = "BufEnter",
    update = function(self)
      self.value = vim.bo.fileencoding
    end,
  },
  hl = "Normal",
  padding = { left = 1, right = 1 },
})

return C
