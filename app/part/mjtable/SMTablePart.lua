local CURRENT_MODULE_NAME = ...
local TablePart = import(".TablePart")
local SMTablePart = class("SMTablePart",TablePart)
SMTablePart.DEFAULT_VIEW = "SMTableScene"

SMTablePart.DEFAULT_PART = {
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
    "CheckHuaPart",
}

function SMTablePart:ctor(...)
    SMTablePart.super.ctor(self, ...)
    self.bCardLifted = false     --  牌是否已经被吃提起过了  
    
    self.iLogGetCardNum = 0 
    self.nameList = {} 
end

function SMTablePart:activate(data)
	-- SMTablePart.super.activate(self, data)
	-- self.view:showHelpInfoBtn();

    -- 进入游戏场不需要延时断线
    if IOS_BACK_DELAY == true then
        IOS_BACK_DELAY = false
        local lua_bridge = global:getModuleWithId(ModuleDef.BRIDGE_MOD)
        if lua_bridge.setBackDelayTime then
            lua_bridge:setBackDelayTime(10)
        end
    end
    ----------------------------------------------------------------------
    local net_mode = global:getModuleWithId(ModuleDef.NET_MOD)
    net_mode:registerMsgListener(MsgDef.MSG_GAME_OPERATION, handler(self, TablePart.gameOperation))  -- 没有操作 
    net_mode:registerMsgListener(MsgDef.MSG_GAME_VIP_ROOM_CLOSE, handler(self, TablePart.closeVipRoomAck))  -- 解散房间通知,展示解散房间页面
    net_mode:registerMsgListener(MsgDef.MSG_GAME_OPERATION_ACK, handler(self, TablePart.gameOperationAck)) -- 添加、移除用户 关闭房间的服务器返回
    net_mode:registerMsgListener(MsgDef.MSG_GAME_UPDATE_PLAYER_PROPERTY, handler(self, TablePart.updatePlayerProperty)) -- 更新玩家信息 没有操作
    net_mode:registerMsgListener(MsgDef.MSG_PLAYER_OPERATION_NTF, handler(self, TablePart.ntfOperation)) -- 提醒玩家进行操作
    net_mode:registerMsgListener(MsgDef.MSG_GAME_START, handler(self, TablePart.gameStartNtf)) -- 牌局开始
    net_mode:registerMsgListener(MsgDef.MSG_PLAYER_OPERATION, handler(self, TablePart.playerOperation))
    net_mode:registerMsgListener(MsgDef.MSG_GAME_OVER_ACK, handler(self, TablePart.gameOverAck))
    net_mode:registerMsgListener(MsgDef.MSG_GAME_OTHERLOGIN_ACK, handler(self, TablePart.otherLogin))
    net_mode:registerMsgListener(SocketConfig.MSG_GAME_SEND_SCROLL_MES, handler(self, TablePart.scrollMsgAck))
    net_mode:registerMsgListener(SocketConfig.MSG_CLOSE_VIP_TABLE_ACK, handler(self, TablePart.closeVipTableAck))
    net_mode:registerMsgListener(SocketConfig.MSG_NOTIFY_SEQ_TO_CLIENT_MSG, handler(self, TablePart.notifySeqToClienTMsg))
    --net_mode:registerMsgListener(MsgDef.MSG_PLAYER_OPERATION , handler(self, self.checkHua))
    TablePart.super.activate(self, CURRENT_MODULE_NAME)
    local wifi_and_net = self:getPart("WifiAndNetPart")
    if wifi_and_net then
        wifi_and_net:activate(self.view.node.wifi_net_node)
    end

