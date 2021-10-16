# steelarray.nvim

Useful functions for array like table.  
Use Emmy annotations.  
It can also be used outside of neovim.

```lua
local array = require("steel.array")
local a = array.range(1, 10) -- {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
  :map(function(x) return x + 1 end) -- {2, 3, 4, 5, 6, 7, 8, 9, 10, 11}
  :filter(function(x) return x > 5 end) -- {6, 7, 8, 9, 10, 11}
```
