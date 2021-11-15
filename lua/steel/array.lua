---@class Array: any[]
local Array = {}
Array.__index = Array

---Copies an array recursively.
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

---Returns a new instance of Array.
---@param t? table
---@param need_check? boolean
---@return array Array
function Array.new(t, need_check)
    if need_check then
        Array.validate({
            t = { t, "array", true },
        })
    end
    return setmetatable(t or {}, Array)
end

---Returns an array of step (default: 1) increments from first to last.
---@param first integer
---@param last integer
---@param step? integer
---@return integer[]
function Array.range(first, last, step)
    Array.validate({
        first = { first, "number" },
        last = { last, "number" },
        step = { step, "number", true },
    })

    step = step or 1
    local t = {}
    for i = first, last, step do
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
    Array.validate({
        e = { e, "any" },
        n = { n, "number" },
    })

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
    Array.validate({
        t = { t, "array" },
        n = { n, "number" },
    })

    local res = {}
    for _ = 1, n do
        for _, v in ipairs(t) do
            table.insert(res, v)
        end
    end
    return Array.new(res)
end

---Returns the array combined multiple arrays.
---@vararg any[]
---@return any[] Array
function Array.concat(...)
    local res = {}
    for _, arg in ipairs({ ... }) do
        if type(arg) == "table" then
            for _, v in ipairs(arg) do
                table.insert(res, v)
            end
        else
            table.insert(res, arg)
        end
    end
    return Array.new(res)
end

----- Array method from here. -----

---Returns the Array with the result of func applied to all the elements in t.
---The return value can be omitted by setting the second argument to true.
---@generic T1, T2
---@param self Array #T1[]
---@param func fun(a: T1): T2
---@param no_return? boolean
---@return Array #T2[]
function Array:map(func, no_return)
    Array.validate({
        self = { self, "array" },
        func = { func, "function" },
    })

    if no_return then
        for _, v in ipairs(self) do
            func(v)
        end
    else
        local res = Array.new()
        for i, v in ipairs(self) do
            res[i] = func(v)
        end
        return res
    end
end

---Returns the Array with all the elements of t that fullfilled the func.
---@param self Array
---@param func fun(a: any): boolean
---@return Array
function Array:filter(func)
    Array.validate({
        self = { self, "array" },
        func = { func, "function" },
    })

    local res = {}
    for i = 1, #self do
        if func(self[i]) then
            table.insert(res, self[i])
        end
    end
    return Array.new(res)
end

