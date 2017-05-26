-- local BasePart = require("packages.mvc.BasePart")
local CURRENT_MODULE_NAME = ...
local TablePart = class("TablePart",cc.load('mvc').PartBase) --登录模块
require("bit")

TablePart.DEFAULT_PART = {
	'ReadyPart',
	'CardPart',
	"ChatPart",
	"WifiAndNetPart",
	'GameEndPart',
	"TipsPart",
	"SmallUserInfoPart",
	"VipOverPart",
	-- 'BroadcastPart',--加入小喇叭节点
	"DissolvePart",
	"RoomSettingPart",--设置组件（牌局内）
	"GpsPart",
	"GpsTipPart", 
	"RoomRulePart",
}
TablePart.DEFAULT_VIEW = "TableScene"

--[
-- @brief 构造函数
--]
function TablePart:ctor(owner)
    TablePart.super.ctor(self, owner)

    self:initialize()
end

--[
-- @override
--]
function TablePart:initialize()
	
end

--激活模块
function TablePart:activate(data)
	--进入游戏场不需要延时断线
	if IOS_BACK_DELAY == true then
		IOS_BACK_DELAY = false
		local lua_bridge = global:getModuleWithId(ModuleDef.BRIDGE_MOD)
		if lua_bridge.setBackDelayTime then
			lua_bridge:setBackDelayTime(10)
		end
	end
	----------------------------------------------------------------------
	local net_mode = global:getModuleWithId(ModuleDef.NET_MOD)
	net_mode:registerMsgListener(MsgDef.MSG_GAME_OPERATION,handler(self,TablePart.gameOperation))  -- 没有操作 
	net_mode:registerMsgListener(MsgDef.MSG_GAME_VIP_ROOM_CLOSE,handler(self,TablePart.closeVipRoomAck))  --解散房间通知,展示解散房间页面
	net_mode:registerMsgListener(MsgDef.MSG_GAME_OPERATION_ACK,handler(self,TablePart.gameOperationAck)) --添加、移除用户 关闭房间的服务器返回
	net_mode:registerMsgListener(MsgDef.MSG_GAME_UPDATE_PLAYER_PROPERTY,handler(self,TablePart.updatePlayerProperty)) --更新玩家信息 没有操作
	net_mode:registerMsgListener(MsgDef.MSG_PLAYER_OPERATION_NTF,handler(self,TablePart.ntfOperation)) --提醒玩家进行操作
	net_mode:registerMsgListener(MsgDef.MSG_GAME_START,handler(self,TablePart.gameStartNtf)) --牌局开始
	net_mode:registerMsgListener(MsgDef.MSG_PLAYER_OPERATION,handler(self,TablePart.playerOperation))
	net_mode:registerMsgListener(MsgDef.MSG_GAME_OVER_ACK,handler(self,TablePart.gameOverAck))
	net_mode:registerMsgListener(MsgDef.MSG_GAME_OTHERLOGIN_ACK,handler(self,TablePart.otherLogin))
	net_mode:registerMsgListener(SocketConfig.MSG_GAME_SEND_SCROLL_MES,handler(self,TablePart.scrollMsgAck))
	net_mode:registerMsgListener(SocketConfig.MSG_CLOSE_VIP_TABLE_ACK,handler(self,TablePart.closeVipTableAck))
	net_mode:registerMsgListener(SocketConfig.MSG_NOTIFY_SEQ_TO_CLIENT_MSG ,handler(self,TablePart.notifySeqToClienTMsg))

	TablePart.super.activate(self, CURRENT_MODULE_NAME)
	local wifi_and_net = self:getPart("WifiAndNetPart")
    if wifi_and_net then
    	wifi_and_net:activate(self.view.node.wifi_net_node)
    end

--    local broadcast_node = self:getPart("BroadcastPart")
--    if broadcast_node then
--    	broadcast_node:activate(self.view.node.broadcast_node)
--    	broadcast_node:isShowBroadcastNode(false)
--    end

    local ready_part = self:getPart("ReadyPart")

    if ready_part then
    	ready_part:activate(data)
    end

    local dissolve_part = self:getPart("DissolvePart")
	if dissolve_part then
		dissolve_part:activate(data)
	end
    
    self.m_seat_id = data.tableinfo.tablepos
	self.tableid = data.tableinfo.viptableid --判断是不是vip场
	
	local gps_part = self:getPart("GpsPart")
	if gps_part then
		gps_part:activate(self.m_seat_id,self.tableid)
	end

	local gpsTip_part = self:getPart("GpsTipPart")
	if gpsTip_part then
		gpsTip_part:activate()
	end
	
    self.player_list = {}

    local user = global:getGameUser()
   	local game_player = user:getProp("gameplayer"..SocketConfig.GAME_ID)
	self.playerIndex = game_player.playerIndex

    --加入界面坐标
	for k,v in ipairs(data.tableinfo.players) do
		self.player_list[k] = self:decodePlayer(v)

		if v.tablepos then
			self.player_list[k].view_id = self:changeSeatToView(v.tablepos)
		end

		if tonumber(v.playerIndex) == tonumber(self.playerIndex) then
			self.uid = v.uid
		end

		if v.intable == 0 then --离线
			self:offlinePlayer(self.player_list[k].view_id,false)
		end
	end
    self.createid = data.tableinfo.creatorid
    self.tableid = data.tableinfo.viptableid --判断是不是vip场
    self.cur_hand = data.tableinfo.currenthand --当前局数
	print("------------self.tableid : ",self.tableid,self.cur_hand)
    if self.tableid > 1 then					--是否显示解散房间按钮
    	self.view:isShowCloseBtn(true)
    	self.view:showGoldOrVipText(true,self.tableid)
    else 
    	self.view:isShowCloseBtn(false)
    	self.view:showGoldOrVipText(false)
    end