--    local broadcast_node = self:getPart("BroadcastPart")
--    if broadcast_node then
--        broadcast_node:activate(self.view.node.broadcast_node)
--        broadcast_node:isShowBroadcastNode(false)
--    end

    local ready_part = self:getPart("ReadyPart")

    if ready_part then
        ready_part:activate(data)
    end

    local dissolve_part = self:getPart("DissolvePart")
    if dissolve_part then
        dissolve_part:activate(data)
        dissolve_part:setShowFirstState(true)
    end
    
    self.m_seat_id = data.tableinfo.tablepos
    self.tableid = data.tableinfo.viptableid -- 判断是不是vip场
	self.no_Touch = false
    self.createid = data.tableinfo.creatorid
    self.tableid = data.tableinfo.viptableid -- 判断是不是vip场
   
    print("------------self.tableid : ", self.tableid, self.cur_hand)
    if self.tableid > 1 then
        -- 是否显示解散房间按钮
        self.view:isShowCloseBtn(true)
        self.view:showGoldOrVipText(true, self.tableid)
    else
        self.view:isShowCloseBtn(false)
        self.view:showGoldOrVipText(false)
    end

    local gps_part = self:getPart("GpsPart")
    if gps_part then
        gps_part:activate(self.m_seat_id, self.tableid)
    end

    self.cur_hand = data.tableinfo.currenthand -- 当前局数
    if self.cur_hand <= 0 then
        local gpsTip_part = self:getPart("GpsTipPart")
        if gpsTip_part then
            gpsTip_part:activate()
        end
    end
	
    self.player_list = { }

    local user = global:getGameUser()
    local game_player = user:getProp("gameplayer" .. SocketConfig.GAME_ID)
    self.playerIndex = game_player.playerIndex

    -- 加入界面坐标
    for k, v in ipairs(data.tableinfo.players) do
        self.player_list[k] = self:decodePlayer(v)

        if v.tablepos then
            self.player_list[k].view_id = self:changeSeatToView(v.tablepos)
        end

        if tonumber(v.playerIndex) == tonumber(self.playerIndex) then
            self.uid = v.uid
        end

        if v.intable == 0 then
            -- 离线
            self:offlinePlayer(self.player_list[k].view_id, false)
        end
    end

end


-- 开始游戏
function SMTablePart:startGame(data)
	-- body
	local chat_part = self:getPart("ChatPart")
    if chat_part then
    	local pos_table = self.view:getPosTable()
		chat_part:activate(pos_table)
		-- chat_part:hideSzBtn()
    end

	local card_part = self:getPart("CardPart")
    card_part:activate(data)

    if self.tableid > 1 then ----显示当前局数和总局数  1/4局
    	local quanTotal = bit._and(data.serviceGold,0xff)
    	self.view:dispalyQuan(data.quannum,quanTotal)
		self.quannum = data.quannum;
		self.quanTotal = quanTotal;
    end

	self.last_card_num = 0
	self.m_seat_id = data.mtablePos
	self.view:initTableWithData(self.player_list,data)
end

