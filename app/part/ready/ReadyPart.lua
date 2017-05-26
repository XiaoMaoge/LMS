-- local BasePart = require("packages.mvc.BasePart")
local CURRENT_MODULE_NAME = ...
local ReadyPart = class("ReadyPart",cc.load('mvc').PartBase) --登录模块
ReadyPart.DEFAULT_PART = {
	"ChatPart",
	'BroadcastPart',--加入小喇叭节点
}
ReadyPart.DEFAULT_VIEW = "ReadyLayer"
--[
-- @brief 构造函数
--]
cc.exports.globalTotalHand = 0      -- 总圈数

function ReadyPart:ctor(owner)
    ReadyPart.super.ctor(self, owner)

    self.iCurrentPlayerNum = 0          -- 当前在局已加入的人数

    self:initialize()

end

--[
-- @override
--]
function ReadyPart:initialize()
	self.player_list = {}
	self.m_pos = -1
	self.vip_table_id = -1      -- 房间ID
    self.iTotalPlayerNum = 0    -- 该局游戏总人数
end

--[[激活模块
	playerList = { --玩家列表
		[1] = {
			seat_id = 1,
			name = "test",
			sex = 1,
			img_rul = "",
			coin = 1000,
		},
		[2] = {
			seat_id = 2,
			name = "test1",
			sex = 0,
			img_rul = "",
			coin  = 1000
		}
	}
--]]
function ReadyPart:activate(data)
	ReadyPart.super.activate(self, CURRENT_MODULE_NAME)
	local chat_part = self:getPart("ChatPart")
	if chat_part then
		local pos_table = self.view:getPosTable()
		chat_part:activate(pos_table)
	end

	local broadcast_node = self:getPart("BroadcastPart")
    if broadcast_node then
    	print("broadcast_node1")
    	broadcast_node:activate(self.view.node.broadcast_node)
    	broadcast_node:isShowBroadcastNode(false)
    end
    print("broadcast_node2")
	--print(data);

	if data ~= nil then
		self.m_pos = data.tableinfo.tablepos 		
		--加入界面坐标
		self.player_list = {}
		for k,v in ipairs(data.tableinfo.players) do
			self.player_list[k] = self:decodePlayerInfo(v)
			if v.tablepos then
				self.player_list[k].view_id = self:changeSeatToView(v.tablepos)
			end
			print(k,v)
		end
		self.owner:updatePlayer(clone(self.player_list))
		self.view:initPlayer(self.player_list)
		if data.tableinfo.viptableid > 0 then
			self.vip_table_id = data.tableinfo.viptableid
            -- data.tableinfo.tablepos
            -- self.iTotalPlayerNum = table.maxn(data.tableinfo.players)

			self.view:showVipInfo()
			self.view:setTableID(data.tableinfo.viptableid)
			self.m_totalhand = data.tableinfo.totalhand         -- 多少局
            globalTotalHand = data.tableinfo.totalhand
            self.iCurrentPlayerNum = table.maxn(data.tableinfo.players)     -- 当前已经有的人数
		end
		if RoomConfig.Ai_Debug then
			local ai_mod = global:getModuleWithId(ModuleDef.AI_MOD)
			ai_mod:init(self,self.owner:getPart("CardPart"),self.owner)
			local user = global:getGameUser()
			local prop = user:getProps()
			local my_info = {
				name = prop.name,
				sex = 0,
				img_rul = prop.photo,
				uid = prop.uid
			}
			ai_mod:addPlayer(my_info)
		end
		if data.currenthand and data.currenthand >= 1 then
			self.view.hideInviteBtn();
		end
	end
end

function ReadyPart:getRoomID()
    return self.vip_table_id
end

function ReadyPart:deactivate()
	local chatPart = self:getPart("ChatPart")
	if chatPart then
		chatPart:deactivate()
	end

	if self.view then
		self.view:removeSelf()
		self.view =  nil
	end
end

function ReadyPart:getPartId()
	-- body
	return "ReadyPart"
end

function ReadyPart:decodePlayerInfo(playerInfo)
	-- body
	local player = {}
	player.uid = playerInfo.uid
	player.name = playerInfo.name
	player.headImgUrl = playerInfo.headImgUrl
	player.targetPlayerName = playerInfo.targetPlayerName
	player.sex = playerInfo.sex
	player.coin = playerInfo.coin or playerInfo.gold
