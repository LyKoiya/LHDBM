package.path = package.path .. ';.\\!src-dist\\scripts\\?.lua'
local X = require('Base') 

-- 清除为空的数据
local function clearNil(tData)
    for k, v in pairs(tData) do -- 遍历数据判断是否有空表
        if X.emptyTable(v) then
            tData[k] = nil
        elseif type(v) == 'table' and k ~= 'aCataclysmBuff' and k ~= 'tMark' and k ~= 'aFocus' then
            tData[k] = clearNil(v)
        end
    end
    return X.emptyTable(tData) and nil or tData
end

-- 清除无效数据
local function clearInvalidtable(tData, bDelFocusType)
    for _, szType in ipairs(X.MY_TM_TYPE_LIST) do
        if tData[szType] then
            for k, _ in pairs(tData[szType]) do -- 遍历类型获取地图ID
                for kk, vv in X.ipairs_r(tData[szType][k]) do -- 遍历地图获取数据下标
                    if bDelFocusType and vv.aFocus then
                        local aFocus = vv.aFocus
                        for kkk, tFocus in ipairs(aFocus) do
                            tFocus.tType = nil
                            if tFocus.dwMapID == -1 then
                                tFocus.dwMapID = nil
                            end
                            if tFocus.szDisplay == '' then
                                tFocus.szDisplay = nil
                            end
                        end
                        if X.emptyTable(aFocus) then
                            vv.aFocus = nil
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

-- 刷新数据修改时间戳
local function refreshTimeStamp(tData, nTimeStamp)
    if not tData then
        return nil
    end
    tData.__meta = tData.__meta or {}
    tData.__meta.nTimeStamp = nTimeStamp or os.time()
    return tData.__meta.nTimeStamp
end

-- 处理文件（有序化Table转String）
local function processFile(szFileName)
    -- print('Sorting: ' .. szFileName)
    local tData = X.file2var(szFileName)
    if not tData then
        return false
    end
    clearInvalidtable(tData, true)
    refreshTimeStamp(tData)
    local szSorted = 'return ' .. X.var2str(tData, '\t', 0) .. '\n'
    X.WriteFile(szFileName, szSorted)
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
