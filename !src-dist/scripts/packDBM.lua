
package.path = package.path .. ';.\\!src-dist\\scripts\\?.lua'
local X = require('Base')
local buffRules = X.file2var('.\\!src-dist\\data\\buffRules.jx3dat')
local FILE = {}
for _, szType in ipairs(X.MY_TM_TYPE_LIST) do
	FILE[szType] = {}
end
-- 检查表内相似键
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

-- 合并数据表
local function tableMerge(tData)
	for _, szType in ipairs(X.MY_TM_TYPE_LIST) do
		if tData[szType] then
			FILE[szType] = FILE[szType] or {}
			for k, v in pairs(tData[szType]) do -- 数据类型
				for kk, vv in ipairs(v) do -- 地图ID
					FILE[szType][k] = FILE[szType][k] or {}
					local idx = CheckSameData(FILE, szType, k, vv.dwID or vv.szContent, vv.nLevel or vv.szTarget)
					if idx then
						FILE[szType][k][idx] = vv
					else
						table.insert(FILE[szType][k], vv)
					end
				end
			end
		end
	end
	return FILE
end

-- 删重复数据表（取非重复数据）
local function tableXor(tData)
	for _, szType in ipairs(X.MY_TM_TYPE_LIST) do
		if tData[szType] then
			FILE[szType] = FILE[szType] or {}
			for k, v in pairs(tData[szType]) do -- 地图ID
				for kk, vv in X.ipairs_r(v) do -- 具体数据
					local idx = CheckSameData(FILE, szType, k, vv.dwID or vv.szContent, vv.nLevel or vv.szTarget)
					if idx then
						FILE[szType][k][idx] = nil
					end
				end
			end
		end
	end
	return FILE
end

-- 取重复数据表（删非重复数据）
local function tableAnd(tData)
	for _, szType in ipairs(X.MY_TM_TYPE_LIST) do
		if FILE[szType] then
			tData[szType] = tData[szType] or {}
			for k, v in pairs(FILE[szType]) do -- 地图ID
				for kk, vv in X.ipairs_r(v) do -- 具体数据
					if not CheckSameData(tData, szType, k, vv.dwID or vv.szContent, vv.nLevel or vv.szTarget) then
						FILE[szType][k][kk] = nil
					end
				end
			end
		end
	end
	return FILE
end

-- 合并表文件
function fileMerge(szFile)
	local tData, err = X.file2var(szFile)
	if tData then
		tableMerge(tData)
	else
		print('fileMerge fail:' .. szFile .. err)
	end
end

-- 合并表字符串
function strMerge(szStr)
	local tData = X.str2var(szStr)
	if tData then
		tableMerge(tData)
	end
end

-- 合并一条原始数据
---@param tData  table?
---@param szType string
---@param MapID  int | number
local function dataMerge(tData, szType, MapID)
	local k, v
	if tData then
		k, v = CheckSameData(FILE, szType, MapID, tData.dwID, tData.nLevel)

		if k then
			FILE[szType][MapID][k] = tData
		else
			FILE[szType][MapID] = FILE[szType][MapID] or {}
			table.insert(FILE[szType][MapID], tData)
		end
	end
end

-- 清理不必要的团队气劲面板，用于秘境地图阻断通用数据，可实现秘境地图关闭头顶染色
local function cleanCataclysmBuff(tData)
	local retData = X.clone(tData)
	retData.nCount = nil
	if retData[1] then
		retData[1].bScreenHead = nil
	end
	if retData.aCataclysmBuff then
		for k, v in X.ipairs_r(retData.aCataclysmBuff) do
			if k == 1 and v then
				v.szStackOp = nil
				v.nStackNum = nil
				v.bScreenHead = nil
			else
				table.remove(retData.aCataclysmBuff, k)
			end
		end
		--[[
		for k = #retData.aCataclysmBuff, 2, -1 do
			table.remove(retData.aCataclysmBuff, k)
		end
		]]--
	end
	return retData
end

