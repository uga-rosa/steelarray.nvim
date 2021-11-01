# steel.vector

Useful functions for n-D vector (An array whose elements are all numbers).

## available functions

```lua
local vector = require("steel.vector")
```

#### vector.is_vector(t)

Checks if t is a vector.

- parameters
  - `t`: table.
- return
  - boolean

```lua
vector.is_vector({1, 2, 3})
--> true
vector.is_vector({1, 2, "a"})
--> false
```

#### vector.init(num, value)