--	player.coin = playerInfo.coin
--	player.gold = playerInfo.gold
	player.tablepos = playerInfo.tablepos
	player.desc = playerInfo.desc
	player.fan = playerInfo.fan
	player.gameresult = playerInfo.gameresult
	player.canfrind = playerInfo.canfrind
	player.intable= playerInfo.intable
	player.vipoverdata = playerInfo.vipoverdata
	player.ip = playerInfo.ip
	player.gamestate = playerInfo.gamestate
	player.playerIndex = playerInfo.playerIndex
	return player
end

--将逻辑座位转换为界面座位
function ReadyPart:changeSeatToView(seatId) --座位顺时针方向增加 1 - 4
	-- body
	if self.m_pos then
		return (seatId - self.m_pos + 4)%4 + 1
	end
end

function ReadyPart:loadHeadImg(url,node)
	-- body
	local lua_bridge = global:getModuleWithId(ModuleDef.BRIDGE_MOD)
	lua_bridge:startDownloadImg(url,node)
end

function ReadyPart:offlinePlayer(pos,online)
	-- body
	if self.view then
		self.view:offlinePlayer(pos,online)
	end
end

--隐藏准备界面
function ReadyPart:hideView()
	-- body
	local chatPart = self:getPart("ChatPart")
	if chatPart then
		chatPart:deactivate()
	end
	self.view:hide()
end

--显示准备界面
function ReadyPart:showView()
	-- body
	self.view:show()
end

--[[ 加入新的玩家
	{
		seat_id = 2,
		name = "test1",
		sex = 0,
		img_rul = "",
		coin  = 1000
	}
--]]
function ReadyPart:addPlayer(playerInfo)
	-- body
	if playerInfo and playerInfo.tablepos then
		playerInfo.view_id = self:changeSeatToView(playerInfo.tablepos)
		local exit_player,index = self:getPlayerInfo(playerInfo.view_id)
		if exit_player == nil then --防止断线重连重复添加
			table.insert(self.player_list,playerInfo)
		else
			self.player_list[index] = playerInfo
		end
		self.owner:updatePlayer(clone(self.player_list))
	end
	self.view:showPlayer(playerInfo)
end

function ReadyPart:getPlayerInfo(viewId)
	-- body
	for i,v in ipairs(self.player_list) do
		if v.view_id == viewId then
			return v,i
		end
	end
	return nil
end

function ReadyPart:startGame(data)
	-- body
	self.owner:startGame(data)
	self:deactivate()
	self.player_list = {}
end

if RoomConfig.Ai_Debug then
ReadyPart.debug_index = 1
function ReadyPart:getDebugPlayer()
	-- body
	self.debug_index = self.debug_index + 1
	return {
		uid = self.debug_index,
		name = "test" .. self.debug_index,
		sex = 0,
		img_rul = "http://wx.qlogo.cn/mmopen/Vt3en7SeZMnc4t2XACP0I2v0SAoHDlDsqtUsrgsy5yIv6icUzwR1Xm2Tesib2U4iaVlLXaOazo8EsrF8xSJF8GEM1xmURV9AMNe/0",
		coin = 1000
	}
end
end

function ReadyPart:inviteFriends()
	-- body
	print("tablewating_inviteFriends1")
	if RoomConfig.Ai_Debug then
		local player_info = self:getDebugPlayer()
		local ai_mod = global:getModuleWithId(ModuleDef.AI_MOD)
		ai_mod:addPlayer(player_info)
	else
		print("tablewating_inviteFriends2",string_table.game_name[tonumber(SocketConfig.GAME_ID)],SocketConfig.GAME_ID)
		local title = string_table.game_title_yi_chang
		local bridge = global:getModuleWithId(ModuleDef.BRIDGE_MOD)
		--string_table.vip_table_invite_wechat="房号：%d，%d局，%s速度来战"
		
		if self.m_totalhand == nil or self.m_totalhand == 0 then
			self.m_totalhand = 4
		end

--      local tmpStr1 = string_table.vip_table_invite_wechat
--		if string_table.game_name[tonumber(SocketConfig.GAME_ID)] then
--			tmpStr1 = string_table.game_name[tonumber(SocketConfig.GAME_ID)] .. "," .. tmpStr1
--		end