local function buffRuleCMD(tData, szRule, tCmd)
	local aRule = X.split(szRule, '/')
	for _, Rule in ipairs(aRule) do
		local k = X.strLeft(Rule, ' ')
		local v = X.strDelBothEnd(X.strRight(Rule, ' '), ' ')
		if k then
			if k == 'MapID' then
				tCmd.aMapID = X.str2var('{' .. v .. '}') or {}
			elseif k == 'szName' then
				tData.szName = v
			elseif k == 'nIcon' then
				tData.nIcon = tonumber(v)
			elseif k == 'nLevel' then
				tData.nLevel = tonumber(v)
			elseif k == 'nCount' then
				tData.nCount = tonumber(v)
			elseif k == 'nScrutinyType' then
				tData.nScrutinyType = tonumber(v)
			elseif k == 'disableTeamPanel' then
				tData.aCataclysmBuff = nil
				tData[1].bTeamPanel = false
				tData[1].bOnlySelfSrc = false
			elseif k == 'bCenterAlarm1' then
				tData[1].bCenterAlarm = true
			elseif k == 'bCenterAlarm2' then
				tData[2].bCenterAlarm = true
			elseif k == 'bPartyBuffList1' then
				tData[1].bPartyBuffList = true
			elseif k == 'bBuffList1' then
				tData[1].bBuffList = true
			elseif k == 'szVoice1' then
				tData[1].szVoice = v
			elseif k == 'szVoice2' then
				tData[2].szVoice = v
			elseif k == 'bVoiceSelfOnly1' then
				tData[1].bVoiceSelfOnly = true
			elseif k == 'bVoiceSelfOnly2' then
				tData[2].bVoiceSelfOnly = true
			elseif k == 'bTeamChannel1' then
				tData[1].bTeamChannel = true
			elseif k == 'bTeamChannel2' then
				tData[2].bTeamChannel = true
			elseif k == 'bWhisperChannel1' then
				tData[1].bWhisperChannel = true
			elseif k == 'bWhisperChannel2' then
				tData[2].bWhisperChannel = true
			elseif k == 'bTeamPanel' then
				tData[1].bTeamPanel = true
				if tonumber(v) >= 1 then
					tData[1].bTeamPanel = true
				else
					tData[1].bTeamPanel = false
				end
			elseif k == 'bFullScreen' then
				tData[1].bFullScreen = true
			elseif k == 'col' then
				local aCol = X.str2var('{' .. v .. '}')
				if #aCol >= 3 then
					tData.col = aCol
				end
			elseif k == 'tKungFu' then
				local aKungFu = X.str2var('{' .. v .. '}')
				tData.tKungFu = aKungFu
			elseif k == 'tMark' then
				local aMark = X.str2var('{' .. v .. '}')
				if #aMark >= 1 then
					tData.tMark = aMark
				end
			elseif k == 'reservedEx' then
				local tReservedEx = X.str2var('{' .. v .. '}')
				for kk, vv in pairs(tReservedEx) do
					tData[kk] = vv
				end
			elseif k == 'shield' then
				tCmd.shield = true -- 指定气劲在秘境地图不开启头顶染色，该指令只在气劲开启头顶警报功能且生效地图包含id为-1通用地图时有效
			elseif k == 'Reshield' then
				tCmd.Reshield = true -- 若该气劲在秘境地图屏蔽了头顶警报功能，则取消屏蔽，在秘境地图仍允许头顶染色
			end
		end
	end
	return tCmd
end
local function buffRule(tData, szRule, bCanCancel)
	tData[1] = tData[1] or {}
	tData[2] = tData[2] or {}
	local tCmd = {}
	if buffRules[tData.dwID] then
		buffRuleCMD(tData, buffRules[tData.dwID], tCmd)
	end
	buffRuleCMD(tData, szRule, tCmd)

	for _, v in pairs(tCmd.aMapID) do
		dataMerge(tData, bCanCancel and 'BUFF' or 'DEBUFF', tonumber(v))
		if v == -1 and tData[1].bScreenHead then -- 通用地图且开启头顶警报，需要考虑秘境地图屏蔽头顶染色
			if bCanCancel then
				-- 有利气劲，默认屏蔽, 但是Reshield强制不屏蔽
				if not tCmd.Reshield then
					dataMerge(cleanCataclysmBuff(tData), 'BUFF', -3)
				end
			else
				-- 不利气劲，默认不屏蔽，但是shield强制屏蔽
				if tCmd.shield then
					dataMerge(cleanCataclysmBuff(tData), 'DEBUFF', -3)
				end
			end
		end
	end
end

