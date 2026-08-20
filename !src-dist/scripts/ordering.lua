local _ENV = _ENV or getfenv()

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
local function emptyTable(var)
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
local function ReadFile(szPath)
    local file, err = io.open(szPath, 'rb')
    if not file then
        return nil, err
    end
    local content = file:read('*a')
    file:close()
    return content
end

-- 通用写出文件
local function WriteFile(szPath, var)
    local file, err = io.open(szPath, 'wb')
    if not file then
        return nil, err
    end
    file:write(var)
    file:close()
    return true
end

-- 反序列化字符串转表
local function str2var(str, env)
    if type(str) ~= 'string' then
        return nil, string.format('bad argument #1 to str2var, string expected, got %s', type(str))
    end

    local fn, err
    if loadstring then
        -- Lua 5.1
        fn, err = loadstring('return ' .. str)
        if not fn then
            fn, err = loadstring(str)
        end
        if fn and env then
            setfenv(fn, env)
        end
    else
        -- Lua 5.2+
        fn, err = load('return ' .. str, 'str2var', 't', env or {})
        if not fn then
            fn, err = load(str, 'str2var', 't', env or {})
        end
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

-- 将table格式化为字符串，有序的
local function var2str(var, indent, nLevel, nMaxLevel)
    local tVisited = setmetatable({}, { __mode = 'k' })
    return serialize(var, indent, nLevel or 0, nMaxLevel, tVisited)
end

-- 文件转表
local function file2var(szFilePath)
    local szVar = ReadFile(szFilePath)
    return str2var(szVar)
end

-- 清除为空的数据
local function clearNil(tData)
    for k, v in pairs(tData) do -- 遍历数据判断是否有空表
        if emptyTable(v) then
            tData[k] = nil
        elseif type(v) == 'table' and k ~= 'aCataclysmBuff' and k ~= 'tMark' and k ~= 'aFocus' then
            tData[k] = clearNil(v)
        end
    end
    return emptyTable(tData) and nil or tData
end

-- 清除无效数据
local function clearInvalidtable(tData, bDelFocusType)
    local aType = { 'BUFF', 'DEBUFF', 'CASTING', 'NPC', 'DOODAD', 'TALK', 'CHAT' }
    for _, szType in ipairs(aType) do
        if tData[szType] then
            for k, _ in pairs(tData[szType]) do -- 遍历类型获取地图ID
                for kk, vv in ipairs_r(tData[szType][k]) do -- 遍历地图获取数据下标
                    if bDelFocusType and vv['aFocus'] then
                        local aFocus = vv['aFocus']
                        for kkk, tFocus in ipairs(aFocus) do
                            tFocus['tType'] = nil
                            if tFocus['dwMapID'] == -1 then
                                tFocus['dwMapID'] = nil
                            end
                            if tFocus['szDisplay'] == '' then
                                tFocus['dwMapID'] = nil
                            end
                        end
                        if emptyTable(aFocus) then
                            vv['aFocus'] = nil
                        end
                    end
                    local tRet = clearNil(vv)
                    if tRet then
                        tData[szType][k][kk] = tRet
                    else
                        table.remove(tData[szType][k], kk)
                    end
                end
            end
        end
    end
end

-- 处理文件（有序化Table转String）
local function processFile(szFileName)
    -- print('Sorting: ' .. szFileName)
    local tData = file2var(szFileName)
    clearInvalidtable(tData, true)
    local szSorted = 'return ' .. var2str(tData, '\t', 0) .. '\n'
    WriteFile(szFileName, szSorted)
    return true
end

-- 批量处理所有传入的文件
local success = true
local errorFiles = {}

for i = 1, #arg do
    local szFileName = arg[i]
    local ok, err = pcall(processFile, szFileName)
    if not ok then
        io.stderr:write('Error processing ' .. szFileName .. ': ' .. err .. '\n')
        errorFiles[#errorFiles + 1] = szFileName
        success = false
    end
end

-- 输出处理结果统计
if success then
    print(string.format('success %d file.', #arg))
else
    io.stderr:write(string.format('failed %d file: %s\n', #errorFiles, table.concat(errorFiles, ', ')))
end

os.exit(success and 0 or 1)

--处理文件
--[[
for i = 1, #arg do
    local szFileName = arg[i]
    print('Sorting: ' .. szFileName)
    local tData = file2var(szFileName)
    local szSorted = 'return ' .. var2str(tData, '\t', 0) .. '\n'
    WriteFile(szFileName, szSorted)
end
--]]
