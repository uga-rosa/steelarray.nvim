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

function matrix.new(row, col, value)
  value = value or 0
  assert(type(value) == "number", "'value' must be number.")
  local res = {}
  for i = 1, row do
    res[i] = {}
    for j = 1, col do
      res[i][j] = value
    end
  end
  res._row = row
  res._col = col
  return res
end

return matrix