-- 解析一行团队气劲面板数据并转为团队监控数据
function decodeBuff(line)
	if not line then
		return
	end
	local aline = X.split(line, '\t')
	if not aline then
		return
	end
	if #aline < 18 or aline[18] == '-' or aline[2] == '' or (tonumber(aline[2]) or 0) <= 0 then
		return
	end

	local tData = {}
	tData[1] = {}
	tData[2] = {}
	tData.aCataclysmBuff = {}
	tData.aCataclysmBuff[1] = {}
	tData[1].bTeamPanel = true
	tData.dwID = tonumber(aline[2])
	tData.szNote = tostring(aline[3])
	if aline[4]:sub(1, 2) == 'lv' then
		tData.nLevel = tonumber(aline[4]:sub(3))
		tData.bCheckLevel = true
	else
		tData.nLevel = 1
	end
	if aline[6] == 'mine' then
		tData.aCataclysmBuff[1].bOnlyMine = true
		tData[1].bOnlySelfSrc = true
	end
	if aline[7] == 'me' then
		tData.aCataclysmBuff[1].bOnlyMe = true
		tData.nScrutinyType = 1
	end
	if aline[8] ~= '' then
		tData.aCataclysmBuff[1].szReminder = X.strLeft(aline[8], ' ') or aline[8]:sub(1, 2)
	end
	if aline[9] ~= '' and tonumber(aline[9]) >= 0 then
		tData.aCataclysmBuff[1].nPriority = tonumber(aline[9])
	end
	if aline[10] == '!!' then
		tData.aCataclysmBuff[1].bAttention = true
	end
	if aline[11] == '!!!' then
		tData.aCataclysmBuff[1].bCaution = true
	end
	if aline[12] == '!!!!' then
		tData.aCataclysmBuff[1].bScreenHead = true
		tData[1].bScreenHead = true
	end

	if aline[13] ~= '' then
		tData.aCataclysmBuff[1].col = X.strMid(aline[13], '[', ']') or ''
		if tData.aCataclysmBuff[1].col:len() == 7 then
			tData.aCataclysmBuff[1].col = tData.aCataclysmBuff[1].col .. 'FF'
		end
		if tData.aCataclysmBuff[1].col:len() >= 9 then
			tData.col = tData.col or {}
			tData.col[1] = tonumber(tData.aCataclysmBuff[1].col:sub(2, 3), 16)
			tData.col[2] = tonumber(tData.aCataclysmBuff[1].col:sub(4, 5), 16)
			tData.col[3] = tonumber(tData.aCataclysmBuff[1].col:sub(6, 7), 16)
			tData.aCataclysmBuff[1].nColAlpha = tonumber(tData.aCataclysmBuff[1].col:sub(8, 9), 16)
		end
	end
	if aline[14] ~= '' and tData[1].bScreenHead then -- 处理头顶颜色，头顶警报开启再提取颜色
		tData.aCataclysmBuff[1].colScreenHead = X.strMid(aline[14], '[', ']') or ''
		-- 如果存在头顶染色颜色，覆盖气劲通用颜色
		if tData.aCataclysmBuff[1].colScreenHead:len() >= 7 then
			tData.col = tData.col or {}
			tData.col[1] = tonumber(tData.aCataclysmBuff[1].colScreenHead:sub(2, 3), 16)
			tData.col[2] = tonumber(tData.aCataclysmBuff[1].colScreenHead:sub(4, 5), 16)
			tData.col[3] = tonumber(tData.aCataclysmBuff[1].colScreenHead:sub(6, 7), 16)
		end
	end
	-- 处理团队气劲面板数据
	if aline[5] ~= '' and aline[5]:sub(1, 2) == 'sn' then
		local szStackOp 
		local nStackNum
		if tonumber(aline[5]:sub(4, 4)) then
			szStackOp = aline[5]:sub(3, 3)
			nStackNum = tonumber((aline[5]:sub(4)))
		else
			szStackOp = aline[5]:sub(3, 4)
			nStackNum = tonumber((aline[5]:sub(5)))
		end
		tData.aCataclysmBuff[1].szStackOp = szStackOp
		tData.aCataclysmBuff[1].nStackNum = nStackNum
		if szStackOp == '>=' then
			tData.nCount = nStackNum
			if nStackNum > 1 and (tData.aCataclysmBuff[1].bScreenHead or tData.aCataclysmBuff[1].bAttention or tData.aCataclysmBuff[1].bCaution) then
				tData.aCataclysmBuff[2] = X.clone(tData.aCataclysmBuff[1])
				tData.aCataclysmBuff[2].szStackOp = '>='
				tData.aCataclysmBuff[2].nStackNum = 1
				tData.aCataclysmBuff[2].nPriority = tData.aCataclysmBuff[2].nPriority and (tData.aCataclysmBuff[2].nPriority + 1) or nil
				tData.aCataclysmBuff[2].bScreenHead = nil
				tData.aCataclysmBuff[2].bAttention = nil
				tData.aCataclysmBuff[2].bCaution = nil
				tData.aCataclysmBuff[2].colScreenHead = nil
			end
		elseif szStackOp == '>' then
			tData.nCount = nStackNum and (nStackNum + 1) or nil
			if tData.aCataclysmBuff[1].bScreenHead or tData.aCataclysmBuff[1].bAttention or tData.aCataclysmBuff[1].bCaution then
				tData.aCataclysmBuff[2] = X.clone(tData.aCataclysmBuff[1])
				tData.aCataclysmBuff[2].szStackOp = '>='
				tData.aCataclysmBuff[2].nStackNum = 1
				tData.aCataclysmBuff[2].nPriority = tData.aCataclysmBuff[2].nPriority and (tData.aCataclysmBuff[2].nPriority + 1) or nil
				tData.aCataclysmBuff[2].bScreenHead = nil
				tData.aCataclysmBuff[2].bAttention = nil
				tData.aCataclysmBuff[2].bCaution = nil
				tData.aCataclysmBuff[2].colScreenHead = nil
			end
		end
	end
	buffRule(tData, aline[17], string.lower(aline[15]) == 'true')
