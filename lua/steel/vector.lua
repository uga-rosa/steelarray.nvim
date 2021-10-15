---@alias vector number[]
local vector = {}

---Checks if vec is a vector.
---@param vec table
---@return boolean
function vector.is_vector(vec)
  local c = 0
  for _, v in pairs(vec) do
    if type(v) ~= "number" then
      return false
    end
    c = c + 1
  end
  return #vec == c
end

---Initializes a vector.
---@param num integer
---@param init number
---@return vector
function vector.init(num, init)
  init = init or 0
  local res = {}
  for i = 1, num do
    res[i] = init
  end
  return res
end

---Copies the vector.
---@param vec vector
---@return vector
function vector.copy(vec)
  local res = {}
  for i = 1, #vec do
    res[i] = vec[i]
  end
  return res
end

---Finds the maximum value of the vector.
---@param vec vector
---@return number
function vector.max(vec)
  local res = vec[1]
  for i = 2, #vec do
    if vec[i] > res then
      res = vec[i]
    end
  end
  return res
end

---Finds the minimum value of the vector.
---@param vec vector
---@return number
function vector.min(vec)
  local res = vec[1]
  for i = 2, #vec do
    if vec[i] < res then
      res = vec[i]
    end
  end
  return res
end

---Finds the sum of the vector.
---@param vec vector
---@return number
function vector.sum(vec)
  local res = vec[1]
  for i = 2, #vec do
    res = res + vec[i]
  end
  return res
end

---Finds the mean of the vector.
---@param vec vector
---@return number
function vector.mean(vec)
  return vector.sum(vec) / #vec
end

---Finds the variance of the vector.
---@param vec vector
---@return number
function vector.variance(vec, unbiased)
  local n = unbiased and #vec - 1 or #vec
  local mean = vector.mean(vec)
  local res = 0
  for i = 1, #vec do
    res = res + (vec[i] - mean) ^ 2
  end
  return res / n
end

---Finds the standard deviation of the vector.
---@param vec vector
---@return number
function vector.standard_deviation(vec, unbiased)
  return math.sqrt(vector.variance(vec, unbiased))
end

---Creates the histogram of the vector.
---@param v vector
---@param bins integer
---@param range {min: number, max: number}
---@param density boolean
---@return vector histogram
---@return vector bin_edges
function vector.histogram(v, bins, range, density)
  local vec = vector.copy(v)
  table.sort(vec)
  bins = bins or 10
  range = range or { vec[1], vec[#vec] }
  density = density or false

  local width = (range[2] - range[1]) / bins
  local bin_edges = { [1] = range[1], [bins + 1] = range[2] }
  for i = 2, bins do
    bin_edges[i] = range[1] + width * (i - 1)
  end

  local hist = vector.init(bins)
  local i, j = 1, 1
  while j < bins do
    if vec[i] < bin_edges[j + 1] then
      hist[j] = hist[j] + 1
      i = i + 1
    else
      j = j + 1
    end
  end
  hist[bins] = #vec - i + 1

  if density then
    for k = 1, #hist do
      hist[k] = hist[k] / #vec
    end
  end

  return hist, bin_edges
end

---Some kind of calculation.
---@param a vector
---@param b vector
---@return vector
---@overload fun(a: number, b:vector): vector
---@overload fun(a: vector, b:number): vector
local function vec_calc(a, b, cal)
  local typeA = type(a)
  local typeB = type(b)
  local res = {}
  if typeA == "table" and typeB == "table" then
    assert(#a == #b, ("attempt to subtract between vectors of different sizes (%s and %s)"):format(#a, #b))
    for i = 1, #a do
      res[i] = cal(a[i] - b[i])
    end
  elseif typeA == "number" and typeB == "table" then
    for i = 1, #b do
      res[i] = cal(a - b[i])
    end
  elseif typeA == "table" and typeB == "number" then
    for i = 1, #a do
      res[i] = cal(a[i] - b)
    end
  else
    assert(false, ("attempt to subtract between %s and %s"):format(typeA, typeB))
  end
  return res
end

local function add(a, b)
  return a + b
end

---Addition
---@param a vector
---@param b vector
---@return vector
---@overload fun(a: number, b:vector): vector
---@overload fun(a: vector, b:number): vector
function vector.add(a, b)
  return vec_calc(a, b, add)
end

local function sub(a, b)
  return a - b
end

---Subtraction
---@param a vector
---@param b vector
---@return vector
---@overload fun(a: number, b:vector): vector
---@overload fun(a: vector, b:number): vector
function vector.sub(a, b)
  return vec_calc(a, b, sub)
end

local function mul(a, b)
  return a * b
end

---Multiplication
---@param a vector
---@param b vector
---@return vector
---@overload fun(a: number, b:vector): vector
---@overload fun(a: vector, b:number): vector
function vector.mul(a, b)
  return vec_calc(a, b, mul)
end

local function div(a, b)
  return a / b
end

---Division
---@param a vector
---@param b vector
---@return vector
---@overload fun(a: number, b:vector): vector
---@overload fun(a: vector, b:number): vector
function vector.div(a, b)
  return vec_calc(a, b, div)
end

return vector