end

function TablePart:turnSeat(viewId,time)
	-- body
	self.view:turnSeat(viewId,time)
end

function TablePart:updatePlayer(playerList)
	-- body
	self.player_list = playerList
end

function TablePart:offlinePlayer(pos,online)
	-- body
	self.view:offlinePlayer(pos,online)
	local ready_part = self:getPart("ReadyPart")

    if ready_part then
    	ready_part:offlinePlayer(pos,online)
    end
end

function TablePart:deactivate()
    local net_mode = global:getModuleWithId(ModuleDef.NET_MOD)
	net_mode:unRegisterMsgListener(MsgDef.MSG_GAME_OPERATION)
	net_mode:unRegisterMsgListener(MsgDef.MSG_GAME_VIP_ROOM_CLOSE)
	net_mode:unRegisterMsgListener(MsgDef.MSG_GAME_OPERATION_ACK)
	net_mode:unRegisterMsgListener(MsgDef.MSG_GAME_UPDATE_PLAYER_PROPERTY)
	net_mode:unRegisterMsgListener(MsgDef.MSG_PLAYER_OPERATION_NTF)
	net_mode:unRegisterMsgListener(MsgDef.MSG_GAME_START)
	net_mode:unRegisterMsgListener(MsgDef.MSG_PLAYER_OPERATION)
	net_mode:unRegisterMsgListener(MsgDef.MSG_GAME_OVER_ACK)
	net_mode:unRegisterMsgListener(MsgDef.MSG_GAME_OTHERLOGIN_ACK)
	--net_mode:unRegisterMsgListener(SocketConfig.MSG_GAME_SEND_SCROLL_MES)
	net_mode:unRegisterMsgListener(SocketConfig.MSG_CLOSE_VIP_TABLE_ACK)
	self.view:removeSelf()
	self.view =  nil
end

function TablePart:getPartId()
	-- body
	return "TablePart"
end

function TablePart:otherLogin(data)
	-- body
	local net_mode = global:getModuleWithId(ModuleDef.NET_MOD)
	net_mode:disconnect()
	local tips_part = global:createPart("TipsPart",self)
	if tips_part then
		tips_part:activate({info_txt=string_table.other_login,left_click = function()
			-- body
			cc.Director:getInstance():endToLua()
		end})
	end
end

function TablePart:startGame(data)
	-- body
	local chat_part = self:getPart("ChatPart")
    if chat_part then
    	local pos_table = self.view:getPosTable()
		chat_part:activate(pos_table)
		chat_part:hideSzBtn()
    end
	-- print("快乐圣诞节法律解释两地分居落地生根啦傻瓜哈萨克的风格很多事是考虑到经费落实到肌肤来说上课了都快放假了圣诞节雷锋精神地方");
	local card_part = self:getPart("CardPart")
    card_part:activate(data)

    if self.tableid > 1 then ----显示当前局数和总局数  1/4局
    	local quanTotal = bit._and(data.serviceGold,0xff)
    	self.view:dispalyQuan(data.quannum,quanTotal)
    end
	--print("66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666");
	self.last_card_num = 0
	self.m_seat_id = data.mtablePos
	self.view:initTableWithData(self.player_list,data)
end

function TablePart:getPlayerInfo(viewId)
	-- body
	for i,v in ipairs(self.player_list) do
		if v.view_id == viewId then
			return v
		end
	end
	return nil
end

function TablePart:getCard()
	-- body
	self.last_card_num = self.last_card_num - 1
	self:updateLastCardNum(self.last_card_num)
end

function TablePart:updateLastCardNum(num)
	-- body
	self.view:updateLastCardNum(num)
end

function TablePart:loadHeadImg(url,node)
	-- body
	local lua_bridge = global:getModuleWithId(ModuleDef.BRIDGE_MOD)
	lua_bridge:startDownloadImg(url,node)
end

function TablePart:chatClick()
	-- body
	local chat_part =self:getPart("ChatPart")
	if chat_part then
		chat_part:showSz()
	end
end

function TablePart:settingsClick()
	-- body
	--local settings_part = self:getPart("SettingsPart")
	--if settings_part then
	--	settings_part:activate()
	--end

	local roomsetting_part =self:getPart("RoomSettingPart")
	if roomsetting_part then
		roomsetting_part:activate(self.tableid)
	end
end

function TablePart:exitClick()
	-- body
	local tips_part = self:getPart("TipsPart")

	if tips_part then
		tips_part:activate({info_txt=string_table.is_back_to_lobby,left_click=function()
			-- body
			self:returnLobby()
		end})
	end
end

function TablePart:returnLobby()
	local net_mode = global:getModuleWithId(ModuleDef.NET_MOD)
	local opt_msg = ycmj_message_pb.PlayerGameOpertaion()
	opt_msg.opid = GameOperation.PLAYER_LEFT_TABLE
	net_mode:sendProtoMsg(opt_msg,MsgDef.MSG_GAME_OPERATION,SocketConfig.GAME_ID)
	self:returnGame()
end

function TablePart:gameEnd(data)
	-- body
	local game_end = self:getPart("GameEndPart")
	local card_part =self:getPart("CardPart")
	self.view:hideMenu()
	if game_end then
		game_end:activate(data , self.m_seat_id)
		if self.tableid > 1 then
			game_end:hideBackBtn() -- vip场小结算隐藏返回按钮
		end
	end

	if card_part then
		card_part:deactivate()
	end

	if self.smalluserinfo_part then
		self.smalluserinfo_part:deactivate()
	end
