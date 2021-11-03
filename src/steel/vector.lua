---@class Vector
local vector = {}

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

---Checks if t is a vector.
---@param t table
---@return boolean, string
function vector.is_vector(t)
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

---Initializes a vector.
---@param num integer
---@param value number
---@return Vector
function vector.init(num, value)
    value = value or 0
    local res = {}
    for i = 1, num do
        res[i] = value
    end
    return res
end

---Copies the vector.
---@param vec Vector
---@return Vector
function vector.copy(vec)
    local res = {}
    for i = 1, #vec do
        res[i] = vec[i]
    end
    return res
end

---Finds the maximum value of the vector.
---@param v Vector
---@return number
function vector.max(v)
    local res = v[1]
    for i = 2, #v do
        if v[i] > res then
            res = v[i]
        end
    end
    return res
end

---Finds the minimum value of the vector.
---@param v Vector
---@return number
function vector.min(v)
    local res = v[1]
    for i = 2, #v do
        if v[i] < res then
            res = v[i]
        end
    end
    return res
end

---Finds the sum of the vector.
---@param v Vector
---@return number
function vector.sum(v)
    local res = v[1]
    for i = 2, #v do
        res = res + v[i]
    end
    return res
end

---Finds the mean of the vector.
---@param v Vector
---@return number
function vector.mean(v)
    return vector.sum(v) / #v
end

---Finds the variance of the vector.
---@param v Vector
---@return number
function vector.variance(v, unbiased)
    local n = unbiased and #v - 1 or #v
    local mean = vector.mean(v)
    local res = 0
    for i = 1, #v do
        res = res + (v[i] - mean) ^ 2
    end
    return res / n
end

---Finds the standard deviation of the vector.
---@param v Vector
---@return number
function vector.sd(v, unbiased)
    return math.sqrt(vector.variance(v, unbiased))
end

---Creates the histogram of the vector.
---@param v Vector
---@param bins integer
---@param range {min: number, max: number}
---@param density boolean
---@return Vector histogram
---@return Vector bin_edges
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
---@param a Vector
---@param b Vector
---@return Vector
---@overload fun(a: number, b:Vector): Vector
---@overload fun(a: Vector, b:number): Vector
local function vec_calc(a, b, cal)
    local typeA = type(a)
    local typeB = type(b)
    local res = {}
    if typeA == "table" and typeB == "table" then
        assert(#a == #b, ("attempt to calculate between vectors of different sizes (%s and %s)"):format(#a, #b))
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
        assert(false, ("attempt to calculate between %s and %s"):format(typeA, typeB))
    end
    return res
end

local function add(a, b)
    return a + b
end

---Addition
---@param a Vector
---@param b Vector
---@return Vector
---@overload fun(a: number, b:Vector): Vector
---@overload fun(a: Vector, b:number): Vector
function vector.add(a, b)
    return vec_calc(a, b, add)
end

local function sub(a, b)
    return a - b
end

---Subtraction
---@param a Vector
---@param b Vector
---@return Vector
---@overload fun(a: number, b:Vector): Vector
---@overload fun(a: Vector, b:number): Vector
function vector.sub(a, b)
    return vec_calc(a, b, sub)
end

local function mul(a, b)
    return a * b
end

---Multiplication
---@param a Vector
---@param b Vector
---@return Vector
---@overload fun(a: number, b:Vector): Vector
---@overload fun(a: Vector, b:number): Vector
function vector.mul(a, b)
    return vec_calc(a, b, mul)
end

local function div(a, b)
    return a / b
end

---Division
---@param a Vector
---@param b Vector
---@return Vector
---@overload fun(a: number, b:Vector): Vector
---@overload fun(a: Vector, b:number): Vector
function vector.div(a, b)
    return vec_calc(a, b, div)
end

---inner product
---@param a Vector
---@param b Vector
---@return number
function vector.prod(a, b)
    if type(a) ~= "table" then
        error("a must be table")
    end
    if type(b) ~= "table" then
        error("b must be table")
    end
    if #a == #b then
        local res = 0
        for i = 1, #a do
            res = res + a[i] * b[i]
        end
        return res
    else
        error("#a must be equal to #b")
    end
end

return vector
