# steel.array

Useful functions for array (array-like table).

## available functions

```lua
local array = require("steel.array")
```

#### array.copy(t)

Returns a deep copy of array t, respect to metatable.

- parameters
  - `t`: array.
- return
  - A deep copy of t.

example
```lua
local a = array.new({1, 2, 3, 4, 5})
local b = array.copy(a)
assert(a == b, "lua's table returns true with == only if they have the same reference.")
```

#### array.new(t, check?)

Creates a new instance of class Array.

- parameters
  - `t`: array.
  - `check`: optional and can be either "shallow" or "deep".
- return
  - A instance of class Array.

example
```lua
local a = array.new({1, 2, 3, 4, 5}) -- OK
local b = arrow.new({1, 2, 3, a = "a"}, "shallow") -- This cause error.
```

#### array.range(first, last, step?)

Returns an array of step (default: 1) increments from first to last.

- parameters
  - `first`: integer.
  - `last`: integer.
  - `step`: optional. default is 1.
- return
  - A instance of class Array.

example
```lua
local a = array.range(1, 10)
--> {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
local b = array.range(1, 10, 4)
--> {1, 5, 9}
local c = array.range(10, 1, -2)
--> {10, 8, 6, 4, 2}
```

#### array.repeats(e, n)

Returns a new array with the element e repeated n times.

- parameters
  - `e`: element.
  - `n`: number of elements.
- return
  - A instance of class Array.

example
```lua
local a = array.repeats("a", 3)
--> {"a", "a", "a"}
local b = array.repeats({"a", "b"}, 3)
--> {{"a", "b"}, {"a", "b"}, {"a", "b"}}
```

#### array.cycle(t, n)

Returns a new array with the elements of t repeated n times.

- parameters
  - `t`: elements' array.
  - `n`: Number of repetitions.
- return
  - A instance of class Array.

example
```lua
local a = array.cycle({1, 2, 3}, 3)
--> {1, 2, 3, 1, 2, 3, 1, 2, 3}
```

#### array.concat(...)

Returns the array combined multiple arrays.

- parameters
  - `...`: arrays.
- return
  - A instance of class Array.

example
```lua
local a = array.concat({1, 2}, {"a"}, {3, {4, 5}})
--> {1, 2, "a", 3, { 4, 5 }}
```

#### array.map(t, func)

Returns the Array with the result of func applied to all the elements in t.

- parameters
  - `t`: array.
  - `func`: Function that takes array element as arguments.
- return
  - A instance of class Array.

example
```lua
local a = array.new({"a", "b", "c"})
local b = array.map(a, function(x) return x .. "hoge" end)
--> {"ahoge", "bhoge", "choge"}
local c = array.range(1, 5)
  :map(function(x) return x * 3 end) -- very useful syntax sugar
--> {3, 6, 9, 12, 15}
```

#### array.filter(t, func)

Returns the Array with all the elements of t that fullfilled the func.

- parameters
  - `t`: array.
  - `func`: Function that takes array element as arguments.
- return
  - A instance of class Array.

example
```lua
local a = array.range(1, 10)
  :filter(a, function(x) return x > 5 end)
--> {6, 7, 8, 9, 10}
local b = array.range(1, 10)
  :map(function(x) return x + 5 end)
  :filter(function(x) return x > 12 end)
--> {13, 14, 15}
```

#### array.delete(t, first, last)

Deletes the elements of the array t at positions `first..last`

- parameters
  - `t`: array
  - `first`: integer
  - `last`: integer
- return
  - A instance of class Array

example
```lua
local a = array.range(1, 10)
  :delete(3, 7)
--> {1, 2, 8, 9, 10}
local b = array.range(1, 10)
  :delete(-4, -2)
--> {1, 2, 3, 4, 5, 6, 10}
```

#### array.insert(t, src, pos?)

The difference with `table.insert` is that src is an array and elements of it are inserted at position pos in array t.

- parameters
  - `t`: array
  - `src`: array
  - `pos`: optional. default is `#t`
- return
  - A instance of class Array

example
```lua
local a = array.new({"a", "b", "c"})
  :insert({"d", "e"}, 2)
--> {"a", "d", "e", "b", "c"}
```

#### array.slice(t, first, last)

Returns the slice of the array t.

- parameters
  - `t`: array
  - `first`: integer
  - `last`: integer
- return
  - A instance of class Array

```lua
local a = array.range(1, 10)
  :slice(4, 7)
--> {4, 5, 6, 7}
  :delete(2, 3)
--> {4, 7}
  :insert({5, 6}, 2)
--> {4, 5, 6, 7}
```

#### array.contain(t, e)

Checks if t contains e.

- parameters
  - `t`: array
  - `e`: element
