local array = {}

---@class Array
local Array = {}

---Copies elements recursively.
---@generic T
---@param t T[]
---@return T[]
function array.copy(t)
  if type(t) ~= "table" then
    return t
  end
  local res = {}
  for i = 1, #t do
    res[i] = array.copy(t[i])
  end
  return setmetatable(res, getmetatable(t))
end

---Checks if t is an array.
---@param t table
---@return boolean
function array.is_array(t)
  local c = 0
  for _ in pairs(t) do
    c = c + 1
  end
  return #t == c
end

---Recursively checks if t is an array.
---@param t table
---@return boolean
function array.is_array_deep(t)
  local r = true
  local c = 0
  for _, k in pairs(t) do
    c = c + 1
    if type(k) == "table" then
      r = array.is_array_deep(k)
      if not r then
        return r
      end
    end
  end
  return r and #t == c
end

---Returns a new instance of Array.
---@generic T
---@param t T[]
---@param check? '"shallow"' | '"deep"'
---@return T[] Array
function array.new(t, check)
  assert(type(t) == "table", "This is not a table")
  if check == "shallow" then
    assert(array.is_array(t), "This is not an array-like table.")
  elseif check == "deep" then
    assert(array.is_array_deep(t), "This is not an array-like table.")
  end
  return setmetatable(t, { __index = Array })
end

---Returns an array of step (default: 1) increments from start to last.
---@param start integer
---@param last integer
---@param step? integer
---@return integer[]
function array.range(start, last, step)
  step = step or 1
  local t = {}
  for i = start, last, step do
    t[#t + 1] = i
  end
  return array.new(t)
end

---Returns a new array with the element e repeated n times.
---@generic T
---@param e T
---@param n number
---@return T[] Array
function array.mono(e, n)
  local res = {}
  for i = 1, n do
    res[i] = array.copy(e)
  end
  return array.new(res)
end

---Returns a new array with the elements of t repeated n times.
---@generic T
---@param t T[]
---@param n number
---@return T[] Array
function array.cycle(t, n)
  local res = {}
  local len = #t
  local c = 0
  for _ = 1, n do
    for j = 1, len do
      c = c + 1
      res[c] = array.copy(t[j])
    end
  end
  return array.new(res)
end

---Takes multiple array and returns a concatenated array.
---@vararg any[]
---@return any[] Array
function array.concat(...)
  local res = {}
  local c = 0
  local args = { ... }
  for i = 1, #args do
    for j = 1, #args[i] do
      c = c + 1
      res[c] = array.copy(args[i][j])
    end
  end
  return array.new(res)
end

----- Array method from here. -----

---Returns a new Array with the result of func applied to all the elements in t.
---@generic T1, T2
---@param t T1[] Array
---@param func fun(a: T1): T2
---@return T2[] Array
function Array.map(t, func)
  local res = {}
  for i = 1, #t do
    res[i] = func(t[i])
  end
  return array.new(res)
end

---Returns a new Array with all the elements of t that fullfilled the func.
---@generic T
---@param t T[] Array
---@param func fun(x: T): boolean
---@return T[] Array
function Array.filter(t, func)
  local res = {}
  local c = 0
  for i = 1, #t do
    if func(t[i]) then
      c = c + 1
      res[c] = array.copy(t[i])
    end
  end
  return array.new(res)
end

---Checks if t contains e.
---@generic T
---@param t T[] Array
---@param e T
---@return boolean
function Array.contain(t, e)
  for i = 1, #t do
    if e == t[i] then
      return true
    end
  end
  return false
end

---Returns how many e's are contained in t.
---@generic T
---@param t T[] Array
---@param e T
---@return integer
function Array.count(t, e)
  local res = 0
  for i = 1, #t do
    if e == t[i] then
      res = res + 1
    end
  end
  return res
end

---Checks if all the elements of t fullfilled func.
---@generic T
---@param t T[] Array
---@param func fun(x: T): boolean
---@return boolean
function Array.any(t, func)
  for i = 1, #t do
    if func(t[i]) then
      return true
    end
  end
  return false
end

---Checks if some element of t fullfilled func.
---@generic T
---@param t T[] Array
---@param func fun(x: T): boolean
---@return boolean
function Array.all(t, func)
  for i = 1, #t do
    if not func(t[i]) then
      return false
    end
  end
  return true
end

---Returns a new Array without duplicates.
---@generic T
---@param t T[] Array
---@return T[] Array
function Array.deduplicate(t)
  local res = {}
  local c = 0
  for i = 1, #t do
    if not Array.contain(res, t[i]) then
      c = c + 1
      res[c] = array.copy(t[i])
    end
  end
  return array.new(res)
end

---Returns a copy of the sorted array t.
---@generic T
---@param t T[] Array
---@param cmp? fun(x: T, y: T): boolean
---@return T[] Array
function Array.sort(t, cmp)
  local res = array.copy(t)
  table.sort(res, cmp)
  return res
end

---Flattens array t
---@param t any[] Array
---@return any[] Array
function Array.flatten(t)
  local res = {}
  local function _flatten(arr)
    for i = 1, #arr do
      if type(arr[i]) == "table" then
        _flatten(arr[i])
      else
        table.insert(res, arr[i])
      end
    end
  end
  _flatten(t)
  return array.new(res)
end

---Returns a new array with a combination of self and arr.
---If one array is shorter, the remaining elemants in the longer are discarded.
---@generic T1, T2
---@param t T1[] Array
---@param arr T2[] Array
---@return {x: T1, y: T2}[] Array
function Array.zip(t, arr)
  local res = {}
  local len = #t < #arr and #t or #arr
  for i = 1, len do
    res[i] = { t[i], arr[i] }
  end
  return array.new(res)
end

---Unzipping an array of an array with two elements and returns each.
---@generic T1, T2
---@param t {x: T1, y: T2}[] Array
---@return T1[] Array, T2[] Array
function Array.unzip(t)
  local res1, res2 = {}, {}
  for i = 1, #t do
    res1[i] = t[i][1]
    res2[i] = t[i][2]
  end
  return array.new(res1), array.new(res2)
end

---Slice an array t and returns it.
---Negative numbers can also be used for start and last.
---@generic T
---@param t T[]
---@param start integer
---@param last? integer
---@return T[] Array
function Array.slice(t, start, last)
  last = last or #t
  start = start > 0 and start or #t + start + 1
  last = last > 0 and last or #t + last + 1
  assert(start <= #t, ("start (%s) is grater than t's length (%s)"):format(start, #t))
  assert(last <= #t, ("last (%s) is grater than t's length (%s)"):format(last, #t))
  assert(start <= last, ("start (%s) is grater than last (%s)"):format(start, last))
  local res = {}
  for i = start, last do
    res[#res + 1] = t[i]
  end
  return array.new(res)
end

---Reverses array t.
---@generic T
---@param t T[] Array
---@return T[] Array
function Array.reverse(t)
  local i, n = 1, #t
  while i < n do
    t[i], t[n] = t[n], t[i]
    i = i + 1
    n = n - 1
  end
  return t
end

---Returns a copy of array t reversed.
---@generic T
---@param t T[] Array
---@return T[] Array
function Array.reversed(t)
  local res = array.copy(t)
  return Array.reverse(res)
end

return setmetatable(array, { __index = Array })
