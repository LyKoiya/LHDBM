local M = {}

M.MY_TM_TYPE_LIST = { 'BUFF', 'DEBUFF', 'CASTING', 'NPC', 'DOODAD', 'TALK', 'CHAT' }

local function empty(var)
    local szType = type(var)
    if szType == 'nil' then
        return true
    elseif szType == 'boolean' then
        return var
    elseif szType == 'number' then
        return var == 0
    elseif szType == 'string' then
        return var == ''
    elseif szType == 'function' then
        return false
    elseif szType == 'table' then
        return next(var) == nil
    else
        return false
    end
end

-- 是否为空表
function M.emptyTable(var)
    local szType = type(var)
    if szType == 'nil' then
        return true
    elseif szType == 'table' then
        return next(var) == nil
    else
        return false
    end
end

-- 倒序迭代器
local ipairs_r
do
    local function fnBpairs(tab, nIndex)
        nIndex = nIndex - 1
        if nIndex > 0 then
            return nIndex, tab[nIndex]
        end
    end
    function ipairs_r(tab)
        return fnBpairs, tab, #tab + 1
    end
end

-- 通用读取文件
function M.ReadFile(szPath)
    local file, err = io.open(szPath, 'rb')
    if not file then
        return nil, err
    end
    local szContent = file:read('*a')
    file:close()
    return szContent
end

-- 通用写出文件
function M.WriteFile(szPath, var)
    local file, err = io.open(szPath, 'wb')
    if not file then
        return nil, err
    end
    file:write(var)
    file:close()
    return true
end
-- 有序序列化，防止嵌合引用无限递归
local function serialize(var, indent, nLevel, nMaxLevel, tVisited)
    if nMaxLevel and nLevel >= nMaxLevel then
        indent = nil
    end
    local t = {}
    local szType = type(var)
    if szType == 'nil' then
        table.insert(t, 'nil')
    elseif szType == 'number' then
        table.insert(t, tostring(var))
    elseif szType == 'string' then
        table.insert(t, string.format('%q', var))
    elseif szType == 'function' then
        local s = string.dump(var)
        table.insert(t, 'loadstring("')
        for i = 1, #s, 2000 do
            table.insert(t, table.concat({ '', string.byte(s, i, i + 2000 - 1) }, '\\'))
        end
        table.insert(t, '")')
    elseif szType == 'boolean' then
        table.insert(t, tostring(var))
    elseif szType == 'table' then
        if tVisited == nil then
            tVisited = setmetatable({}, { __mode = 'k' })
        end
        if tVisited[var] then
            table.insert(t, '"<circular reference>"')
            return table.concat(t)
        end
        tVisited[var] = true

        table.insert(t, '{')
        local s_tab_equ = '='
        if indent then
            s_tab_equ = ' = '
            if not empty(var) then
                table.insert(t, '\n')
            end
        end

        -- 收集并排序所有键
        local keys = {}
        for k in pairs(var) do
            keys[#keys + 1] = k
        end
        table.sort(keys, function (a, b)
            if type(a) == 'number' and type(b) == 'number' then
                return a < b
            end
            if type(a) == 'string' and type(b) == 'string' then
                return a < b
            end
            return tostring(a) < tostring(b)
        end)

        -- 判断是否为纯数组
        local nohash = true
        if #keys > 0 then
            for i, k in ipairs(keys) do
                if type(k) ~= 'number' or k ~= i then
                    nohash = false
                    break
                end
            end
        else
            nohash = false
        end

        -- 判断数字键部分是否连续（用于混合表中的数组风格输出）
        local num_is_array = false
        if not nohash then
            num_is_array = true
            local idx = 1
            for _, k in ipairs(keys) do
                if type(k) == 'number' then
                    if k ~= idx then
                        num_is_array = false
                        break
                    end
                    idx = idx + 1
                else
                    break
                end
            end
            if idx == 1 then
                num_is_array = false
            end
        end

        -- 按排序后的键遍历
        for _, key in ipairs(keys) do
            local val = var[key]
            if nohash or (num_is_array and type(key) == 'number') then
                -- 纯数组 或 混合表中连续数字键部分：省略键名
                if indent then
                    table.insert(t, string.rep(indent, nLevel + 1))
                end
                table.insert(t, serialize(val, indent, nLevel + 1, nMaxLevel, tVisited))
                table.insert(t, ',')
                if indent then
                    table.insert(t, '\n')
                end
            elseif type(key) == 'string' and key:find('^[a-zA-Z_][a-zA-Z0-9_]*$') then
                if indent then
                    table.insert(t, string.rep(indent, nLevel + 1))
                end
                table.insert(t, key)
                table.insert(t, s_tab_equ)
                table.insert(t, serialize(val, indent, nLevel + 1, nMaxLevel, tVisited))
                table.insert(t, ',')
                if indent then
                    table.insert(t, '\n')
                end
            else
                if indent then
                    table.insert(t, string.rep(indent, nLevel + 1))
                end
                table.insert(t, '[')
                table.insert(t, serialize(key, indent, nLevel + 1, nMaxLevel, tVisited))
                table.insert(t, ']')
                table.insert(t, s_tab_equ)
                table.insert(t, serialize(val, indent, nLevel + 1, nMaxLevel, tVisited))
                table.insert(t, ',')
                if indent then
                    table.insert(t, '\n')
                end
            end
        end

        if not empty(var) then
            if indent then
                table.insert(t, string.rep(indent, nLevel))
            else
                table.remove(t)
            end
        end
        table.insert(t, '}')
    else
        table.insert(t, '"')
        table.insert(t, tostring(var))
        table.insert(t, '"')
    end
    return table.concat(t)
end

-- 反序列化,字符串转表
function M.str2var(str, env)
    if type(str) ~= 'string' then
        return nil, string.format('bad argument #1 to str2var, string expected, got %s', type(str))
    end

    local fn, err
    -- Lua 5.1
    fn, err = loadstring('return ' .. str)
    if not fn then
        fn, err = loadstring(str)
    end
    if fn and env then
        setfenv(fn, env)
    end

    if not fn then
        return nil, string.format('failed to parse "%s": %s', str, err or 'unknown error')
    end

    local ok, result = pcall(fn)
    if not ok then
        return nil, string.format('execution error in "%s": %s', str, result)
    end

    return result
end

-- 文件转表
function M.file2var(szFilePath)
    local fn, err = loadfile(szFilePath)
    if fn then
        return fn()
    else
        return nil, err
    end

    -- return dofile(szFilePath)
end

-- 将table格式化为字符串，有序的
function M.var2str(var, indent, nLevel, nMaxLevel)
    local tVisited = setmetatable({}, { __mode = 'k' })
    return serialize(var, indent, nLevel or 0, nMaxLevel, tVisited)
end

-- 反转数组顺序
function M.arrayReverse(arr)
    local len = #arr
    for i = 1, math.floor(#arr / 2) do
        local j = len - i + 1
        arr[i], arr[j] = arr[j], arr[i]
    end
    return arr
end

M.empty = empty
M.ipairs_r = ipairs_r

return M
