local lfs = require("lfs")

local function contains(t, e)
    if type(t) == "table" then
        if #t == 0 then
            return true
        end
        for i = 1, #t do
            if t[i] == e then
                return true
            end
        end
        return false
    else
        return t == e
    end
end

---Walks over the directory dir and returns array of objects in dir.
---@param dir string
---@param mode? string|string[]
---@return string[]
function lfs.walkdir(dir, mode)
    mode = mode or {}
    local res, c = {}, 0
    for obj in lfs.dir(dir) do
        if obj ~= "." and obj ~= ".." then
            local f = dir .. "/" .. obj
            local attr = lfs.attributes(f)
            if contains(mode, attr.mode) then
                c = c + 1
                res[c] = f
            end
        end
    end
    return res
end

---Returns all lines in the file f
---@param f string
---@return string[]
function lfs.readlines(f)
    local res, c = {}, 0
    for line in io.lines(f) do
        c = c + 1
        res[c] = line
    end
    return res
end

return lfs
