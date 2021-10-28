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
---@param init number
---@return Vector
function vector.init(num, init)
    init = init or 0
    local res = {}
    for i = 1, num do
        res[i] = init
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
---@param self Vector
---@return number
function vector:max()
    local res = self[1]
    for i = 2, #self do
        if self[i] > res then
            res = self[i]
        end
    end
    return res
end

---Finds the minimum value of the vector.
---@param self Vector
---@return number
function vector:min()
    local res = self[1]
    for i = 2, #self do
        if self[i] < res then
            res = self[i]
        end
    end
    return res
end

---Finds the sum of the vector.
---@param self Vector
---@return number
function vector:sum()
    local res = self[1]
    for i = 2, #self do
        res = res + self[i]
    end
    return res
end

---Finds the mean of the vector.
---@param self Vector
---@return number
function vector:mean()
    return vector.sum(self) / #self
end

---Finds the variance of the vector.
---@param self Vector
---@return number
function vector:variance(unbiased)
    local n = unbiased and #self - 1 or #self
    local mean = vector.mean(self)
    local res = 0
    for i = 1, #self do
        res = res + (self[i] - mean) ^ 2
    end
    return res / n
end

---Finds the standard deviation of the vector.
---@param self Vector
---@return number
function vector:standard_deviation(unbiased)
    return math.sqrt(vector.variance(self, unbiased))
end

---Creates the histogram of the vector.
---@param self Vector
---@param bins integer
---@param range {min: number, max: number}
---@param density boolean
---@return Vector histogram
---@return Vector bin_edges
function vector:histogram(bins, range, density)
    local vec = vector.copy(self)
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
