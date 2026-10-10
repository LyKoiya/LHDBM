
package.path = package.path .. ';.\\!src-dist\\scripts\\?.lua'
local X = require('Base')
local buffRules = X.file2var('.\\!src-dist\\data\\buffRules.jx3dat')
local FILE = {}
local teamBuff = {}
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
		FILE[szType] = FILE[szType] or {}
		k, v = CheckSameData(FILE, szType, MapID, tData.dwID, tData.nLevel)

		if k then
			FILE[szType][MapID][k] = tData
		else
			FILE[szType][MapID] = FILE[szType][MapID] or {}
			table.insert(FILE[szType][MapID], tData)
		end
	end
end

-- 解析团队面板规则
function EncodeBuffRule(v, bNoBasic)
	local a = {}
	if not bNoBasic then
		table.insert(a, v.dwID or v.szName)
		if v.nLevel then
			table.insert(a, 'lv' .. v.nLevel)
		end
	end
	if v.nStackNum then
		table.insert(a, 'sn' .. (v.szStackOp or '>=') .. v.nStackNum)
	end
	if v.bOnlyMe then
		table.insert(a, 'me')
	end
	if v.bOnlyMine or v.bOnlySelf or v.bSelf then
		table.insert(a, 'mine')
	end
	a = { table.concat(a, '|') }

	if v.col then
		local cols = { v.col }
		if v.nColAlpha and v.col:sub(1, 1) ~= '#' then
			table.insert(cols, v.nColAlpha)
		end
		table.insert(a, '[' .. table.concat(cols, '|') .. ']')
	end
	if not X.IsEmpty(v.szReminder) then
		table.insert(a, '(' .. v.szReminder .. ')')
	end
	if v.nPriority then
		table.insert(a, '#' .. v.nPriority)
	end
	if v.bAttention then
		table.insert(a, '!!')
	end
	if v.bCaution then
		table.insert(a, '!!!')
	end
	if v.bScreenHead then
		if v.colScreenHead then
			table.insert(a, '!!!!|[' .. v.colScreenHead .. ']')
		else
			table.insert(a, '!!!!')
		end
	end
	if v.bDelete then
		table.insert(a, '-')
	end
	return table.concat(a, ',')
end

-- 团队面板txt解析一行数据
local function DecodeBuffRule(line)
	line = X.TrimString(line)
	if line ~= '' then
		local tab = {}
		local vals = X.split(line, ',')
		for i, val in ipairs(vals) do
			if i == 1 then
				local vs = X.split(val, '|')
				for j, v in ipairs(vs) do
					v = X.TrimString(v)
					if v ~= '' then
						if j == 1 then
							tab.dwID = tonumber(v)
							if not tab.dwID then
								tab.szName = v
							end
						elseif v == 'self' or v == 'mine' then
							tab.bOnlyMine = true
						elseif v:sub(1, 2) == 'lv' then
							tab.nLevel = tonumber((v:sub(3)))
						elseif v:sub(1, 2) == 'sn' then
							if tonumber(v:sub(4, 4)) then
								tab.szStackOp = v:sub(3, 3)
								tab.nStackNum = tonumber((v:sub(4)))
							else
								tab.szStackOp = v:sub(3, 4)
								tab.nStackNum = tonumber((v:sub(5)))
							end
						end
					end
				end
			elseif val == '!!' then
				tab.bAttention = true
			elseif val == '!!!' then
				tab.bCaution = true
			elseif val == '!!!!' or val:sub(1, 5) == '!!!!|' then
				tab.bScreenHead = true
				local vs = X.split(val, '|')
				for _, v in ipairs(vs) do
					if v:sub(1, 1) == '[' and v:sub(-1, -1) == ']' then
						tab.colScreenHead = v:sub(2, -2)
					end
				end
			elseif val == '-' then
				tab.bDelete = true
			elseif val:sub(1, 1) == '#' then
				tab.nPriority = tonumber((val:sub(2)))
			elseif val:sub(1, 1) == '[' and val:sub(-1, -1) == ']' then
				val = val:sub(2, -2)
				if val:sub(1, 1) == '#' then
					tab.col = val
				else
					local vs = X.split(val, '|')
					tab.col = vs[1]
					tab.nColAlpha = vs[2] and tonumber(vs[2])
				end
			elseif val:sub(1, 1) == '(' and val:sub(-1, -1) == ')' then
				tab.szReminder = val:sub(2, -2)
			end
		end
		if tab.dwID or tab.szName then
			return tab
		end
	end
end

-- 团队气劲面板文档转传入DBM
function teamBufftxt2DBM(szFilePath)
	FILE.Cataclysm = FILE.Cataclysm or {}
	local str =  X.ReadFile(szFilePath)
	if str then
		for k, v in ipairs(X.split(str, '\n')) do
			local tData = DecodeBuffRule(v)
			if tData then
				local key = tData.dwID or tData.szName
				FILE.Cataclysm[key] = tData
			end
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
					tData[1].bOnlySelfSrc = true
				else
					tData[1].bOnlySelfSrc = false
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

