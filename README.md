line.nvim
=======

A wip statusline plugin for neovim which focuses on class-based components. Replaces [the old one](https://github.com/njeromin/line.nvim.old).

## Installing
**lazy.nvim**
```lua
{
	"njeromin/line.nvim",
	lazy = false,
	config = true,
}
```

**packer.nvim**

```lua
{
	"njeromin/line.nvim",
	config = function()
		require("line").setup()
	end,
}
```

## Config
```lua
{
	profile? = boolean, -- defaults: false
	statusline? = function: (Component|string)[], -- defaults to line.default_statusline
	builder? = function: string -- defaults to line.builders.default
	theme? = {
		name = string, -- defaults to neovim colorscheme
		loaders_order = string[] -- defaults to { "lualine", "lightline" }
	}
}
```

## Component
Components are instantiated through ``require("line.component"):new(name, fields)``.

**Example LSP Server Listing Component**
```lua
----- components/example_lsp.lua
local C = require("line.component"):new("line.components.example_lsp", {
	icon = {
	    text = "󱙌 ",
	    hl = { fg = "Constant", bg = "{self}" },
	},
	autocmd = {
		event = { "BufEnter", "LspAttach", "LspDetach" },
		update = function(self)
		    local clients = vim.lsp.get_active_clients({ bufnr = 0 })
		    local filtered = {}
            for _, client in ipairs(clients) do
                local name = client.name
                if not self.data.ignored[name] then
                    table.insert(filtered, name)
                end
            end

            if #filtered == 0 then
                self.value = "No LSPs"
                return
            end

            self.value = table.concat(filtered, ", ")
        end,
	},
    	data = {
        	ignored = { ["null-ls"] = true } 
    	},
})

return C

----- statusline_generator.lua
require("line").setup({
    statusline = function()
        return {
            require("components.example_lsp")
        }
    end,
})
```