-- 通知操作
function SMTablePart:doNtfOperation(data,appId)
	-- body
	local ntf_operation = ycmj_message_pb.PlayerOperationNotifyMsg()
	ntf_operation:ParseFromString(data)
	--if(ntf_operation.operation > 0x8000000) then
	--	ntf_operation.operation = 0x8000000
	--end

	print("this is  ntf_operation:",os.date(),ntf_operation)
	if ntf_operation.operation == MahjongOperation.GAME_OVER then --游戏结束

    elseif ntf_operation.operation == 0x40 then
        local checkhua_part =self:getPart("CheckHuaPart")
        chahua_part:activate(data)
    --elseif ntf_operation.operation == MahjongOperation.JIN_KAN then -- 金坎
    elseif ntf_operation.operation == 0x40 then -- 金坎 -- 因为部分手机无法读取到金坎配置 才把类型写死
		-- 金坎提示按钮
		print(" ==== 金坎  金坎   金坎  ======= ")
		self:operationTipCardJK(ntf_operation)
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
	elseif ntf_operation.operation == RoomConfig.MAHJONG_QIANG_JIN then
		self:operationCard(ntf_operation)
	elseif bit._and(ntf_operation.operation,RoomConfig.MAHJONG_SAN_JIN_DAO) == RoomConfig.MAHJONG_SAN_JIN_DAO or bit._and(ntf_operation.operation,RoomConfig.MAHJONG_SAN_YOU) == RoomConfig.MAHJONG_SAN_YOU 
		or bit._and(ntf_operation.operation,RoomConfig.MAHJONG_SHUANG_YOU) == RoomConfig.MAHJONG_SHUANG_YOU or bit._and(ntf_operation.operation,RoomConfig.MAHJONG_DAN_YOU) == RoomConfig.MAHJONG_DAN_YOU then --双游三游
		self:operationCard(ntf_operation)
	elseif ntf_operation.operation == MahjongOperation.HU then
		self:operationCard(ntf_operation)
	elseif bit._and(ntf_operation.operation,MahjongOperation.CHU) == MahjongOperation.CHU then --轮到玩家出牌
		self:operationChu(ntf_operation)
	elseif ntf_operation.operation == MahjongOperation.ADD_CHU_CARD then --玩家出牌结束，牌没有被吃碰杠
		self:addOutCard(ntf_operation)
	elseif ntf_operation.operation == MahjongOperation.TIP then --提示当前谁在操作
        if ntf_operation.chiflag == 1 then
            self.no_Touch = true
        else 
            self.no_Touch = false
        end
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
	elseif bit._and(ntf_operation.operation, RoomConfig.MAHJONG_OPERTAION_TIP_CARD_YJ) == RoomConfig.MAHJONG_OPERTAION_TIP_CARD_YJ then
		-- 游金提示卡牌
		self:operationTipCardYJ(ntf_operation);
	end
end

--自己摸了一张牌
function SMTablePart:operationChu(data)
	-- body
	local card_part = self:getPart("CardPart")
	-- if data.chicardvalue ~= 0 then --是否摸了新牌，如果是断线回来，这个通知里面没有新牌
	-- 	card_part:getCard(data.chicardvalue)
	-- end

	-- print("dgfffffffffffffffff", data.cardleftnum, data.chicardvalue, data.pengcardvalue);
	-- print("This is SMTablePart operationChu:", data.operation, bit._and(data.operation,RoomConfig.MAHJONG_SAN_JIN_DAO))

	if bit._and(data.operation,RoomConfig.MAHJONG_OPERTAION_CHU) == RoomConfig.MAHJONG_OPERTAION_CHU  then
		if data.chicardvalue ~= 0 and 1 ~= data.chaCard then
			card_part:getCard(data.chicardvalue)
		end
	end

	local dis_play_guo = false --是否显示过牌

	local opt_type = nil
	local card_value = {}

	if bit._and(data.operation,RoomConfig.MAHJONG_SAN_JIN_DAO) == RoomConfig.MAHJONG_SAN_JIN_DAO then
		opt_type = RoomConfig.MAHJONG_SAN_JIN_DAO
		dis_play_guo = true;
		card_part:addOpt(RoomConfig.MAHJONG_SAN_JIN_DAO)
	end

	if bit._and(data.operation,RoomConfig.MAHJONG_QIANG_JIN) == RoomConfig.MAHJONG_QIANG_JIN then
		opt_type = RoomConfig.MAHJONG_QIANG_JIN
		dis_play_guo = true;
		card_part:addOpt(RoomConfig.MAHJONG_QIANG_JIN)
	end

	if bit._and(data.operation,RoomConfig.MAHJONG_SAN_YOU) == RoomConfig.MAHJONG_SAN_YOU then
		opt_type = RoomConfig.MAHJONG_SAN_YOU
		dis_play_guo = true;
		card_part:addOpt(RoomConfig.MAHJONG_SAN_YOU)
	end

	if bit._and(data.operation,RoomConfig.MAHJONG_SHUANG_YOU) == RoomConfig.MAHJONG_SHUANG_YOU then
		opt_type = RoomConfig.MAHJONG_SHUANG_YOU
		dis_play_guo = true;
		card_part:addOpt(RoomConfig.MAHJONG_SHUANG_YOU)
	end

	if bit._and(data.operation,RoomConfig.MAHJONG_DAN_YOU) == RoomConfig.MAHJONG_DAN_YOU then
		opt_type = RoomConfig.MAHJONG_DAN_YOU
		dis_play_guo = true;
		card_part:addOpt(RoomConfig.MAHJONG_DAN_YOU)
	end

	--如果玩家听牌
	if bit._and(data.operation,RoomConfig.MAHJONG_OPERTAION_HU) == RoomConfig.MAHJONG_OPERTAION_HU then
		dis_play_guo = true;
		opt_type = RoomConfig.MAHJONG_OPERTAION_HU
		card_value.mcard = {}
		card_part:addOpt(RoomConfig.MAHJONG_OPERTAION_HU)
	end

	if bit._and(data.operation,RoomConfig.Gang) == RoomConfig.Gang then
  		local card_data = data.gangList
		dis_play_guo = true;
		card_part:addOpt(RoomConfig.Gang)
  		card_part:ntfGangList(card_data)
	end

	if opt_type then
		card_part:showAddOpt(data.pengcardvalue, dis_play_guo) --自己摸牌不显示过
	end
