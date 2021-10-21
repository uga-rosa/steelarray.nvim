---@class matrix
---@field _row number
---@field _col number
local matrix = {}

local function is_table(t)
  return type(t) == "table"
end

local function tbl_copy(t)
  if not is_table(t) then
    return t
  end
  local res = {}
  for k, v in pairs(t) do
    res[k] = tbl_copy(v)
  end
  return setmetatable(res, getmetatable(t))
end

local function is_vector(t)
  if not is_table(t) then
    return false
  end
  local _t = tbl_copy(t)
  for i = 1, #t do
    if _t[i] == nil or type(_t[i]) ~= "number" then
      return false
    end
    _t[i] = nil
  end
  if next(_t) then
    return false
  end
  return true
end

---Checks if m is matrix
---@param m table
---@return boolean
function matrix.is_matrix(m)
  if not is_table(m) then
    return false
  end
  local col
  if is_vector(m[1]) then
    col = #m[1]
  else
    return false
  end

  for i = 1, #m do
    if not (is_vector(m[i]) and col == #m[i]) then
      return false
    end
  end
  return true
end

---Returns a copy of t
---@param t any[]
---@return any[]
function matrix.copy(t)
  if type(t) ~= "table" then
    return t
  end
  local res = {}
  for i = 1, #t do
    res[i] = matrix.copy(t[i])
  end
  return setmetatable(res, getmetatable(t))
end

---Returns a instance of class matrix
---@param m table
---@param check boolean
---@return matrix
---@overload fun(m:table, check:boolean): boolean, string
function matrix.new(m, check)
  if check and not matrix.is_matrix(m) then
    return false, "The first argument 'm' must be matrix."
  end
  m._row = #m
  m._col = #m[1]
  return setmetatable(m, { __index = matrix })
end

---Initialize a matrix with specified rows and columns.
---@param row integer
---@param col integer
---@param value? number #default 0
---@return matrix
---@overload fun(row: integer, col:integer, value: number): boolean, string
function matrix.init(row, col, value)
  value = value or 0
  if type(value) ~= "number" then
    return false, "The third argument 'value' must be number."
  end
  local res = {}
  for i = 1, row do
    res[i] = {}
    for j = 1, col do
      res[i][j] = value
    end
  end
  res._row = row
  res._col = col
  return matrix.new(res)
end

---Calculates the determinant.
---@return number
---@overload fun(): boolean, string
function matrix:determinant()
  local row, col = self._row, self._col
  if row ~= col then
    return false, "This matrix is not square."
  end
  local n = row

  local det = 1

  local upper = matrix.copy(self)
  for c = 1, n do
    if upper[c][c] == 0 then
      local i = c + 1
      while true do
        det = det * -1
        if upper[i] == nil then
          return 0 -- the rank is less than n
        elseif upper[i][c] ~= 0 then
          break
        end
        i = i + 1
      end
      upper[i], upper[c] = upper[c], upper[i]
    end
    for r = 1, n do
      if c < r then
        local buf = upper[r][c] / upper[c][c]
        for k = 1, n do
          upper[r][k] = upper[r][k] - buf * upper[c][k]
        end
      end
    end
  end

  local res = 1
  for i = 1, n do
    res = res * upper[i][i]
  end

  return res
end

return matrix