- return
  - boolean

example
```lua
local a = array.range(1, 10)
  :contain(5)
--> true
local b = array.new({"a", "b", "c"})
  :contain("d")
--> false
```

#### array.count(t, e)

Checks if t contains e.

- parameters
  - `t`: array
  - `e`: element
- return
  - integer

example
```lua
local a = array.range(1, 10)
  :count(5)
--> 1
local b = array.new({"a", "b", "a"})
  :count("a")
--> 2
```

#### array.any(t, func)

Checks if any element of t fullfilled func.

- parameters
  - `t`: array
  - `func`: fun(x: any): boolen
- return
  - boolen

```lua
local a = array.range(1, 10)
  :any(function(x) return x > 9 end)
--> true
local b = array.range(1, 10)
  :any(function(x) return x < 1 end)
--> false
```

#### array.all(t, func)

Checks if all the elements of t fullfilled func.

- parameters
  - `t`: array
  - `func`: fun(x: any): boolen
- return
  - boolen

```lua
local a = array.range(1, 10)
  :any(function(x) return x > 0 end)
--> true
local b = array.range(1, 10)
  :all(function(x) return x > 5 end)
--> false
```

#### array.deduplicate(t)

Returns the array without duplicates.

- parameters
  - `t`: array
- return
  - A instance of class Array

```lua
local a = array.cycle({1, 2, 3}, 3)
--> {1, 2, 3, 1, 2, 3, 1, 2, 3}
  :deduplicate()
--> {1, 2, 3}
```

#### array.sort(t)

Returns the copy of the sorted array t.
table.sort() is destructive.

- parameters
  - `t`: array
- return
  - Same class as original t.

```lua
local a = array.new({1, 5, 2, 4, 3})
local b = a:sort()
--> a == {1, 5, 2, 4, 3}
--> b == {1, 2, 3, 4, 5}
```

#### array.flatten(t)

Flattens the array t.

- parameters
  - `t`: array
- return
  - A instance of class Array

```lua
local a = array.new({1, {2, 3}, {{4, {5, 6}}}})
  :flatten()
--> {1, 2, 3, 4, 5, 6}
```

#### array.zip(t1, t2)

Returns the array with a combination of t1 and t1.
If one array is shorter, the remaining elemants in the longer are discarded.

- parameters
  - `t1`: array
  - `t2`: array
- return
  - A instance of class Array

```lua
local a = array.zip({1, 2, 3}, {"a", "b", "c"})
--> {{1, "a"}, {2, "b"}, {3, "c"}}
local b = array.zip({1, 2}, {"a", "b", "c", "d"})
--> {{1, "a"}, {2, "b"}}
```

#### array.unzip(t)

Unzipping the array of the array with two elements and returns each.

- parameters
  - `t`: array
- returns
  - A instance of class Array
  - A instance of class Array

```lua
local a, b = Array.unzip({ { 1, "a" }, { 2, "b" }, { 3, "c" } })
--> a == {1, 2, 3}
--> b == {"a", "b", "c"}
```

#### array.reverse(t)

Reverses the content of the array t.
Destructive method.

- parameters
  - `t`: array
- returns
  - A instance of class Array

```lua
local a = array.range(1, 5)
a:reverse()
--> {5, 4, 3, 2, 1}
```

#### array.reversed(t)

Returns the copy of the reversed array t.
Non-destructive method.

- parameters
  - `t`: array
- returns
  - A instance of class Array

```lua
local a = array.range(1, 5)
local b = a:reversed()
--> a == {1, 2, 3, 4, 5}
--> b == {5, 4, 3, 2, 1}
```

#### array.foldl(t, func, first?)

Returns the result of left convolution.

- parameters
  - `t`: array
  - `func`: A function that takes two arguments.
  - `first`: optional.
- returns
  - any

```lua
local a = array.range(1, 5)
  :foldl(function(x, y) return x - y end)
--> -13
-- ((((1 - 2) - 3) - 4) - 5)
local b = array.range(1, 5)
  :foldl(function(x, y) return x - y end, 10)
--> -5
-- (((((10 - 1) - 2) - 3) - 4) - 5)
```

#### array.foldr(t, func, first?)

Returns the result of right convolution.

- parameters
  - `t`: array
  - `func`: A function that takes two arguments.
  - `first`: optional.
- returns
  - any

```lua
local a = array.range(1, 5)
  :foldr(function(x, y) return x - y end)
--> -5
-- ((((5 - 4) - 3) - 2) - 1)
local b = array.range(1, 5)
  :foldr(function(x, y) return x - y end, 1)
--> -14
-- (((((1 - 5) - 4) - 3) - 2) - 1)
```