end

function SMTablePart:getRoomID()
    local nodeReadyPart = self:getPart("ReadyPart")
    local iRoomID = nodeReadyPart:getRoomID()
    return iRoomID
end

function SMTablePart:operationCard(data)
	-- body
    self.bCardLifted = false
	local card_part = self:getPart("CardPart")
	local dis_play_guo = true --是否显示过牌
	-- print("This is SMTablePart operationCard:",bit._and(data.operation,MahjongOperation.PENG),bit._and(data.operation,MahjongOperation.AN_GANG),bit._and(data.operation,MahjongOperation.MING_GANG))

	if bit._and(data.operation,RoomConfig.MAHJONG_OPERTAION_CHU) == RoomConfig.MAHJONG_OPERTAION_CHU  then
		if data.chicardvalue ~= 0 and 1 ~= data.chaCard then
			card_part:getCard(data.chicardvalue)
		end	
	end

	if bit._and(data.operation,RoomConfig.MAHJONG_SAN_JIN_DAO) == RoomConfig.MAHJONG_SAN_JIN_DAO then
		card_part:addOpt(RoomConfig.MAHJONG_SAN_JIN_DAO)
	end

	if bit._and(data.operation,RoomConfig.MAHJONG_QIANG_JIN) == RoomConfig.MAHJONG_QIANG_JIN then
		card_part:addOpt(RoomConfig.MAHJONG_QIANG_JIN)
	end

	if bit._and(data.operation,RoomConfig.MAHJONG_SAN_YOU) == RoomConfig.MAHJONG_SAN_YOU then
		card_part:addOpt(RoomConfig.MAHJONG_SAN_YOU)
	end

	if bit._and(data.operation,RoomConfig.MAHJONG_SHUANG_YOU) == RoomConfig.MAHJONG_SHUANG_YOU then
		card_part:addOpt(RoomConfig.MAHJONG_SHUANG_YOU)
	end

	if bit._and(data.operation,RoomConfig.MAHJONG_DAN_YOU) == RoomConfig.MAHJONG_DAN_YOU then
		card_part:addOpt(RoomConfig.MAHJONG_DAN_YOU)
	end

