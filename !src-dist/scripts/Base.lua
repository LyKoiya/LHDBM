local M = {}

M.MY_TM_TYPE_LIST = { 'BUFF', 'DEBUFF', 'CASTING', 'NPC', 'DOODAD', 'TALK', 'CHAT' }

-- 打印表
function M.printTable(var)
    local str = M.var2str(var)
    print(str)
    return str
end

-- 变量是否问空
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

-- 深拷贝表
function M.clone(var)
    local szType = type(var)
    if szType == 'nil' or szType == 'boolean' or szType == 'number' or szType == 'string' then
        return var
    elseif szType == 'table' then
        local t = {}
        for key, val in pairs(var) do
            key = M.clone(key)
            val = M.clone(val)
            t[key] = val
        end
        return t
    elseif szType == 'function' or szType == 'userdata' then
        return nil
    else
        return nil
    end
end

-- 简单JSON解析
function M.parseJson(str)
    str = str:gsub("^%s+", ""):gsub("%s+$", "")
    if str:match("^{.*}$") then
        local result = {}
        for key, value in str:gmatch('"([^"]+)"%s*:%s*([^,}]+)') do
            value = value:gsub('^%s*"', ""):gsub('"$', "")
            if value == "true" then value = true end
            if value == "false" then value = false end
            result[key] = value
        end
        return result
    end
    return nil
end

-- 判断数据是否为字符串
---@param var any @需要判断的数据
---@return boolean @是否为字符串
function M.IsString(var)
    return type(var) == 'string'
end

-- 取字符串左边
function M.strLeft(szText, delimiter)
    if M.IsString(szText) then
        local pos = szText:find(delimiter, 1, true)
        if pos then
            return szText:sub(1, pos - 1)
        else
            return szText
        end
    end
end

-- 取字符串右边
function M.strRight(szText, delimiter)
    if M.IsString(szText) then
        local pos = szText:find(delimiter, 1, true)
        if pos then
            return szText:sub(pos + 1)
        else
            return szText
        end
    end
end

-- 取字符串中间
function M.strMid(szText, delimiter1, delimiter2)
    if M.IsString(szText) then
        local left = szText:find(delimiter1, 1, true)
        local right = szText:find(delimiter2, 1, true)
        if left and right then
            return szText:sub(left + #delimiter1, right - 1)
        end
    end
    return szText
end

-- 删除字符串末尾的指定字符
function M.strDelEnd(szText, delimiter)
    if M.IsString(szText) then
        local pos = szText:sub(-#delimiter)
        if pos == delimiter then
            return M.strDelEnd(szText:sub(1, -#delimiter - 1), delimiter)
        else
            return szText
        end
    end
end

-- 删除字符串开头的指定字符
function M.strDelStart(szText, delimiter)
    if M.IsString(szText) then
        local pos = szText:sub(1, #delimiter)
        if pos == delimiter then
            return M.strDelStart(szText:sub(#delimiter + 1), delimiter)
        else
            return szText
        end
    end
end

-- 删除字符串两端的指定字符
function M.strDelBothEnd(szText, delimiter)
    return M.strDelEnd(M.strDelStart(szText, delimiter), delimiter)
end

-- 分隔字符串
function M.split(str, delimiter)
    local result = {}

    -- 如果字符串为空，返回空表
    if str == nil or str == "" then
        return result
    end

    -- 如果分隔符为空，返回包含整个字符串的表
    if delimiter == nil or delimiter == "" then
        return { str }
    end

    local start_pos = 1
    while true do
        -- 使用 string.find 并启用 plain 模式（不解析正则）
        local end_pos = string.find(str, delimiter, start_pos, true)

        if not end_pos then
            -- 没有更多分隔符，取最后一段
            table.insert(result, string.sub(str, start_pos))
            break
        end

        -- 提取从 start_pos 到 end_pos-1 的子串
        local segment = string.sub(str, start_pos, end_pos - 1)
        table.insert(result, segment)

        -- 跳过分隔符
        start_pos = end_pos + #delimiter

        -- 如果已经到达字符串末尾，退出循环
        if start_pos > #str then
            break
        end
    end

    return result
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
        if tVisited then
            if tVisited[var] then
                table.insert(t, '"<circular reference>"')
                return table.concat(t)
            end
            tVisited[var] = true
        end

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
---@param str  string
---@param env? table
---@return table | nil, string | nil
function M.str2var(str, env)
    if type(str) ~= 'string' then
        return nil, string.format('bad argument #1 to str2var, string expected, got %s', type(str))
    end

    local fn, err
    -- Lua 5.1
    fn, err = loadstring(str)
    if not fn then
        fn, err = loadstring('return ' .. str)
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
    -- local tVisited = setmetatable({}, { __mode = 'k' })
    return serialize(var, indent, nLevel or 0, nMaxLevel, nil)
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

-- 判断文件是否存在
function M.fileExists(path)
	local f = io.open(path, "r")
	if f then
		f:close()
		return true
	end
	return false
end

M.empty = empty
M.ipairs_r = ipairs_r

return M