end

function TablePart:nextGame()
	-- body
    local ready_part = self:getPart("ReadyPart")
    if ready_part then
    	ready_part:showView()
    end

    self.owner:creatNewPlayerGame()
end


function TablePart:returnGame()
	-- body
	self:deactivate()
	local net_mode = global:getModuleWithId(ModuleDef.NET_MOD)
	net_mode:refreshSeq()
	print("------------------------客户端主动刷新双序号")
	local user = global:getGameUser()
	local lobby_part = global:createPart("LobbyPart",user)
	lobby_part:activate()
end

function TablePart:gameOperation(data,appId)
	-- body

	local game_op_ack = ycmj_message_pb.PlayerGameOpertaionAck()
	game_op_ack:ParseFromString(data)
	print("this is table part :gameOperation------------",game_op_ack)
end

function TablePart:gameOperationAck(data,appId)
	-- body
	local game_op_ack = ycmj_message_pb.PlayerGameOpertaionAck()
	game_op_ack:ParseFromString(data)
	print("this is  game op ack:",game_op_ack)
	if game_op_ack.opertaionID == GameOperation.TABLE_ADD_NEW_PLAYER then
		local player = self:decodePlayer(game_op_ack)
		player.view_id = self:changeSeatToView(player.tablepos)
		local ready_part = self:getPart("ReadyPart")
		ready_part:addPlayer(player)
		if self:getPlayerInfo(player.view_id) then --上线线重连通知
			self:offlinePlayer(player.view_id,true)
		end
	elseif game_op_ack.opertaionID == MahjongOperation.WAITING_OR_CLOSE_VIP then
		--self:showCloseVipRoomTips(game_op_ack.playerName , game_op_ack.playerIndex)
	elseif game_op_ack.opertaionID == GameOperation.PLAYER_LEFT_TABLE then
		local ready_part = self:getPart("ReadyPart")
		local pos = self:changeSeatToView(game_op_ack.tablePos)
		ready_part:hideIndex(pos)
		local gps_part = self:getPart("GpsPart")
		if gps_part then
			gps_part:sendGpsMsg(self.m_seat_id,self.tableid,true)
			gps_part:setIsShow(true)
		end
	end
end

function TablePart:decodePlayer(playerInfo)
	-- body
	local player = {}
	player.uid = playerInfo.playerIndex or playerInfo.uid 
	player.name = playerInfo.name or playerInfo.playerName
	player.headImgUrl = playerInfo.headImgUrl
	player.targetPlayerName = playerInfo.targetPlayerName
	player.sex = playerInfo.sex
	player.coin = playerInfo.coin or playerInfo.gold
	player.tablepos = playerInfo.tablepos or playerInfo.tablePos
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

function TablePart:closeVipRoomAck(data,appId)
	-- body
	--self:returnGame()
	--local ai_mod = global:getModuleWithId(ModuleDef.AI_MOD)
    --data = ai_mod:vipEndOverData()

    local function closeVipRoom()
        local dissolve_part = self:getPart("DissolvePart")
        if dissolve_part then
            dissolve_part:closeClick()
        end

        local tips_part = self:getPart("TipsPart")
        if tips_part then
            tips_part:deactivate()
        end

        local gps_part = self:getPart("GpsPart")
        if gps_part then
            gps_part:deactivate()
        end

        local game_over_ack = ycmj_message_pb.VipRoomClose()
        game_over_ack:ParseFromString(data)
        print("TablePart:closeVipRoomAck:", game_over_ack)
        local vip_over_part = self:getPart("VipOverPart")
        if vip_over_part then
            vip_over_part:activate(game_over_ack, self.tableid)
        end
    end

    self.view:closeVipRoomWithDelayTime(closeVipRoom)
end

--更新玩家属性
function TablePart:updatePlayerProperty(data,appId)

	self:doUpdatePlayerProperty(data,appId)
end

function TablePart:doUpdatePlayerProperty(data,appId)
	
	local player_property = ycmj_message_pb.UpdatePlayerPropertyMsg()
	player_property:ParseFromString(data)
	print("this is update player property :", player_property)

	local user = global:getGameUser()
	local player_info = user:getProp("gameplayer" .. SocketConfig.GAME_ID)

	player_info.gold = player_property.gold
	player_info.diamond = player_property.diamond
	
	user:setProp("gameplayer" .. SocketConfig.GAME_ID,player_info)
end

function TablePart:ntfOperation(data,appId)
	-- body
	self:doNtfOperation(data, appId)
end

