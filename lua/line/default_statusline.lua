---@type LineStatuslineFunction
return function()
  return {
    require("line.components.mode"):extend({ margin = { right = 0 } }),
    require("line.components.git_branch"),
    require("line.components.file_info"):extend({ margin = { left = 1, right = 1 } }),
    require("line.components.git_info"),
    "%=",
    require("line.components.diagnostics"):extend({ margin = { right = 1 } }),
    require("line.components.lsp"):extend({ margin = { right = 1 } }),
    require("line.components.file_encoding"),
    require("line.components.position"):extend({ margin = { left = 0 } }),
  }
end
