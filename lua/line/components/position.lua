local Component = require("line.component")

local C = Component:new("njeromin.line.components.position", {
  padding = {
    left = 1,
    right = 1,
  },
  margin = {
    left = 1,
  },
  hl = { "njeromin.line.components.mode", "String" },
  autocmd = {
    event = { "CursorMoved", "CursorMovedI", "BufEnter" },
    update = function(self)
      local ok, cursor = pcall(vim.api.nvim_win_get_cursor, 0)
      if ok then
        self.value = string.format("%s:%s", cursor[2]+1, cursor[1])
      else
        self.value = "-:-"
      end
    end,
  },
})

function C:init()
  self.value = "1:1"
end

return C
