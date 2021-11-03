local str = {}

function str.startswith(s, prefix)
    return s:sub(1, #prefix) == prefix
end

function str.endswith(s, suffix)
    return #suffix == 0 or s:sub(-#suffix) == suffix
end

function str.trim(s)
    return s:match("^%s*(.*%S)") or ""
end

function str.gsplit(s, sep, plain)
    local start = 1
    local done = false

    local function _pass(i, j, ...)
        if i then
            assert(j + 1 > start, "Infinite loop detected")
            local seg = s:sub(start, i - 1)
            start = j + 1
            return seg, ...
        else
            done = true
            return s:sub(start)
        end
    end

    return function()
        if done or (s == "" and sep == "") then
            return
        end
        if sep == "" then
            if start == #s then
                done = true
            end
            return _pass(start + 1, start)
        end
        return _pass(s:find(sep, start, plain))
    end
end

function str.split(s, sep, kwargs)
    kwargs = kwargs or {}
    local plain = kwargs.plain
    local trimempty = kwargs.trimempty

    local t = {}
    local skip = trimempty
    for c in str.gsplit(s, sep, plain) do
        if c ~= "" then
            skip = false
        end

        if not skip then
            table.insert(t, c)
        end
    end

    if trimempty then
        for i = #t, 1, -1 do
            if t[i] ~= "" then
                break
            end
            table.remove(t, i)
        end
    end

    return t
end

return str