--	if bit._and(data.operation,RoomConfig.Gang) == RoomConfig.Gang and bit._and(data.operation,RoomConfig.MAHJONG_OPERTAION_HU) ~= RoomConfig.MAHJONG_OPERTAION_HU then
--  		local card_data = data.gangList
--		card_part:addOpt(RoomConfig.Gang)
--  		card_part:ntfGangList(card_data)
--	end

    if bit._and(data.operation, RoomConfig.Gang) == RoomConfig.Gang then
        local card_data = data.gangList
        card_part:addOpt(RoomConfig.Gang)
        card_part:ntfGangList(card_data)

        if false == self.bCardLifted then
            -- 如果只有一组可以提起的牌则将牌提起
            if 1 == #card_data then
                local iValue = bit._and(card_data[1].cardValue, 0xff)
                -- 记录杠的牌值
                card_part:setGangValue(iValue)
                -- 设置被举起的牌
                self.bCardLifted = true
                card_part:liftCanGangCard()
            end
        end
    end

	if bit._and(data.operation,MahjongOperation.PENG) == MahjongOperation.PENG then
		local c1 = bit._and(data.pengcardvalue,0xff)
		local c2 = bit._and(bit.rshift(data.pengcardvalue,8),0xff)
		local cur_seat_id = data.playertablepos
		local cur_view_id = self:changeSeatToView(cur_seat_id)
		local card_data = {mcard={c1,c2},ocard=c1}
        card_part:addOpt(RoomConfig.Peng)

        -- 设置被举起的牌
        if false == self.bCardLifted then
            -- 设置碰的牌的值
            card_part:setPengValue(c1)
            self.bCardLifted = true
            card_part:liftCanPengCard()
        end
	end

	if bit._and(data.operation,MahjongOperation.CHI) == MahjongOperation.CHI then
		card_part:setChiList(data.chicardvalue,data.targetcard)
        card_part:addOpt(RoomConfig.Chi)

        -- 设置被举起的牌
        if false == self.bCardLifted then
            self.bCardLifted = true
            card_part:liftCanChiCard()
        end
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


function SMTablePart:doPlayerOperation(data, appId)
	-- body
	local card_part = self:getPart("CardPart")
	local player_operaction = ycmj_message_pb.PlayerTableOperationMsg()
	player_operaction:ParseFromString(data)
    print("SMTablePart:playerOperation:",player_operaction,bit._and(player_operaction.operation,MahjongOperation.BU_GANG))
	local cur_seat_id = player_operaction.player_table_pos
	local cur_view_id = self:changeSeatToView(cur_seat_id)

	if player_operaction.operation == RoomConfig.MAHJONG_OPERTAION_POP_LAST then --刷新左上角的尾牌
		local cur_seat_id = player_operaction.player_table_pos
		local cur_view_id = self:changeSeatToView(cur_seat_id)
		local card_data = {mcard={},ocard=player_operaction.card_value}
		card_part:optCard(cur_view_id,RoomConfig.MAHJONG_OPERTAION_POP_LAST,card_data)
    elseif player_operaction.operation == 0x5C000000 then -- MAHJONG_OPERTAION_NOTIFY_LOOK_HUA =0x5C000000;//通知客户端要看花牌
	    local checkhua_part =self:getPart("CheckHuaPart")
        if player_operaction~= nil then
            checkhua_part:activate(player_operaction,self.nameList)
        end

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
			card_data = {mcard={RoomConfig.EmptyCard,RoomConfig.EmptyCard,RoomConfig.EmptyCard,card[4]}}
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

    --elseif bit._and(player_operaction.operation,MahjongOperation.JIN_KAN) == MahjongOperation.JIN_KAN then
    elseif bit._and(player_operaction.operation,0x40) == 0x40 then  -- 因为部分手机无法读取到金坎配置 才把类型写死

        local opvalue = player_operaction.opValue
        local c1 = bit._and(opvalue,0xff)
		local c2 = bit._and(bit.rshift(opvalue,8),0xff)
        local card_value = player_operaction.card_value
        local cur_seat_id = player_operaction.player_table_pos
		local cur_view_id = self:changeSeatToView(cur_seat_id)
        local card_data = {mcard={c1,c2}}
		
        -- card_part:optCard(cur_view_id,RoomConfig.MAHJONG_OPERTAION_JIN_KAN,card_data) -- 因为部分手机无法读取到金坎配置 才把类型写死
        card_part:optCard(cur_view_id,0x40,card_data)


	elseif bit._and(player_operaction.operation,MahjongOperation.BU_HUA) == MahjongOperation.BU_HUA then ------补花
		print("my_seat_id, player_table_pos card_value: ", self.m_seat_id, cur_seat_id, player_operaction.card_value)
		if cur_seat_id == self.m_seat_id then
            if player_operaction.opValue == 1 and player_operaction.card_value > 0 then 
                 table.insert(player_operaction.handCards,player_operaction.card_value)              
            end
             card_part:refreshMyCard(player_operaction.handCards,player_operaction.downCards,player_operaction.beforeCards)
		else
			local cur_seat_id = player_operaction.player_table_pos
			local cur_view_id = self:changeSeatToView(cur_seat_id)
			card_part:resetOutCard(cur_view_id, player_operaction.beforeCards)
		end
        card_part:optCard(cur_view_id,RoomConfig.BuHua,card_data)
    
    end
