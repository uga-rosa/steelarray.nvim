---@class Array
local Array = {}

---Checks if t is an array.
---@param t table
---@return boolean
function Array.is_array(t)
  local c = 0
  for _ in pairs(t) do
    c = c + 1
  end
  return #t == c
end

---Recursively checks if t is an array.
---@param t table
---@return boolean
function Array.is_array_deep(t)
  local r = true
  local c = 0
  for _, k in pairs(t) do
    c = c + 1
    if type(k) == "table" then
      r = Array.is_array_deep(k)
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
function Array.new(t, check)
  assert(type(t) == "table", "This is not a table")
  if check == "shallow" then
    assert(Array.is_array(t), "This is not an array-like table.")
  elseif check == "deep" then
    assert(Array.is_array_deep(t), "This is not an array-like table.")
  end
  return setmetatable(t, { __index = Array })
end

---Copies elements recursively.
---@generic T
---@param t T[]
---@return T[]
function Array.copy(t)
  if type(t) ~= "table" then
    return t
  end
  local res = {}
  for i = 1, #t do
    res[i] = Array.copy(t[i])
  end
  return setmetatable(res, getmetatable(t))
end

---Returns an array of step (default: 1) increments from start to last.
---@param start integer
---@param last integer
---@param step? integer
---@return integer[]
function Array.range(start, last, step)
  step = step or 1
  local t = {}
  for i = start, last, step do
    t[#t + 1] = i
  end
  return Array.new(t)
end

---Returns a new array with the element e repeated n times.
---@generic T
---@param e T
---@param n number
---@return T[] Array
function Array.repeats(e, n)
  local res = {}
  for i = 1, n do
    res[i] = Array.copy(e)
  end
  return Array.new(res)
end

---Returns a new array with the elements of t repeated n times.
---@generic T
---@param t T[]
---@param n number
---@return T[] Array
function Array.cycle(t, n)
  local res = {}
  local len = #t
  local c = 0
  for _ = 1, n do
    for j = 1, len do
      c = c + 1
      res[c] = Array.copy(t[j])
    end
  end
  return Array.new(res)
end

---Takes multiple array and returns a concatenated array.
---@vararg any[]
---@return any[] Array
function Array.concat(...)
  local res = {}
  local c = 0
  local args = { ... }
  for i = 1, #args do
    for j = 1, #args[i] do
      c = c + 1
      res[c] = Array.copy(args[i][j])
    end
  end
  return Array.new(res)
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
  return Array.new(res)
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
      res[c] = Array.copy(t[i])
    end
  end
  return Array.new(res)
end

---Deletes the elements of the array t at positions `first..last`
---@generic T
---@param t T[]
---@param first integer
---@param last integer
---@return T[]
function Array.delete(t, first, last)
  local res = {}
  local c = 0
  for i = 1, #t do
    if i < first or i > last then
      c = c + 1
      res[c] = t[i]
    end
  end
  return Array.new(res)
end

---Returns the array with the elements inserted from src into t at position pos.
---@generic T
---@param t T[]
---@param src T[]
---@param pos integer
---@return T[]
function Array.insert(t, src, pos)
  src = type(src) == "table" and src or { src }
  pos = pos or 1
  local res = {}
  for i = 1, pos - 1 do
    res[i] = t[i]
  end
  for i = 1, #src do
    res[pos - 1 + i] = src[i]
  end
  for i = pos, #t do
    res[#src + i] = t[i]
  end
  return Array.new(res)
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

---Returns how many e's are contained in the array t.
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

---Checks if any element of t fullfilled func.
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

---Returns the array without duplicates.
---@generic T
---@param t T[] Array
---@return T[] Array
function Array.deduplicate(t)
  local res = {}
  local c = 0
  for i = 1, #t do
    if not Array.contain(res, t[i]) then
      c = c + 1
      res[c] = Array.copy(t[i])
    end
  end
  return Array.new(res)
end

---Returns the copy of the sorted array t.
---@generic T
---@param t T[] Array
---@param cmp? fun(x: T, y: T): boolean #default: `<`
---@return T[] Array
function Array.sort(t, cmp)
  local res = Array.copy(t)
  table.sort(res, cmp)
  return res
end

---Flattens the array t
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
  return Array.new(res)
end

---Returns the array with a combination of t1 and t1.
---If one array is shorter, the remaining elemants in the longer are discarded.
---@generic T1, T2
---@param t1 T1[] Array
---@param t2 T2[] Array
---@return {x: T1, y: T2}[] Array
function Array.zip(t1, t2)
  local res = {}
  local len = #t1 < #t2 and #t1 or #t2
  for i = 1, len do
    res[i] = { t1[i], t2[i] }
  end
  return Array.new(res)
end

---Unzipping the array of the array with two elements and returns each.
---@generic T1, T2
---@param t {x: T1, y: T2}[] Array
---@return T1[] Array, T2[] Array
function Array.unzip(t)
  local res1, res2 = {}, {}
  for i = 1, #t do
    res1[i] = t[i][1]
    res2[i] = t[i][2]
  end
  return Array.new(res1), Array.new(res2)
end

---Returns the slice of the array t.
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
  return Array.new(res)
end

---Reverses the content of the array t.
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

---Returns the reverse of the array t.
---@generic T
---@param t T[] Array
---@return T[] Array
function Array.reversed(t)
  local res = Array.copy(t)
  return Array.reverse(res)
end

return Array