-- 团队气劲转文本文档
local function teamBuff2str(aLine)

	local aTeamBuff = {}
	local tTeamBuff = {}
	if aLine[3] ~= '' then
		local szTitle = string.sub(aLine[3],1,2)
		
		if szTitle == '==' or szTitle == '——' then
			table.insert(teamBuff, aLine[3] .. '\n')
			return aLine[3]
		else
			tTeamBuff.szName = aLine[3]
		end
	end
	if aLine[2] ~= '' then
		tTeamBuff.dwID = X.tonumberStr(aLine[2])
	end

	if aLine[4]:sub(1, 2) == 'lv' then
		tTeamBuff.nLevel = aLine[4]
	end
	
	if aLine[5]:sub(1, 2) == 'sn' then
		tTeamBuff.nCount = aLine[5]
	end
	if aLine[6] == 'mine' then
		tTeamBuff.bOnlyMine = aLine[6]
	end

	if aLine[7] == 'me' then
		tTeamBuff.bOnlyMe = aLine[7]
	end
	if aLine[8] ~= '' then
		tTeamBuff.szReminder = aLine[8]
	end
	if aLine[9] ~= '' then
		tTeamBuff.nPriority = X.tonumberStr(aLine[9])
	end
	if aLine[10] == '!!' then
		tTeamBuff.bAttention = true
	end
	if aLine[11] == '!!!' then
		tTeamBuff.bCaution = true
	end
	if aLine[12] == '!!!!' then
		tTeamBuff.bScreenHead = true
	end
	if aLine[13]:sub(1, 2) == '[#' then
		tTeamBuff.col = aLine[13]
	end
	if aLine[14]:sub(1, 2) == '[#'  then
		tTeamBuff.colScreenHead = aLine[14]
	end
	if aLine[18] == '-'  then
		tTeamBuff.bDelete = true
	end

	if tTeamBuff.dwID or tTeamBuff.szName then
		
		table.insert(aTeamBuff, tTeamBuff.dwID or tTeamBuff.szName)
		if tTeamBuff.nLevel then
			table.insert(aTeamBuff,'|' .. tTeamBuff.nLevel)
		end
		if tTeamBuff.nCount then
			table.insert(aTeamBuff,'|' .. tTeamBuff.nCount)
		end
		if tTeamBuff.bOnlyMe then
			table.insert(aTeamBuff,'|' .. tTeamBuff.bOnlyMe)
		end
		if tTeamBuff.bOnlyMine then
			table.insert(aTeamBuff,'|' .. tTeamBuff.bOnlyMine)
		end
		if tTeamBuff.col then
			table.insert(aTeamBuff,',' .. tTeamBuff.col)
		end
		if tTeamBuff.szReminder then
			table.insert(aTeamBuff,',('.. tTeamBuff.szReminder .. ')')
		end
		if tTeamBuff.nPriority then
			table.insert(aTeamBuff,',#' .. tTeamBuff.nPriority)
		end
		if tTeamBuff.bAttention then
			table.insert(aTeamBuff,',!!')
		end
		if tTeamBuff.bCaution then
			table.insert(aTeamBuff,',!!!')
		end
		if tTeamBuff.bScreenHead then
			table.insert(aTeamBuff,',!!!!')
		end
		if tTeamBuff.colScreenHead then
			table.insert(aTeamBuff,'|' .. tTeamBuff.colScreenHead)
		end
		if tTeamBuff.bDelete then
			table.insert(aTeamBuff,',-')
		end
		local str = table.concat(aTeamBuff)
		table.insert(teamBuff, str .. '\n')
		return str
	end

	-- 122|lv2|sn>=2|me|mine,[#DF7F3FC1],(备注),#99,!!,!!!,!!!!|[#DFFF1F],-
end
-- 解析一行团队气劲面板数据并转为团队监控数据
function decodeBuff(szLine)
	if not szLine then
		return
	end
	local aline = X.split(szLine, '\t')
	if not aline then
		return
	end
	if #aline < 18 or aline[18] == '-' or aline[2] == '' or (tonumber(aline[2]) or 0) <= 0 then
		teamBuff2str(aline)
		return
	end
	teamBuff2str(aline)
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

	if aline[13]:sub(1, 2) == '[#' then
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
	if aline[14]:sub(1, 2) == '[#' and tData[1].bScreenHead then -- 处理头顶颜色，头顶警报开启再提取颜色
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
	if aline[5]:sub(1, 2) == 'sn' then
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
function fileSave(szSavePath, nMaxLevel, bClear, bReverse)
	if bClear then
		clearInvalidData(FILE, true, true, true)
	end
	if bReverse then
		tableReverse(FILE)
	end
	X.refreshTimeStamp(FILE)
	local str = 'return ' .. X.var2str(FILE, '\t', 0, nMaxLevel or 3)
	X.WriteFile(szSavePath, str)
	return str
end

-- 清除FILE表
function fileClear()
	FILE = {}
end

-- 保存teamBuff为txt
function teamBuffSave(szSavePath)
	local str = table.concat(teamBuff)
	X.WriteFile(szSavePath, str)
end

-- 清除teamBuff
function teamBuffClear()
	teamBuff = {}
end
print("PackDBM initialized")
