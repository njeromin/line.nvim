local Component = require("line.component")

local C = Component:new("njeromin.line.components.git_branch", {
  lazy = { event = "BufReadPost" },
  update = function(self)
    ---@diagnostic disable-next-line
    if self.value == vim.b.gitsigns_head then return end
    self.value = vim.b.gitsigns_head
  end,
  padding = { left = 1, right = 1 },
  icon = { text = "󰘬 ", hl = { fg = "Constant", bg = "{self}" } },
  hl = { fg = "Normal", bg = "Normal" },
})

return C
