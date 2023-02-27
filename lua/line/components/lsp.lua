local Component = require("line.component")

local C = Component:new("njeromin.line.components.lsp", {
  icon = {
    text = "󱙌 ",
    hl = { fg = "Constant", bg = "{self}" },
  },
  autocmd = {
    event = { "BufEnter", "LspAttach", "LspDetach" },
    update = function(self)
      local clients = vim.lsp.get_active_clients({ bufnr = 0 })

      local too_many = false
      local filtered = {}
      for _, c in ipairs(clients) do 
        if not self.data.ignored[c.name] then
          if #filtered > self.data.max_shown then
            too_many = true
            break
          end
          table.insert(filtered, c.name)
        end
      end

      if #filtered == 0 then
        self.value = "No LSPs"
        return
      end

      local ret = table.concat(filtered, ", ")
      if too_many then ret = ret.."..." end
      self.value = ret
    end,
  },
  data = {
    max_shown = 3,
    ignored = { ["null-ls"] = true },
  },
})

return C