function TablePart:doNtfOperation(data,appId)
	-- body
	local ntf_operation = ycmj_message_pb.PlayerOperationNotifyMsg()
	ntf_operation:ParseFromString(data)
	--if(ntf_operation.operation > 0x8000000) then
	--	ntf_operation.operation = 0x8000000
	--end

	print("this is  ntf_operation:",os.date(),ntf_operation)
	if ntf_operation.operation == MahjongOperation.GAME_OVER then --游戏结束
	elseif ntf_operation.operation == MahjongOperation.OFFLINE then --玩家离线
		self:operationOffline(ntf_operation)
	elseif ntf_operation.operation == MahjongOperation.HU_CARD_LIST_UPDATE then --提醒玩家可以胡的牌
		self:updateHuCard(ntf_operation)
	elseif ntf_operation.operation == MahjongOperation.ONLINE then --下线后又上线
        self:operationOffline(ntf_operation)
	elseif ntf_operation.operation == MahjongOperation.REMOE_CHU_CARD then --玩家打出的牌，被吃碰杠走了
		self:removeOutCard(ntf_operation)
	elseif ntf_operation.operation == MahjongOperation.OVERTIME_AUTO_CHU then --超时自动出牌
		self:autoOutCard(ntf_operation)
	elseif bit._and(ntf_operation.operation,MahjongOperation.CHI) == MahjongOperation.CHI or bit._and(ntf_operation.operation,MahjongOperation.PENG) == MahjongOperation.PENG or bit._and(ntf_operation.operation,MahjongOperation.BU_GANG) == MahjongOperation.BU_GANG
		or bit._and(ntf_operation.operation,MahjongOperation.AN_GANG) == MahjongOperation.AN_GANG or bit._and(ntf_operation.operation,MahjongOperation.MING_GANG) == MahjongOperation.MING_GANG 
		or bit._and(ntf_operation.operation,RoomConfig.Gang) == RoomConfig.Gang then --服务器通知轮到玩家吃牌血流杠会冲突
		self:operationCard(ntf_operation)
	elseif ntf_operation.operation == MahjongOperation.HU then
		self:operationCard(ntf_operation)
	elseif bit._and(ntf_operation.operation,MahjongOperation.CHU) == MahjongOperation.CHU then --轮到玩家出牌
		self:operationChu(ntf_operation)
	elseif ntf_operation.operation == MahjongOperation.ADD_CHU_CARD then --玩家出牌结束，牌没有被吃碰杠
		self:addOutCard(ntf_operation)
	elseif ntf_operation.operation == MahjongOperation.TIP then --提示当前谁在操作
		self:operationTip(ntf_operation)
	elseif ntf_operation.operation == MahjongOperation.CANCEL then --吃碰听超时
	elseif ntf_operation.operation == MahjongOperation.WAITING_OR_CLOSE_VIP then --提醒玩家有人掉线是否等待
	elseif ntf_operation.operation == MahjongOperation.NO_START_CLOSE_VIP then -- VIP房间超时未开始游戏，房间结束
	elseif ntf_operation.operation == MahjongOperation.UPDATE_PLAYER_GOLD then --更新桌上金币
	elseif ntf_operation.operation == MahjongOperation.PLAYER_HU_CONFIRMED then --玩家胡
		self:operationHu(ntf_operation)
	elseif bit._and(ntf_operation.operation,RoomConfig.MAHJONG_OPERTAION_POP_LAST) == RoomConfig.MAHJONG_OPERTAION_POP_LAST then
		--提示抓尾，即显示抓尾的2张牌
		self:operationCard(ntf_operation)
	end
end

function TablePart:operationOffline(data)
	print("operationOffline");
    local offline_pos = self:changeSeatToView(data.playertablepos)
    local online = true --默认在线
    if data.operation == MahjongOperation.OFFLINE then
        online = false
    end
    self:offlinePlayer(offline_pos,online)
end

function TablePart:operationHu(data)
	-- body
	local hu_pos = data.playertablepos
	local hu_card = data.targetcard
	local view_id = self:changeSeatToView(hu_pos)
	local card_part = self:getPart("CardPart")
	local ma1 = data.chiflag
	local ma2 = data.pengcardvalue
	local m_winner_ma = bit._or(ma1,bit.lshift(ma2,30))
	--解析码牌搞不懂为什么之前的人要写的这么蛋疼
	local m_table = {}
	local function checkMa(i)
		-- body
		local temp = bit._and(bit.rshift(m_winner_ma,6*i),0x3f)
		print("this is decode ma -------:",temp)
		if temp > 0 then
			table.insert(m_table,temp)
			checkMa(i+1)
		else
			card_part:showHuAnimate(view_id,m_table)
			--card_part:showOutCard(view_id,hu_card) --胡牌的时候，不需要再出 胡的牌
			card_part:showHuCardSp(view_id,hu_card)
		end
	end
	checkMa(0)

end


--更新听牌
function TablePart:updateHuCard(data)
	-- body
	if data.tinglist and #(data.tinglist) > 0 then
    	self.last_card_num = data.cardleftnum
    	self.view:updateLastCardNum(self.last_card_num)
    	local ting_list = data.tinglist
    	local card_part = self:getPart("CardPart")
	    card_part:tingCard(ting_list)
	elseif #(data.tinglist) == 0 then
		local ting_list = data.tinglist
    	local card_part = self:getPart("CardPart")
	    card_part:tingCard(ting_list)
	end
end

--玩家牌被吃碰了移除最后出的牌
function TablePart:removeOutCard(data)
	-- body
	local card_part = self:getPart("CardPart")
	local view_id = self:changeSeatToView(data.playertablepos)
	card_part:removeLastCard(view_id,data.targetcard)
end

function TablePart:operationTip(data)
	-- body
	self.last_card_num = data.cardleftnum
	self.view:updateLastCardNum(self.last_card_num)
	local card_part = self:getPart("CardPart")
	if card_part then
		local cur_view_id = self:changeSeatToView(data.playertablepos)
		card_part:turnSeat(cur_view_id)
	end
end

function TablePart:addOutCard(data)
	-- body
	self.last_card_num = data.cardleftnum
	self.view:updateLastCardNum(self.last_card_num)

	--把牌加到已出牌队列中
	local card_part = self:getPart("CardPart")
	local cur_seat_id = data.playertablepos 
	local cur_view_id = self:changeSeatToView(cur_seat_id)
	local card_value = data.targetcard
	card_part:outCard(cur_view_id,card_value)