end
-- 2	631	握针			mine		握 奶花技能握针hot	6				[#00EE00]		TRUE		/MapID -1 /nScrutinyType 2

--[[decodeBuff(
	'1688	31374	傀儡在场标记（未附身）				me	主 傀儡在场标记（未附身）	11				[#FFFF00]		FALSE		/MapID -1 /szName 伶影 /nIcon 24866 /nScrutinyType 1 /bBuffList1 /tKungFu ["SKILL#10821"]=true, /disableTeamPanel'
)
]]--

-- 递归清除为空数据
local function clearNil(tData)
	for k, v in pairs(tData) do -- 遍历数据判断是否有空表
		if X.emptyTable(v) then
			tData[k] = nil
		elseif not v then
			tData[k] = nil
		elseif v == '' then
			tData[k] = nil
		elseif type(v) == 'table' and k ~= 'tMark' and k ~= 'aFocus' and k ~= 'aCataclysmBuff' then
			tData[k] = clearNil(v)
		end
	end
	return X.emptyTable(tData) and nil or tData
end

-- 打包前清除无效数据，极致缩减体积
local function clearInvalidData(tData, bDelNote, bDelFocus, bDelCataclysmBuff)
	for _, szType in ipairs(X.MY_TM_TYPE_LIST) do
		if tData[szType] then
			tData[szType][-9] = nil -- 清除回收站数据
			for k, _ in pairs(tData[szType]) do -- 遍历类型获取地图ID
				if X.emptyTable(tData[szType][k]) then
					tData[szType][k] = nil -- 当前地图无数据则清除
				end
				for kk, vv in X.ipairs_r(tData[szType][k]) do -- 遍历地图获取数据下标
					if bDelNote then -- 删除备注
						if szType == 'TALK' then -- 若无中央警报和头顶警报，szNote无效，可删除
							if vv[14] and not vv[14].bCenterAlarm and not vv[14].bScreenHead then
								-- vv.szNote = nil
							end
						elseif szType == 'CHAT' then
							if vv[20] and not vv[20].bCenterAlarm and not vv[20].bScreenHead then
								-- vv.szNote = nil
							end
						else
							vv.szNote = nil
						end
					end
					if vv.tMark then -- 处理动态标记
						local bDelMark = true
						for kkk, vvv in ipairs(vv.tMark) do
							if vvv then
								bDelMark = false
								break
							end
						end
						if bDelMark then
							vv.tMark = nil
						end
					end
					if bDelFocus and vv.aFocus then -- 处理焦点列表
						local aFocus = vv.aFocus
						for kkk, tFocus in ipairs(aFocus) do
							tFocus.tType = nil
							if tFocus.dwMapID == -1 then
								tFocus.dwMapID = nil
							end
							if tFocus.szDisplay == '' then
								tFocus.szDisplay = nil
							end
							if tFocus.nMaxDistance == 0 then
								tFocus.nMaxDistance = nil
							end
							if tFocus.tRelation then
								if tFocus.tRelation.bAll == true then
									tFocus.tRelation = nil
								end
							end
							if tFocus.tLife then
								if tFocus.tLife.bEnable == false then
									tFocus.tLife = nil
								end
							end
						end
						if X.emptyTable(aFocus) then
							vv.aFocus = nil
						end
					end
					if bDelCataclysmBuff and vv.aCataclysmBuff then -- 处理团队气劲面板
						local aCataclysmBuff = vv.aCataclysmBuff
						for kkk, tCataclysmBuff in ipairs(aCataclysmBuff) do
							if not tCataclysmBuff.bScreenHead then-- 头顶染色未开启，头顶染色颜色无意义可清除
								tCataclysmBuff.colScreenHead = nil
							end
							clearNil(tCataclysmBuff)
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
	return tData
end

local function tableReverse(tData)
	for _, szType in ipairs(X.MY_TM_TYPE_LIST) do
		if tData[szType] then
			for k, _ in pairs(tData[szType]) do -- 遍历类型获取地图ID
				X.arrayReverse(tData[szType][k])
			end
		end
	end
	return tData
end
-- 保存FILE表，序列化有序，可缩进
function fileSave(szSavePath, nMaxLevel)
	clearInvalidData(FILE, true, true, true)
	tableReverse(FILE)
	local str = 'return ' .. X.var2str(FILE, '\t', 0, nMaxLevel)
	X.WriteFile(szSavePath, str)
	return str
end

print("PackDBM initialized")