--		local shareContent = string.format(tmpStr1,self.vip_table_id,self.m_totalhand,"")
        
        -- 游戏名称
        local strGameName = ""
        if string_table.game_name[tonumber(SocketConfig.GAME_ID)] then
            strGameName = string_table.game_name[tonumber(SocketConfig.GAME_ID)]
        end

        -- local tempStr = "【房号】%d   六六福建麻将，GPS定位让作弊无所遁形《%s》 %d局 %d人场"-- string_table.vip_table_invite_share_word

        local strRule = ""

        if bit._and(globlerule, bit.lshift(1, 19)) ~= 0 then
            if string.len(strRule) > 0 then
                strRule = strRule .. "、AA支付"
            else
                strRule = strRule .. "AA支付"
            end
        else
            if string.len(strRule) > 0 then
                strRule = strRule .. "、房主支付"
            else
                strRule = strRule .. "房主支付"
            end
        end

        if bit._and(globlerule, bit.lshift(1, 0)) ~= 0 then
            if string.len(strRule) > 0 then
                strRule = strRule .. "、无平胡"
            else
                strRule = strRule .. "无平胡"
            end
        end

        if bit._and(globlerule, bit.lshift(1, 1)) ~= 0 then
            if string.len(strRule) > 0 then
                strRule = strRule .. "、点杠包三家"
            else
                strRule = strRule .. "点杠包三家"
            end
        end

        if bit._and(globlerule, bit.lshift(1, 2)) ~= 0 then
            if string.len(strRule) > 0 then
                strRule = strRule .. "、带白板"
            else
                strRule = strRule .. "带白板"
            end
        end 

        local tempStr = "<%s>房号:【%d】,%d局,%s,当前%d缺%d"    -- 游戏名、房号、局数、玩法、当前%d缺%d
        local shareContent = string.format(tempStr, strGameName, self.vip_table_id, self.m_totalhand, strRule, globlePlayersNum, globlePlayersNum - self.iCurrentPlayerNum)

		local shareUrl = string_table.share_weixin_android_url
		--分享内容和分享链接都是从服务器上拉取的
		
		local user = global:getGameUser()
	    local props = user:getProps()
	    local gameConfigList = props["gameplayer" .. SocketConfig.GAME_ID].gameConfigList

	    for i,v in ipairs(gameConfigList) do
	    	local gameParam = gameConfigList[i]
			if device.platform == "android" then
				if gameParam.paraId == ClientParamConfig.WEIXIN_SHARE_URL_ANDROID then
					if gameParam.valueStr then
						shareUrl = gameParam.valueStr --分享链接
					end
				end
			elseif device.platform == "ios" then
				if gameParam.paraId == ClientParamConfig.WEIXIN_SHARE_URL_IOS then
					if gameParam.valueStr then
						shareUrl = gameParam.valueStr --分享链接
					end
				end
			end
		end

		bridge:ShareToWX(1,shareContent,shareUrl)
	end
	-- self:addPlayer(player_info)
end

function ReadyPart:closeRoom()
	-- body
	print("this is close room------------------------------")
	self.owner:closeVipRoom(true)
end

function ReadyPart:exitClick()
	print("this is exit room------------------------------")
	self.owner:exitClick()
end

function ReadyPart:maskClick()
	-- body
	local chat_part = self:getPart("ChatPart")
	if chat_part then
		chat_part:hideSz()
	end
end

function ReadyPart:hideIndex(num)
	-- body
	self.view:hidePlayer(num)
end

function ReadyPart:scrollMsgAck(data,appId)		--跑马灯消息
	-- body
	if tonumber(appId) == tonumber(SocketConfig.GAME_ID) then
		local broadcast_node = self:getPart("BroadcastPart")
	    if broadcast_node then
	    	broadcast_node:isShowBroadcastNode(true)
	    end

		local net_manager = global:getNetManager()
		local scroll_msg = wllobby_message_pb.ScrollMsg()
		scroll_msg:ParseFromString(data)
		print("----scrollMsgAck ReadyPart: ",scroll_msg)
		local msg = scroll_msg.msg
		local loopNum = scroll_msg.loopNum
		local removeAll = scroll_msg.removeAll

		local broadcast_node = self:getPart("BroadcastPart")
		broadcast_node:startBroadcast(msg,loopNum,removeAll,true,appId)
	end
end

return ReadyPart