end

function TablePart:operationCard(data)
	-- body
	-- local card_part = self:getPart("CardPart")
	-- print("This is operationCard:",bit._and(data.operation,MahjongOperation.PENG),bit._and(data.operation,MahjongOperation.AN_GANG),bit._and(data.operation,MahjongOperation.MING_GANG))
	-- if bit._and(data.operation,MahjongOperation.AN_GANG) == MahjongOperation.AN_GANG then
	-- 	local card_value = data.pengcardvalue
	-- 	local cur_seat_id = data.playertablepos
	-- 	local cur_view_id = self:changeSeatToView(cur_seat_id)
 --        local card_data = {mcard={card_value,card_value,card_value},ocard = card_value}
 --        card_part:getCard(card_value)
	-- 	card_part:ntfOpt(RoomConfig.AnGang,card_data,card_value)
	-- elseif bit._and(data.operation,MahjongOperation.BU_GANG) == MahjongOperation.BU_GANG then
	-- 	local card_value = data.pengcardvalue
	-- 	local cur_seat_id = data.playertablepos
	-- 	local cur_view_id = self:changeSeatToView(cur_seat_id)
	-- 	local card_data = {mcard ={card_value}}
	-- 	card_part:getCard(card_value)
	-- 	card_part:ntfOpt(RoomConfig.BuGang,card_data,card_value)
	-- elseif bit._and(data.operation,MahjongOperation.MING_GANG) == MahjongOperation.MING_GANG then
	-- 	local card_value = data.pengcardvalue
	-- 	local cur_seat_id = data.playertablepos
	-- 	local cur_view_id = self:changeSeatToView(cur_seat_id)
	-- 	local card_data = {mcard={card_value,card_value,card_value},ocard = card_value}
	-- 	card_part:ntfOpt(RoomConfig.MingGang,card_data,card_value)
	-- elseif bit._and(data.operation,MahjongOperation.PENG) == MahjongOperation.PENG then
	-- 	local c1 = bit._and(data.pengcardvalue,0xff)
	-- 	local c2 = bit._and(bit.rshift(data.pengcardvalue,8),0xff)
	-- 	local cur_seat_id = data.playertablepos
	-- 	local cur_view_id = self:changeSeatToView(cur_seat_id)
	-- 	local card_data = {mcard={c1,c2},ocard=c1}
	-- 	card_part:ntfOpt(RoomConfig.Peng,card_data,data.pengcardvalue)
	-- end

	local card_part = self:getPart("CardPart")
	local dis_play_guo = true --是否显示过牌
	print("This is TablePart operationCard:",bit._and(data.operation,RoomConfig.MAHJONG_OPERTAION_CHU),bit._and(data.operation,MahjongOperation.AN_GANG),bit._and(data.operation,MahjongOperation.MING_GANG))


	if bit._and(data.operation,RoomConfig.Gang) == RoomConfig.Gang and bit._and(data.operation,RoomConfig.MAHJONG_OPERTAION_HU) ~= RoomConfig.MAHJONG_OPERTAION_HU then
  		local card_data = data.gangList
  		if bit._and(data.operation,RoomConfig.MAHJONG_OPERTAION_CHU) == RoomConfig.MAHJONG_OPERTAION_CHU  then
  			dis_play_guo = false --自己出牌不显示过  
   		else
  			card_part:addOpt(RoomConfig.Gang)		
  		end
  		card_part:ntfGangList(card_data)
	end

	if bit._and(data.operation,RoomConfig.MAHJONG_OPERTAION_CHU) == RoomConfig.MAHJONG_OPERTAION_CHU  then --自己摸了一张牌
		print("this is YNTablePart get card -------------------------------------------")
		if data.chicardvalue ~= 0 then
			card_part:getCard(data.chicardvalue)
		end
   	end

	if bit._and(data.operation,MahjongOperation.PENG) == MahjongOperation.PENG then
		local c1 = bit._and(data.pengcardvalue,0xff)
		local c2 = bit._and(bit.rshift(data.pengcardvalue,8),0xff)
		local cur_seat_id = data.playertablepos
		local cur_view_id = self:changeSeatToView(cur_seat_id)
		local card_data = {mcard={c1,c2},ocard=c1}
		card_part:addOpt(RoomConfig.Peng)
	end

	if bit._and(data.operation,MahjongOperation.CHI) == MahjongOperation.CHI then
		card_part:setChiList(data.chicardvalue,data.targetcard)
		card_part:addOpt(RoomConfig.Chi)
	end

	if bit._and(data.operation,MahjongOperation.HU) == MahjongOperation.HU then
		card_part:addOpt(MahjongOperation.HU)
	end

	if bit._and(data.operation,RoomConfig.MAHJONG_OPERTAION_POP_LAST) == RoomConfig.MAHJONG_OPERTAION_POP_LAST then
		--显示2张 可点击的尾牌
		local cur_seat_id = data.playertablepos
		local cur_view_id = self:changeSeatToView(cur_seat_id)
		local card_data = {mcard={},ocard=data.targetcard}
		card_part:ntfOpt(RoomConfig.MAHJONG_OPERTAION_POP_LAST,card_data,data.targetcard)
		return
	end

	card_part:showAddOpt(data.pengcardvalue,dis_play_guo)
end