local function in_range(t, first, last)
    Array.validate({
        t = { t, "array" },
        first = { first, "number" },
        last = { last, "number", true },
    })

    if first < 0 then
        first = #t + first + 1
    elseif first == 0 then
        error("first should not be zero")
    elseif first > #t then
        error("first is grater than t's length: " .. first .. " > " .. #t)
    end

    last = last or #t
    if last < 0 then
        last = #t + last + 1
    elseif last == 0 then
        error("last should not be zero")
    elseif last > #t then
        error("last is grater than t's length: " .. last .. " > " .. #t)
    end
    assert(first <= last, string.format("first is grater than last: %s > %s", first, last))
    return first, last
end

---Returns the slice of the array t.
---Negative numbers can also be used for first and last.
---@param self Array
---@param first integer
---@param last? integer
---@return Array
function Array:slice(first, last)
    first, last = in_range(self, first, last)
    local res = {}
    for i = first, last do
        table.insert(res, self[i])
    end
    return Array.new(res)
end

---Deletes the elements of the array t at positions `first..last`
---@param self Array
---@param first integer
---@param last? integer
---@return Array
function Array:delete(first, last)
    first, last = in_range(self, first, last)
    for _ = first, last do
        table.remove(self, first)
    end
    return self
end

---Returns the array with the elements inserted from src into t at position pos.
---@param self Array
---@param src Array
---@param pos? integer
---@return Array
---Array.insert({1, 2, 3, 4, 5}, {"a", "b", "c"}, 3)
--- -> {1, 2, "a", "b", "c", 3, 4, 5}
function Array:insert(src, pos)
    Array.validate({
        self = { self, "array" },
        src = { src, "array" },
        pos = { pos, "number", true },
    })

    if pos then
        for i, v in ipairs(src) do
            table.insert(self, pos + i - 1, v)
        end
    else
        for _, v in ipairs(src) do
            table.insert(self, v)
        end
    end
    return self
end

---Wrapping table.insert as a method.
---@param e any
---@param pos? number
function Array:append(e, pos)
    Array.validate({
        self = { self, "array" },
        e = { e, "any" },
        pos = { pos, "number", true },
    })

    if pos then
        table.insert(self, pos, e)
    else
        table.insert(self, e)
    end
end

---Checks if t contains e.
---@param self Array
---@param e any
---@return boolean
function Array:contains(e)
    Array.validate({
        self = { self, "array" },
        e = { e, "any" },
    })

    for _, v in ipairs(self) do
        if v == e then
            return true
        end
    end
    return false
end

---Returns how many e's are contained in the array t.
---@param self Array
---@param e any
---@return integer
function Array:count(e)
    Array.validate({
        self = { self, "array" },
        e = { e, "any" },
    })

    local res = 0
    for _, v in ipairs(self) do
        if v == e then
            res = res + 1
        end
    end
    return res
end

---Checks if any element of t fullfilled func.
---@param self Array
---@param func fun(x: any): boolean
---@return boolean
function Array:any(func)
    Array.validate({
        self = { self, "array" },
        func = { func, "function" },
    })

    for _, v in ipairs(self) do
        if func(v) then
            return true
        end
    end
    return false
end

---Checks if all the elements of t fullfilled func.
---@param self Array
---@param func fun(x: any): boolean
---@return boolean
function Array:all(func)
    Array.validate({
        self = { self, "array" },
        func = { func, "function" },
    })

    for _, v in ipairs(self) do
        if not func(v) then
            return false
        end
    end
    return true
end

---Returns the array without duplicates.
---@param self Array
---@return Array
function Array:deduplicate()
    Array.validate({
        self = { self, "array" },
    })

    local res = Array.new()
    for _, v in ipairs(self) do
        if not res:contains(v) then
            res:append(v)
        end
    end
    return res
end

---Wrapping table.sort as a method.
---@param self Array
---@param cmp? fun(x: any, y: any): boolean #default: `<`
---@return Array
function Array:sort(cmp)
    Array.validate({
        self = { self, "array" },
        cmp = { cmp, "function", true },
    })

    table.sort(self, cmp)
    return self -- for chain
end

---Returns the copy of the sorted array t.
---@param self Array
---@param cmp? fun(x: any, y: any): boolean #default: `<`
---@return Array
function Array:sorted(cmp)
    Array.validate({
        self = { self, "array" },
        cmp = { cmp, "function", true },
    })

    local res = Array.copy(self)
    table.sort(res, cmp)
    return res
end

---Flattens the array t
---@param self Array
---@return Array
function Array:flatten()
    Array.validate({
        self = { self, "array" },
    })

    local res = Array.new()
    local function _flatten(arr)
        for _, v in ipairs(arr) do
            if type(v) == "table" then
                _flatten(v)
            else
                res:append(v)
            end
        end
    end
    _flatten(self)
    return res
end

---Reverses the content of the array t.
---@param self Array
---@return Array
function Array:reverse()
    Array.validate({
        self = { self, "array" },
    })

    local i, n = 1, #self
    while i < n do
        self[i], self[n] = self[n], self[i]
        i = i + 1
        n = n - 1
    end
    return self -- for chain
end

---Returns the copy of reverse of the array self.
---@param self Array
---@return Array
function Array:reversed()
    local res = Array.copy(self)
    return Array.reverse(res)
end

---Returns the result of left convolution.
---@generic T
---@param self Array #T[]
---@param func fun(a: T, b: T): T
---@param first? T
---@return T
function Array:foldl(func, first)
    Array.validate({
        self = { self, "array" },
        func = { func, "function" },
    })

    local res, start
    if first then
        assert(#self > 0, "Can't fold empty array")
        res = first
        start = 1
    else
        assert(#self > 1, "Only one element or less.")
        res = self[1]
        start = 2
    end
    for i = start, #self do
        res = func(res, self[i])
    end
    return res
end

---Returns the result of right convolution.
---@generic T
---@param self Array #T[]
---@param func fun(a: T, b: T): T
---@param first? T
---@return T
function Array:foldr(func, first)
    Array.validate({
        self = { self, "array" },
        func = { func, "function" },
    })

    local res, start
    if first then
        assert(#self > 0, "Can't fold empty array")
        res = first
        start = #self
    else
        assert(#self > 1, "Only one element or less.")
        res = self[#self]
        start = #self - 1
    end
    for i = start, 1, -1 do
        res = func(res, self[i])
    end
    return res
end

local function is_callable(f)
    if type(f) == "function" then
        return true
    end
    local m = getmetatable(f)
    if m == nil then
        return false
    end
    return type(m.__call) == "function"
end

local function _table_copy(t)
    if type(t) ~= "table" then
        return t
    end
    local res = {}
    for k, v in pairs(t) do
        res[k] = _table_copy(v)
    end
    return setmetatable(res, getmetatable(t))
end

local function _is_array(t)
    if getmetatable(t) == Array then
        return true
    end

    if type(t) ~= "table" then
        return false
    end

    local _t = _table_copy(t)
    for i = 1, #_t do
        if _t[i] == nil then
            return false
        end
        _t[i] = nil
    end
    if next(_t) then
        return false
    end
    return true
end

local function _is_type(val, t)
    if t == "array" then
        return _is_array(val)
    elseif t == "any" then
        return val ~= nil
    end
    return type(val) == t or (t == "callable" and is_callable(val))
end

local type_names = {
    array = "array",
    a = "array",
    table = "table",
    t = "table",
    string = "string",
    s = "string",
    number = "number",
    n = "number",
    boolean = "boolean",
    b = "boolean",
    ["function"] = "function",
    f = "function",
    callable = "callable",
    c = "callable",
    ["nil"] = "nil",
    thread = "thread",
    userdata = "userdata",
    any = "any",
}

---vim.validate with array and any (not nil) added.
---@param opt any
function Array.validate(opt)
    if type(opt) ~= "table" then
        error("opt: expected table, got " .. type(opt), 2)
    end

    for param_name, spec in pairs(opt) do
        if type(spec) ~= "table" then
            error(string.format("opt[%s]: expected table, got %s", param_name, type(spec)), 2)
        end

        local val = spec[1]
        local t = spec[2]
        local optional = spec[3] == true

        if type(t) == "string" then
            local t_name = type_names[t]
            if not t_name then
                error("invalid type name: " .. t, 2)
            end
            if not (optional and val == nil or _is_type(val, t_name)) then
                error(string.format("%s: expected %s, got %s", param_name, t_name, type(val)), 2)
            end
        elseif is_callable(t) then
            local valid, optional_message = t(val)
            if not valid then
                local error_message = ("%s: expected %s, got %s"):format(param_name, (spec[3] or "?"), type(val))
                if optional_message then
                    error_message = error_message .. ". Info: " .. optional_message
                end
                error(error_message, 2)
            end
        else
            error("invalid type name: " .. t, 2)
        end
    end
end

return Array