end


function SMTablePart:operationHu(data)
	-- body
	--print("gffffffffffffffffffffffffffffffffff");
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
		if temp > 0 then
			table.insert(m_table,temp)
			checkMa(i+1)
		else
			card_part:showHuAnimate(view_id,m_table, data.use_xiaoji)
			card_part:showHuCardSp(view_id,hu_card)
		end
	end
	checkMa(0)

end

function SMTablePart:gameEnd(data)
	-- body
	local game_end = self:getPart("GameEndPart")
	local card_part =self:getPart("CardPart")
	local gps_part = self:getPart("GpsPart")

	local newData = {};
	newData.data = data;
	newData.baocard = card_part.view.baocard1;
	-- newData.hostid = bit._and(bit.rshift(data.baocard, 16),0xff);
	-- newData.payway = bit._and(bit.rshift(data.baocard, 24),0xff);
	-- print("游戏结束: ", newData.hostid, newData.payway);
	self.view:hideMenu()
	if game_end then
		-- game_end:activate(data , self.m_seat_id, card_part.view.baocard1)
		game_end:activate(newData , self.m_seat_id)
	end

	if card_part then
		card_part:deactivate()
	end

	if self.smalluserinfo_part then
		self.smalluserinfo_part:deactivate()
	end

	if gps_part then
		gps_part:deactivate()
	end
end

-- function SMTablePart:operationTip(data)
-- 	-- body
-- 	self.last_card_num = data.cardleftnum
-- 	self.view:updateLastCardNum(self.last_card_num)
-- 	local card_part = self:getPart("CardPart")
-- 	if card_part then
-- 		-- local cur_view_id = self:changeSeatToView(data.playertablepos)
-- 		-- card_part:turnSeat(cur_view_id)
-- 		card_part:turnSeat(data.playertablepos)
-- 	end
-- end

--更新玩家属性
function SMTablePart:doUpdatePlayerProperty(data,appId)
	local player_property = ycmj_message_add_pb.UpdatePlayerPropertyMsg()
	player_property:ParseFromString(data)
	print("this is update player property :", player_property)

	local user = global:getGameUser()
	local player_info = user:getProp("gameplayer" .. SocketConfig.GAME_ID)

	player_info.gold = player_property.gold
	player_info.diamond = player_property.diamond
	
	user:setProp("gameplayer" .. SocketConfig.GAME_ID,player_info)
end

function SMTablePart:changeViewToSeat(seatId)
	-- body
	if self.m_seat_id then
		-- print("计算结果", seatId, self.m_seat_id, (self.m_seat_id - seatId + 4)%4 + 1);
		return (seatId + self.m_seat_id + 2)%4 + 1
	end
end

function SMTablePart:operationTipCardYJ(ntf_operation)
	local card_part = self:getPart("CardPart")
	if card_part then
		card_part:showTipCardYJ(ntf_operation.targetcard);
	end
end

function SMTablePart:operationTipCardJK(data)
	local card_part = self:getPart("CardPart")
	-- card_part:addOpt(MahjongOperation.JIN_KAN)  -- 因为部分手机无法读取到金坎配置 才把类型写死
    card_part:addOpt(0x40)
    card_part:showAddOpt(data.pengcardvalue,true)

end

-- 规则
function SMTablePart:showHelpInfo()
	local room_rule_part = self:getPart("RoomRulePart")
	room_rule_part:activate(self.quannum, self.quanTotal)
end



return SMTablePart