--自己摸了一张牌
function TablePart:operationChu(data)
	-- body
	local card_part = self:getPart("CardPart")
	if data.chicardvalue ~= 0 then --是否摸了新牌，如果是断线回来，这个通知里面没有新牌
		card_part:getCard(data.chicardvalue)
	end

	local opt_type = nil
	local card_value = {}
	--如果玩家听牌
	if bit._and(data.operation,RoomConfig.MAHJONG_OPERTAION_HU) == RoomConfig.MAHJONG_OPERTAION_HU then
		opt_type = RoomConfig.MAHJONG_OPERTAION_HU
		card_value.mcard = {}
	end

	if bit._and(data.operation,MahjongOperation.AN_GANG) == MahjongOperation.AN_GANG then
		opt_type = RoomConfig.AN_GANG
		card_value.mcard = {data.pengcardvalue,data.pengcardvalue,data.pengcardvalue,data.pengcardvalue}
	end

	if bit._and(data.operation,MahjongOperation.BU_GANG) == MahjongOperation.BU_GANG then
		opt_type = RoomConfig.BU_GANG
		card_value.mcard = {data.pengcardvalue}
	end

	if opt_type then
		card_part:ntfOpt(opt_type,card_value)
	end
end

--自动出牌显示托管状态
function TablePart:autoOutCard(data)
	-- body
	local card_part = self:getPart("CardPart")
	if card_part then
		card_part:setAutoOutCard(true)
	end
end

function TablePart:gameStartNtf(data,appId)
	-- body
	local game_start = ycmj_message_pb.GameStartMsg()
	game_start:ParseFromString(data)
	globlerule = game_start.newplayway
	self.playerwin = game_start.playerwin
	print("TablePart:gameStartNtf:",game_start)
	
	--设置手牌的张数--如果是13张牌的时候需要向右偏移--策划需求
	if globlerule ~= nil then
		if globlerule >= bit.lshift(1,24) and globlerule < bit.lshift(1,25) then--手牌13张
			handCardNumFlag = 13
		elseif globlerule >= bit.lshift(1,25) and globlerule < bit.lshift(1,26) then--手牌16张
			handCardNumFlag = 16
		elseif globlerule >= bit.lshift(1,26) and globlerule < bit.lshift(1,27) then
			handCardNumFlag = 16
		end
	end
	
	local ready_part = self:getPart("ReadyPart")
	ready_part:hideView()
	self:startGame(game_start)
end

function TablePart:headClick(player_info , posX , posY , viewId )
	self.smalluserinfo_part = self:getPart("SmallUserInfoPart") 
	if self.smalluserinfo_part then
		self.smalluserinfo_part:deactivate()
		local is_vip = false
		if self.tableid > 1 then
			is_vip = true
		end
		self.smalluserinfo_part:activate(player_info , posX , posY , viewId ,self.playerwin,is_vip)
	end
end

function TablePart:playerOperation(data,appId)
	-- body
	self:doPlayerOperation(data, appId);	
end

