package.path = package.path .. ';.\\!src-dist\\scripts\\?.lua'
local X = require('Base')
-- os.execute("chcp 936")
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

-- 检查表内相似键
---@param szTable TeamMonData       需要检查的表
---@param szType  string            类型
---@param dwMapID integer | number? 地图ID
---@param dwID    integer | string  ID
---@param nLevel  integer | string  等级
local function CheckSameData(szTable, szType, dwMapID, dwID, nLevel)
    if szTable[szType][dwMapID] then
        if dwMapID ~= -9 then
            for k, v in ipairs(szTable[szType][dwMapID]) do
                if type(dwID) == 'string' then
                    if dwID == v.szContent and nLevel == v.szTarget then
                        return k, v
                    end
                else
                    if dwID == v.dwID and (not v.bCheckLevel or nLevel == v.nLevel) then
                        return k, v
                    end
                end
            end
        end
    end
end
local function deepEqual(a, b)
    if a == b then return true end -- 同一引用或相同原始值
    if type(a) ~= "table" or type(b) ~= "table" then
        return false -- 类型不同 / 原始值不等
    end
    -- 比较 a 的每个键值
    for k, v in pairs(a) do
        if not deepEqual(v, b[k]) then
            return false
        end
    end
    -- 再确认 b 没有多余的键
    for k in pairs(b) do
        if a[k] == nil then
            return false
        end
    end
    return true
end

function DBMdiff(old, new)
    if not old and not new then
        return nil
    end

    local tOld = X.clone(old) or {}
    local tNew = X.clone(new) or {}

    local LH_ADD = { szChanged = 'ADD' }
    local LH_MODIFY = { szChanged = 'MODIFY' }
    local LH_REMOVE = { szChanged = 'REMOVE' }

    local tRet, tData
    tRet, tData = {}, {}
    tRet.ADD, tRet.REMOVE, tRet.MODIFY = {}, {}, {}

    for _, szType in ipairs(X.MY_TM_TYPE_LIST) do
        tOld[szType] = tOld[szType] or {}
        tNew[szType] = tNew[szType] or {}
        tData[szType] = tData[szType] or {}
        tRet.ADD[szType] = tRet.ADD[szType] or {}
        tRet.REMOVE[szType] = tRet.REMOVE[szType] or {}
        tRet.MODIFY[szType] = tRet.MODIFY[szType] or {}
        for k, v in pairs(tOld[szType]) do -- k地图组,v项目数据数组
            tNew[szType][k] = tNew[szType][k] or {}
            for kk, vv in ipairs(v) do -- kk项目下标,vv项目数据
                local idx = CheckSameData(tNew, szType, k, vv.dwID or vv.szContent, vv.nLevel or vv.szTarget)
                if idx then -- 新表存在相似数据，比较差异
                    if not deepEqual(vv, tNew[szType][k][idx]) then -- 数据不同，记录差异
                        tData[szType][k] = tData[szType][k] or {}
                        tRet.MODIFY[szType][k] = tRet.MODIFY[szType][k] or {}
                        table.insert(tRet.MODIFY[szType][k], tNew[szType][k][idx])
                        local tDiff = X.clone(tNew[szType][k][idx])
                        if tDiff.LH then
                            tDiff.LH.szChanged = 'MODIFY'
                        else
                            tDiff.LH = LH_MODIFY
                        end
                        table.insert(tData[szType][k], tDiff)
                    end
                else -- 新表不存在相似数据，被删除
                    tData[szType][k] = tData[szType][k] or {}
                    tRet.REMOVE[szType][k] = tRet.REMOVE[szType][k] or {}
                    table.insert(tRet.REMOVE[szType][k], vv)
                    local tDiff = X.clone(vv)
                    if tDiff.LH then
                        tDiff.LH.szChanged = 'REMOVE'
                    else
                        tDiff.LH = LH_REMOVE
                    end
                    table.insert(tData[szType][k], tDiff)
                end
            end
        end
        for k, v in pairs(tNew[szType]) do
            tNew[szType][k] = tNew[szType][k] or {}
            for kk, vv in ipairs(v) do -- kk项目下标,vv项目数据
                local idx = CheckSameData(tOld, szType, k, vv.dwID or vv.szContent, vv.nLevel or vv.szTarget)
                if not idx then -- 旧表不存在相似数据，被新增
                    tData[szType][k] = tData[szType][k] or {}
                    tRet.ADD[szType][k] = tRet.ADD[szType][k] or {}
                    table.insert(tRet.ADD[szType][k], vv)
                    local tDiff = X.clone(vv)
                    if tDiff.LH then
                        tDiff.LH.szChanged = 'ADD'
                    else
                        tDiff.LH = LH_ADD
                    end
                    table.insert(tData[szType][k], tDiff)
                end
            end
        end
    end
    tData = clearNil(clearNil(tData))
    tRet = clearNil(clearNil(tRet))

    if X.emptyTable(tData) then
        tData = nil
    end
    if X.emptyTable(tRet) then
        tRet = nil
    end
    return tData, tRet
end

-- dllcall调用处理文件，对比版本差异
function processFilediff(szNewFileName, szOldFileName, szSaveDiffFileName)
    -- print('Sorting: ' .. szFileName)
    local tData = X.file2var(szNewFileName)
    if tData then
        clearInvalidtable(tData, true)
    end
    local tOldData = X.file2var(szOldFileName)
    -- 旧文件不清除也可以，因为旧文件是历史数据，上次提交都清过一次，但为了安心，还是清除一次
    if tOldData then
        clearInvalidtable(tOldData, true)
    end

    local tDiffmark, tDiff = DBMdiff(tOldData, tData)

    if tDiffmark or tDiff then
        X.WriteFile(
            szSaveDiffFileName,
            'return ' .. X.var2str(tDiffmark, '\t', 0, 3)
                .. ',' .. X.var2str(tDiff, '\t', 0, 4)
                .. '\n'
        )
    end
    if not tData then -- 新表为空，说明该文件被删除，删除记录差异，记录完后返回false
        return false
    end

    X.refreshTimeStamp(tData)
    local szSorted = 'return ' .. X.var2str(tData, '\t', 0, 3) .. '\n'
    X.WriteFile(szNewFileName, szSorted)
    return true
end

-- PY调用处理文件（有序化Table转String）
function processFile(szFileName)
    -- print('Sorting: ' .. szFileName)
    local tData = X.file2var(szFileName)
    if not tData then
        return false
    end
    clearInvalidtable(tData, true)
    X.refreshTimeStamp(tData)
    local szSorted = 'return ' .. X.var2str(tData, '\t', 0, 3) .. '\n'
    X.WriteFile(szFileName, szSorted)
    return true
end

if select('#', ...) == 0 then
    return
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

-- os.exit(success and 0 or 1)
