local Component = require("line.component")

local C = Component:new("njeromin.line.components.file_info", {
  lazy = { event = { "UIEnter" } },
  update = function (self)
    local bufname = vim.api.nvim_buf_get_name(0)
    if bufname == self._last_bufname then return end
    self._last_bufname = bufname

    local ft = vim.bo.filetype
    local custom = self.data.custom[ft] or {}
    local v = {}

    -- set icon
    self.icon = custom.icon
    if not custom.icon then
      local ok, devicons = pcall(require, "nvim-web-devicons")
      if ok then
        local i, h = devicons.get_icon_by_filetype(ft, { default = true })
        self.icon = { text = i.." ", hl = { fg = h } }
      end
    end
    if type(self.icon.hl) == "table" then
      self.icon.hl.bg = "{self}"
    end

    -- name
    v[#v+1] = custom.name or vim.fs.basename(bufname)

    self.value = table.concat(v, " ")
  end,
  data = {
    ---@type { [string]: { name: string, icon: { text: string, hl: ComponentHighlight } } }
    custom = {
      [""] = { name = "[No Name]" },
      ["help"] = {
        name = "Help",
        icon = { text = "󰘥 ", hl = { fg = "String" } },
      },
      ["lazy"] = {
        name = "Lazy",
        icon = { text = "󰒲 ", hl = { fg = "Function" } },
      },
      ["mason"] = {
        name = "Mason",
        icon = { text = "󰢛 ", hl = { fg = "Normal" } },
      },
      ["neo-tree"] = {
        name = "File Tree",
        icon = { text = "󱏒 ", hl = { fg = "String"} },
      },
      ["neo-tree-popup"] = {
        name = "File Tree [popup]",
        icon = { text = "󱏒 ", hl = { fg = "String"} },
      },
      ["toggleterm"] = {
        name = "Terminal",
        icon = { text = " ", hl = { fg = "Constant" } },
      },
      ["TelescopePrompt"] = {
        name = "Telescope",
        icon = { text = " ", hl = { fg = "Normal" } },
      },
      ["lspinfo"] = {
        name = "LSP Info",
        icon = { text = "󱙌 ", hl = { fg = "String" } },
      },
      ["Trouble"] = {
        name = "Trouble",
        icon = { text = "🚦", hl = { fg = "{self}" } },
      },
      ["dap-repl"] = {
        name = "DAP REPL",
        icon = { text = " ", hl = { fg = "Constant" } },
      },
      ["dapui_console"] = {
        name = "DAP Console",
        icon = { text = " ", hl = { fg = "Constant" } },
      },
      ["dapui_watches"] = {
        name = "DAP Watches",
        icon = { text = " ", hl = { fg = "Constant" } },
      },
      ["dapui_stacks"] = {
        name = "DAP Stacks",
        icon = { text = "ﱨ ", hl = { fg = "Constant" } },
      },
      ["dapui_breakpoints"] = {
        name = "DAP Breakpoints",
        icon = { text = " ", hl = { fg = "Constant" } },
      },
      ["dapui_scopes"] = {
        name = "DAP Scopes",
        icon = { text = "ﱆ ", hl = { fg = "Constant" } },
      },
    },
  },
})

return C