function TablePart:doPlayerOperation(data, appId)
	-- body
	local card_part = self:getPart("CardPart")
	local player_operaction = ycmj_message_pb.PlayerTableOperationMsg()
	player_operaction:ParseFromString(data)
    print("TablePart:playerOperation:",player_operaction,bit._and(player_operaction.operation,MahjongOperation.BU_GANG))
	local cur_seat_id = player_operaction.player_table_pos
	local cur_view_id = self:changeSeatToView(cur_seat_id)

	if player_operaction.operation == RoomConfig.MAHJONG_OPERTAION_POP_LAST then --刷新左上角的尾牌
		local cur_seat_id = player_operaction.player_table_pos
		local cur_view_id = self:changeSeatToView(cur_seat_id)
		local card_data = {mcard={},ocard=player_operaction.card_value}
		card_part:optCard(cur_view_id,RoomConfig.MAHJONG_OPERTAION_POP_LAST,card_data)
	elseif bit._and(player_operaction.operation,MahjongOperation.CHU) == MahjongOperation.CHU then --其他玩家出牌
		if cur_seat_id == self.m_seat_id and #player_operaction.handCards  > 0 then --如果是自己就刷新手牌
			local card_value = player_operaction.card_value
			card_part:showAutoOutCard(card_value) --托管需要出牌
			card_part:refreshMyCard(player_operaction.handCards,player_operaction.downCards,player_operaction.beforeCards,card_value)
		elseif cur_seat_id ~= self.m_seat_id then
			local card_value = player_operaction.card_value
			card_part:showOutCard(cur_view_id,card_value)
		end
	elseif bit._and(player_operaction.operation,MahjongOperation.AN_GANG) == MahjongOperation.AN_GANG or bit._and(player_operaction.operation,MahjongOperation.MING_GANG) == MahjongOperation.MING_GANG or bit._and(player_operaction.operation,MahjongOperation.BU_GANG) == MahjongOperation.BU_GANG then
        local card_value = player_operaction.opValue
        local c1 = bit._and(card_value,0xff)
        local c2 = bit._and(bit.rshift(card_value,8),0xff)
        local c3 = bit._and(bit.rshift(card_value,16),0xff)
        local c4 = bit._and(bit.rshift(card_value,32),0xff)

        if player_operaction.opValue == MahjongOperation.GANG_NOTIFY  then
         	return
        end


		local op_card = 0
		if c1 == c4 then
		  op_card = bit._or(bit._or(bit.lshift(c3,16),bit.lshift(c1,8)),c2)
		elseif c3 == c4 then
		  op_card = bit._or(bit._or(bit.lshift(c2,16),bit.lshift(c3,8)),c1)
        else
          op_card = bit._or(player_operaction.opValue,0xffffff)
        end

		op_card = bit._or(op_card,bit.lshift(c2,24))

		local card = {}
		for i=1, 4 do
		  	card[i] = bit._and(bit.rshift(op_card,(i-1)*8),0xff)
		end
		local cur_seat_id = player_operaction.player_table_pos
		local cur_view_id = self:changeSeatToView(cur_seat_id)
		local card_data = {mcard={card[1],card[2],card[3]},ocard=card[4]}

		if bit._and(player_operaction.operation,MahjongOperation.AN_GANG) == MahjongOperation.AN_GANG then
			card_data = {mcard={RoomConfig.EmptyCard,RoomConfig.EmptyCard,RoomConfig.EmptyCard,RoomConfig.EmptyCard}}
			if cur_seat_id == self.m_seat_id then --我自己可以看见第二张牌
				card_data = {mcard= {RoomConfig.EmptyCard,RoomConfig.EmptyCard,RoomConfig.EmptyCard,card[4]}}
			end
		elseif bit._and(player_operaction.operation,MahjongOperation.BU_GANG) == MahjongOperation.BU_GANG then
			card_data = {mcard={card[1]}} --补杠只有一张牌
        elseif bit._and(player_operaction.operation,MahjongOperation.MING_GANG) == MahjongOperation.MING_GANG then
            card_data = {mcard={c1,c2,c3},ocard=c4}
        end
		card_part:optCard(cur_view_id,player_operaction.operation,card_data)
	elseif bit._and(player_operaction.operation,MahjongOperation.PENG) == MahjongOperation.PENG then --碰
		local opvalue = player_operaction.opValue
		local c1 = bit._and(opvalue,0xff)
		local c2 = bit._and(bit.rshift(opvalue,8),0xff)
		local c3 = bit._and(bit.rshift(opvalue,16),0xff)
		print("this is  peng:",c1,c2,c3)
		local cur_seat_id = player_operaction.player_table_pos
		local cur_view_id = self:changeSeatToView(cur_seat_id)
		local card_data = {mcard={c1,c2},ocard=c3}
		card_part:optCard(cur_view_id,RoomConfig.Peng,card_data)
		-- card_part:ntfOpt(RoomConfig.Peng,card_data)
	elseif bit._and(player_operaction.operation,MahjongOperation.CHI) == MahjongOperation.CHI then --吃
		local opvalue = player_operaction.opValue
		local c = {}
		for i=1,4 do
			table.insert(c,bit._and(bit.rshift(opvalue,(i-1)*8),0xff))
		end
		print("this is  chi:",c[1],c[2],c[3],c[4])
		
		local cur_seat_id = player_operaction.player_table_pos
		local cur_view_id = self:changeSeatToView(cur_seat_id)
		local card_data = {mcard={c1,c2},ocard=c3}
		if c[4] ~= 0 then --服务端逻辑很诡异判断下为好
			card_data.mcard = {}
			for i=1,3 do
				if c[i] ~= c[4] then
					table.insert(card_data.mcard,c[i])
				end	
			end
			card_data.ocard = c[4]
		end
		card_part:optCard(cur_view_id,RoomConfig.Chi,card_data)
	end
end

function TablePart:gameOverAck(data,appId)
	-- body
	local game_over_ack = ycmj_message_pb.PlayerGameOverAck()
	game_over_ack:ParseFromString(data)
	--print("TablePart:gameOverAck:",game_over_ack)
	self:gameEnd(game_over_ack)
end

function TablePart:changeSeatToView(seatId)
	-- body
	if self.m_seat_id then
		return (seatId - self.m_seat_id + 4)%4 + 1
	end
end

--发送申请解散VIP房间
function TablePart:closeVipRoom(readyCall)
	-- body
	local tips_part = global:createPart("TipsPart",self)
	if tips_part then
		tips_part:activate({info_txt=string_table.close_vip_room_tip,left_click=function()
			-- body
			if readyCall and self.cur_hand <= 0   then --准备界面调起
				local net_mode = global:getModuleWithId(ModuleDef.NET_MOD)
			    local opt_msg = ycmj_message_pb.PlayerGameOpertaion()
			    opt_msg.opid = GameOperation.APPLY_CLOSE_VIP_ROOM	     -- 房主申请解散VIP房间
			   	opt_msg.opvalue = self.tableid                           -- 1:请求解散 2：同意解散
			    net_mode:sendProtoMsg(opt_msg,MsgDef.MSG_GAME_OPERATION,SocketConfig.GAME_ID)
			    print("self.uid self.createid : ",self.uid ,self.createid)
			    if self.uid ~= self.createid then --不是房主直接离开
			    	self:returnGame()
			    end
			else --请求解散房间
				local net_mode = global:getModuleWithId(ModuleDef.NET_MOD)
			    local opt_msg = ycmj_message_pb.PlayerTableOperationMsg()
			    opt_msg.operation = MahjongOperation.WAITING_OR_CLOSE_VIP	     -- 房主申请解散VIP房间
			   	opt_msg.opValue = 1                           -- 1:请求解散 2：同意解散
			   	if SocketConfig.IS_SEQ == false then	
			    	local buff_str = opt_msg:SerializeToString()
			    	local buff_lenth = opt_msg:ByteSize()
			    	net_mode:sendMsg(buff_str,buff_lenth,MsgDef.MSG_PLAYER_OPERATION,SocketConfig.GAME_ID)
			    elseif SocketConfig.IS_SEQ == true then
			   		net_mode:sendProtoMsgWithSeq(opt_msg,MsgDef.MSG_PLAYER_OPERATION,SocketConfig.GAME_ID)
			   	end
			end
		end})
	end

end

function TablePart:showCloseVipRoomTips( playerName,playerIndex)
	-- body
	print("---------showCloseVipRoomTips : ",playerName,playerIndex)
	local string_info = string.format(string_table.player_close_room_req,playerName,playerIndex)
	local tips_part = self:getPart("TipsPart")
	if tips_part then
		tips_part:activate({info_txt=string_info,left_click=function()
			-- body 
			print("同意解散")
		 	self:sureCloseVipRoom(2)
		end,right_click=function()
			-- body
			print("取消解散")
		 	self:sureCloseVipRoom(3)
		end})
	end
end

--同意解散房间
function TablePart:sureCloseVipRoom(op_id)
	-- body
	print("-----sureCloseVipRoom op_id ：",op_id)
	local net_mode = global:getModuleWithId(ModuleDef.NET_MOD)
    local opt_msg = ycmj_message_pb.PlayerTableOperationMsg()
    opt_msg.operation = MahjongOperation.WAITING_OR_CLOSE_VIP 	     -- 房主申请解散VIP房间
   	opt_msg.opValue = op_id                           -- 1:请求解散 2：同意解散 3:取消解散
   	if SocketConfig.IS_SEQ == false then
	    net_mode:sendProtoMsg(opt_msg,MsgDef.MSG_PLAYER_OPERATION,SocketConfig.GAME_ID)
	elseif SocketConfig.IS_SEQ == true then
    	net_mode:sendProtoMsgWithSeq(opt_msg,MsgDef.MSG_PLAYER_OPERATION,SocketConfig.GAME_ID)
    end
end

function TablePart:scrollMsgAck(data,appId)		--跑马灯消息
	-- body
	--if tonumber(appId) == tonumber(SocketConfig.GAME_ID) then

    -- 因跑马灯信息被牌遮挡因此将此功能移到cardlayer中，注意cardlayerUI中要添加BroadcastNode节点 DFL 2017年3月17日
--		local broadcast_node = self:getPart("BroadcastPart")
--	    if broadcast_node then
--	    	broadcast_node:isShowBroadcastNode(true)
--	    end

--		local net_manager = global:getNetManager()
--		local scroll_msg = wllobby_message_pb.ScrollMsg()
--		scroll_msg:ParseFromString(data)
--		print("----scrollMsgAck: ",scroll_msg)
--		local msg = scroll_msg.msg
--		local loopNum = scroll_msg.loopNum
--		local removeAll = scroll_msg.removeAll

--		local broadcast_node = self:getPart("BroadcastPart")
--		broadcast_node:startBroadcast(msg,loopNum,removeAll,true,appId)

        local card_part = self:getPart("CardPart")
        if card_part then
            card_part:isShowBroadcastNode(true)

            local net_manager = global:getNetManager()
            local scroll_msg = wllobby_message_pb.ScrollMsg()
            scroll_msg:ParseFromString(data)
            local msg = scroll_msg.msg
            local loopNum = scroll_msg.loopNum
            local removeAll = scroll_msg.removeAll

            card_part:startBroadcast(msg, loopNum, removeAll, true, appId)
        end

		local ready_part = self:getPart("ReadyPart")
		if ready_part then
			ready_part:scrollMsgAck(data,appId)
		end
	--end
end
--是否同意解散房间用户列表
function TablePart:closeVipTableAck(data,appId)
	local close_vip_tablemsg_ack = ycmj_message_pb.CloseVipTableMsgAck()
	close_vip_tablemsg_ack:ParseFromString(data)
	print("DissolvePart:closeVipTableAck:",close_vip_tablemsg_ack)

	local dissolve_part = self:getPart("DissolvePart")
	if dissolve_part then
		dissolve_part:setData(close_vip_tablemsg_ack , self.player_list ,self.m_seat_id)
	end

	if close_vip_tablemsg_ack.mCloseStatus ~= 1 then
		local tips_part = self:getPart("TipsPart")
		if tips_part then
			tips_part:deactivate()
		end
	end
end

function TablePart:notifySeqToClienTMsg()
	local net_mode = global:getModuleWithId(ModuleDef.NET_MOD)
	local ntf_operation = ycmj_message_pb.PlayerOperationNotifyMsg()
	ntf_operation.operation = RoomConfig.MAHJONG_OPERATION_GET_CLOSE_VIP_ROOM_MSG
	if SocketConfig.IS_SEQ == false then
	    net_mode:sendProtoMsg(ntf_operation,MsgDef.MSG_PLAYER_OPERATION,SocketConfig.GAME_ID)
	elseif SocketConfig.IS_SEQ == true then
    	net_mode:sendProtoMsgWithSeq(ntf_operation,MsgDef.MSG_PLAYER_OPERATION,SocketConfig.GAME_ID)
    end
end

function TablePart:getTableid()
	-- body
	return self.tableid
end

function TablePart:startLoading()
	-- body
	local loading_part = global:createPart("LoadingPart",self)
	self:addPart(loading_part)
	loading_part:activate()
end

function TablePart:endLoading()
	-- body
	local loading_part = self:getPart("LoadingPart")
	if loading_part then
		loading_part:deactivate()
	end
end

function TablePart:showGpsTip(index,distance)
	-- body
	print("TablePart:showGpsTip : ",index,distance)
	local gpsTip_part = self:getPart("GpsTipPart")
	if gpsTip_part then
		gpsTip_part:setInfo(index,distance)
	end
end

return TablePart