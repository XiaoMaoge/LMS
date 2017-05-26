local CURRENT_MODULE_NAME = ...
local TablePart = import(".TablePart")
local LYTablePart = class("LYTablePart",TablePart)
LYTablePart.DEFAULT_VIEW = "LYTableScene"

--自己摸了一张牌
function LYTablePart:operationChu(data)
	-- body
	local card_part = self:getPart("CardPart")
	if data.chicardvalue ~= 0 then --是否摸了新牌，如果是断线回来，这个通知里面没有新牌
		card_part:getCard(data.chicardvalue)
	end

	print("LYTablePart:operationChu", data)

	local opt_type = nil
	local dis_play_guo = false --是否显示过牌	
	local card_value = {}

	--如果玩家听牌
	if bit._and(data.operation,RoomConfig.MAHJONG_OPERTAION_HU) == RoomConfig.MAHJONG_OPERTAION_HU then
		opt_type = RoomConfig.MAHJONG_OPERTAION_HU
		card_value.mcard = {}
		card_part:addOpt(RoomConfig.MAHJONG_OPERTAION_HU)
		dis_play_guo = true;
	end


	if bit._and(data.operation,MahjongOperation.GANG) == MahjongOperation.GANG 
		or bit._and(data.operation,MahjongOperation.AN_GANG) == MahjongOperation.AN_GANG
		or bit._and(data.operation,MahjongOperation.BU_GANG) == MahjongOperation.BU_GANG then
		opt_type = RoomConfig.Gang
		local card_data = data.gangList
		dis_play_guo = true;
		card_part:addOpt(RoomConfig.Gang)
  		card_part:ntfGangList(card_data)
	end

	if bit._and(data.operation,MahjongOperation.CHA_PAI) == MahjongOperation.CHA_PAI then
		opt_type = RoomConfig.MAHJONG_CHA_PAI
		card_part:setChalist(data.tinglist)			
		card_part:addOpt(RoomConfig.MAHJONG_CHA_PAI)
		dis_play_guo = true;
	end

	if bit._and(data.operation,MahjongOperation.DAN_YOU) == MahjongOperation.DAN_YOU then
		opt_type = RoomConfig.MAHJONG_DAN_YOU
		card_part:setDanyoulist(data.tinglist)
		card_part:addOpt(RoomConfig.MAHJONG_DAN_YOU)
		dis_play_guo = true;
		print("LYTablePart:operationChu danyou")
	end

	if bit._and(data.operation,MahjongOperation.SHUANG_YOU) == MahjongOperation.SHUANG_YOU then
		opt_type = RoomConfig.MAHJONG_SHUANG_YOU
		card_part:addOpt(RoomConfig.MAHJONG_SHUANG_YOU)
		dis_play_guo = true;
	end

	if bit._and(data.operation,MahjongOperation.SAN_YOU) == MahjongOperation.SAN_YOU then
		opt_type = RoomConfig.MAHJONG_SAN_YOU
		card_part:addOpt(RoomConfig.MAHJONG_SAN_YOU)
		dis_play_guo = true;
	end

	if bit._and(data.operation,MahjongOperation.CHA_HUA) == MahjongOperation.CHA_HUA then
		opt_type = RoomConfig.MAHJONG_CHA_HUA
		card_part:addOpt(RoomConfig.MAHJONG_CHA_HUA)
		dis_play_guo = true;
	end

	if bit._and(data.operation,RoomConfig.MAHJONG_QIANG_JIN) == RoomConfig.MAHJONG_QIANG_JIN then
		opt_type = RoomConfig.MAHJONG_QIANG_JIN
		dis_play_guo = true;
		card_part:addOpt(RoomConfig.MAHJONG_QIANG_JIN)
	end

	if bit._and(data.operation,RoomConfig.MAHJONG_SAN_JIN_DAO) == RoomConfig.MAHJONG_SAN_JIN_DAO then
		opt_type = RoomConfig.MAHJONG_SAN_JIN_DAO
		dis_play_guo = true;
		card_part:addOpt(RoomConfig.MAHJONG_SAN_JIN_DAO)
	end

	if bit._and(data.operation,RoomConfig.MAHJONG_SI_JIN_DAO) == RoomConfig.MAHJONG_SI_JIN_DAO then
		opt_type = RoomConfig.MAHJONG_SI_JIN_DAO
		dis_play_guo = true;
		card_part:addOpt(RoomConfig.MAHJONG_SI_JIN_DAO)
	end

	if bit._and(data.operation,RoomConfig.MAHJONG_WU_JIN_DAO) == RoomConfig.MAHJONG_WU_JIN_DAO then
		opt_type = RoomConfig.MAHJONG_WU_JIN_DAO
		dis_play_guo = true;
		card_part:addOpt(RoomConfig.MAHJONG_WU_JIN_DAO)
	end

	if bit._and(data.operation,RoomConfig.MAHJONG_LIU_JIN_DAO) == RoomConfig.MAHJONG_LIU_JIN_DAO then
		opt_type = RoomConfig.MAHJONG_LIU_JIN_DAO
		dis_play_guo = true;
		card_part:addOpt(RoomConfig.MAHJONG_LIU_JIN_DAO)
	end

	print("LYTablePart:operationChu opt_type = ", opt_type)
	if opt_type then
		card_part:showAddOpt(data.pengcardvalue,dis_play_guo) --自己摸牌不显示过
	end
end




function LYTablePart:operationCard(data)
	-- body
	local card_part = self:getPart("CardPart")
	local dis_play_guo = true --是否显示过牌
	print("This is LYTablePart operationCard:", data)

	if bit._and(data.operation,RoomConfig.Gang) == RoomConfig.Gang then
  		local card_data = data.gangList
  		card_part:addOpt(RoomConfig.Gang)
  		card_part:ntfGangList(card_data)  		
	end	

	if bit._and(data.operation,MahjongOperation.PENG) == MahjongOperation.PENG then
		local c1 = bit._and(data.pengcardvalue,0xff)
		local c2 = bit._and(bit.rshift(data.pengcardvalue,8),0xff)
		local cur_seat_id = data.playertablepos
		local cur_view_id = self:changeSeatToView(cur_seat_id)
		local card_data = {mcard={c1,c2},ocard=c1}
		-- card_part:ntfOpt(RoomConfig.Peng,card_data,data.pengcardvalue)
		card_part:addOpt(RoomConfig.Peng)

		if bit._and(data.operation,RoomConfig.MAHJONG_OPERTAION_CHU) ~= RoomConfig.MAHJONG_OPERTAION_CHU then
			card_part:set_card_touch_enable(false)
		end
	end

	if bit._and(data.operation,MahjongOperation.CHI) == MahjongOperation.CHI then
		card_part:setChiList(data.chicardvalue,data.targetcard)
		card_part:addOpt(RoomConfig.Chi)
	end

	if bit._and(data.operation,MahjongOperation.QIANG_JIN) == MahjongOperation.QIANG_JIN then
		card_part:addOpt(MahjongOperation.QIANG_JIN)
	end

	if bit._and(data.operation,MahjongOperation.HU) == MahjongOperation.HU then
		card_part:addOpt(MahjongOperation.HU)
	end


	if bit._and(data.operation,MahjongOperation.CHA_PAI) == MahjongOperation.CHA_PAI then
		local cur_seat_id = data.playertablepos
		local cur_view_id = self:changeSeatToView(cur_seat_id)
		print("cha_pai: data.playertablepos, data.targetcard, cur_view_id: ", data.playertablepos, data.targetcard, cur_view_id)
		if RoomConfig.MySeat == cur_view_id then 
			card_part:addOpt(MahjongOperation.CHA_PAI)
		else
			card_part:showChaPai(data.targetcard)
		end

		return
	end

	if bit._and(data.operation,MahjongOperation.CHA_HUA) == MahjongOperation.CHA_HUA then
		local cur_seat_id = data.playertablepos
		local cur_view_id = self:changeSeatToView(cur_seat_id)
		if RoomConfig.MySeat == cur_view_id then 
			card_part:addOpt(MahjongOperation.CHA_HUA)
		else
			card_part:showChaPai(data.targetcard)
		end

		return
	end

	if bit._and(data.operation,RoomConfig.MAHJONG_JIN_PAI) == RoomConfig.MAHJONG_JIN_PAI then
		--显示金牌
		print("operationCard MAHJONG_JIN_PAI", data.targetcard)

		local cur_seat_id = data.playertablepos
		local cur_view_id = self:changeSeatToView(cur_seat_id)
		local card_data = {mcard={},ocard=data.targetcard}
		--card_part:ntfOpt(RoomConfig.MAHJONG_JIN_PAI,card_data,data.targetcard)
		card_part:refreshBaoCardOnPart(data.targetcard)
		dis_play_guo = false --金牌不显示过 
		
		return
	end

	card_part:showAddOpt(data.pengcardvalue,dis_play_guo)

	if bit._and(data.operation,RoomConfig.Gang) == RoomConfig.Gang then
  		if bit._and(data.operation,RoomConfig.MAHJONG_OPERTAION_CHU) ~= RoomConfig.MAHJONG_OPERTAION_CHU  then
  			card_part:set_card_touch_enable(false)
  		end  		
	end	

	if bit._and(data.operation,MahjongOperation.PENG) == MahjongOperation.PENG or bit._and(data.operation,RoomConfig.MAHJONG_OPERTAION_HU) == RoomConfig.MAHJONG_OPERTAION_HU then
		if bit._and(data.operation,RoomConfig.MAHJONG_OPERTAION_CHU) ~= RoomConfig.MAHJONG_OPERTAION_CHU then
			card_part:set_card_touch_enable(false)
		end
	end
end

function LYTablePart:operationNotifyCha(data)
	print("operationNotifyCha", data);
    local view_pos = self:changeSeatToView(data.playertablepos)
    self.view:chaPlayer(view_pos, true)
end

function LYTablePart:startGame(data)
	-- body
	local chat_part = self:getPart("ChatPart")
    if chat_part then
    	local pos_table = self.view:getPosTable()
		chat_part:activate(pos_table)
		chat_part:hideSzBtn()
    end

	local card_part = self:getPart("CardPart")
    card_part:activate(data)
    card_part:hideChaPai()

    if data.tingplayers ~= nil then
    	for j = 1, 4 do
    		local cha = bit._and(bit.rshift(data.tingplayers,(j-1)*8),0xff)
    		local show = (cha == 1)
    		local view_pos = self:changeSeatToView(j)
    		self.view:chaPlayer(view_pos, show)
    	end
    end
    
    if self.tableid > 1 then ----显示当前局数和总局数  1/4局
    	local quanTotal = bit._and(data.serviceGold,0xff)
    	self.view:dispalyQuan(data.quannum,quanTotal)
    end

	self.last_card_num = 0
	self.m_seat_id = data.mtablePos
	self.view:initTableWithData(self.player_list,data)
end

function LYTablePart:doNtfOperation(data,appId)
	-- body
	local ntf_operation = ycmj_message_pb.PlayerOperationNotifyMsg()
	ntf_operation:ParseFromString(data)
	--if(ntf_operation.operation > 0x8000000) then
	--	ntf_operation.operation = 0x8000000
	--end

	print("LYTablePart this is  ntf_operation:",os.date(),ntf_operation)
	if ntf_operation.operation == MahjongOperation.GAME_OVER then --游戏结束
	elseif ntf_operation.operation == MahjongOperation.OFFLINE then --玩家离线
		self:operationOffline(ntf_operation)
	elseif ntf_operation.operation == MahjongOperation.NOTIFY_CHA then --玩家查牌
		self:operationNotifyCha(ntf_operation)
	elseif ntf_operation.operation == MahjongOperation.HU_CARD_LIST_UPDATE then --提醒玩家可以胡的牌
		self:updateHuCard(ntf_operation)
	elseif ntf_operation.operation == MahjongOperation.ONLINE then --下线后又上线
        self:operationOffline(ntf_operation)
	elseif ntf_operation.operation == MahjongOperation.REMOE_CHU_CARD then --玩家打出的牌，被吃碰杠走了
		self:removeOutCard(ntf_operation)
	elseif ntf_operation.operation == MahjongOperation.OVERTIME_AUTO_CHU then --超时自动出牌
		self:autoOutCard(ntf_operation)		
	elseif bit._and(ntf_operation.operation,MahjongOperation.CHU) == MahjongOperation.CHU then --轮到玩家出牌
		self:operationChu(ntf_operation)
	elseif bit._and(ntf_operation.operation,MahjongOperation.CHI) == MahjongOperation.CHI 
		or bit._and(ntf_operation.operation,MahjongOperation.PENG) == MahjongOperation.PENG 
		or bit._and(ntf_operation.operation,MahjongOperation.AN_GANG) == MahjongOperation.AN_GANG 
		or bit._and(ntf_operation.operation,MahjongOperation.MING_GANG) == MahjongOperation.MING_GANG 
		or bit._and(ntf_operation.operation,MahjongOperation.GANG) == MahjongOperation.GANG  --服务器通知轮到玩家吃牌血流杠会冲突
		or bit._and(ntf_operation.operation,MahjongOperation.BU_GANG) == MahjongOperation.BU_GANG then

		self:operationCard(ntf_operation)
	elseif ntf_operation.operation == MahjongOperation.HU then
		self:operationCard(ntf_operation)
	elseif ntf_operation.operation == MahjongOperation.ADD_CHU_CARD then --玩家出牌结束，牌没有被吃碰杠
		self:addOutCard(ntf_operation)
	elseif ntf_operation.operation == MahjongOperation.TIP then --提示当前谁在操作
		self:operationTip(ntf_operation)
	elseif ntf_operation.operation == MahjongOperation.CANCEL then --吃碰听超时
	elseif ntf_operation.operation == MahjongOperation.WAITING_OR_CLOSE_VIP then --提醒玩家有人掉线是否等待
	elseif ntf_operation.operation == MahjongOperation.NO_START_CLOSE_VIP then -- VIP房间超时未开始游戏，房间结束
	elseif ntf_operation.operation == MahjongOperation.PLAYER_HU_CONFIRMED then --玩家胡
		self:operationHu(ntf_operation)
	elseif bit._and(ntf_operation.operation,MahjongOperation.JIN_PAI) == MahjongOperation.JIN_PAI then
		--提示金牌
		self:operationCard(ntf_operation)
	elseif bit._and(ntf_operation.operation,MahjongOperation.CHA_PAI) == MahjongOperation.CHA_PAI then
		--提示查牌
		self:operationCard(ntf_operation)
	elseif bit._and(ntf_operation.operation,MahjongOperation.CHA_HUA) == MahjongOperation.CHA_HUA then
		--提示查花
		self:operationCard(ntf_operation)
	elseif bit._and(ntf_operation.operation,MahjongOperation.QIANG_JIN) == MahjongOperation.QIANG_JIN then
		--提示抢金
		self:operationCard(ntf_operation)
	end
end

function LYTablePart:doPlayerOperation(data,appId)
	-- body
	local card_part = self:getPart("CardPart")
	local player_operaction = ycmj_message_pb.PlayerTableOperationMsg()
	player_operaction:ParseFromString(data)
    print("LYTablePart:playerOperation:",player_operaction,bit._and(player_operaction.operation,MahjongOperation.BU_GANG))
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
			if player_operaction.use_xiaoji == 1 then				
				card_part:showOutCard(cur_view_id, card_value)
			else
				card_part:showAutoOutCard(card_value) --托管需要出牌
			end
			card_part:refreshMyCard(player_operaction.handCards,player_operaction.downCards,player_operaction.beforeCards)
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
			--if cur_seat_id == self.m_seat_id then --我自己可以看见第二张牌
				card_data = {mcard= {RoomConfig.EmptyCard,RoomConfig.EmptyCard,RoomConfig.EmptyCard,card[4]}}
			--end
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
	elseif bit._and(player_operaction.operation,RoomConfig.MAHJONG_JIN_PAI) == RoomConfig.MAHJONG_JIN_PAI then
		--显示金牌
		print("MAHJONG_JIN_PAI opValue card_value:", player_operaction.opValue, player_operaction.card_value)

		local cur_seat_id = player_operaction.player_table_pos
		local cur_view_id = self:changeSeatToView(cur_seat_id)
		local card_data = {mcard={},ocard=player_operaction.opValue}
		--card_part:ntfOpt(RoomConfig.MAHJONG_JIN_PAI,card_data,player_operaction.targetcard)
		card_part:refreshBaoCardOnPart(player_operaction.opValue)
		card_part:refreshMyCard(player_operaction.handCards,player_operaction.downCards,player_operaction.beforeCards)
	elseif bit._and(player_operaction.operation,MahjongOperation.BU_HUA) == MahjongOperation.BU_HUA then --补花
		print("my_seat_id, player_table_pos card_value: ", self.m_seat_id, cur_seat_id, player_operaction.card_value)
		card_part:optCard(cur_view_id,RoomConfig.BuHua,card_data)
		if cur_seat_id == self.m_seat_id then
			card_part:refreshMyCard(player_operaction.handCards,player_operaction.downCards,player_operaction.beforeCards)
		else
			local cur_seat_id = player_operaction.player_table_pos
			local cur_view_id = self:changeSeatToView(cur_seat_id)

			--for i,v in ipairs(player_operaction.beforeCards) do
			--	card_part:showOutCard(cur_view_id,v)
			--end
			card_part:resetOutCard(cur_view_id, player_operaction.beforeCards)
		end
		
	end
end

--更新玩家属性
function LYTablePart:doUpdatePlayerProperty(data,appId)
	local player_property = ycmj_message_add_pb.UpdatePlayerPropertyMsg()
	player_property:ParseFromString(data)
	print("this is update player property :", player_property)

	local user = global:getGameUser()
	local player_info = user:getProp("gameplayer" .. SocketConfig.GAME_ID)

	player_info.gold = player_property.gold
	player_info.diamond = player_property.diamond
	
	user:setProp("gameplayer" .. SocketConfig.GAME_ID,player_info)
end

function LYTablePart:operationHu(data)
	-- body
	print("LYTablePart:operationHu: ", data)
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
			local huType = nil
			if bit._and(data.use_xiaoji, RoomConfig.LONG_YAN_LIU_JIN_DAO) == RoomConfig.LONG_YAN_LIU_JIN_DAO then
				huType = RoomConfig.MAHJONG_LIU_JIN_DAO
			elseif bit._and(data.use_xiaoji, RoomConfig.LONG_YAN_WU_JIN_DAO) == RoomConfig.LONG_YAN_WU_JIN_DAO then
				huType = RoomConfig.MAHJONG_WU_JIN_DAO
			elseif bit._and(data.use_xiaoji, RoomConfig.LONG_YAN_SI_JIN_DAO) == RoomConfig.LONG_YAN_SI_JIN_DAO then
				huType = RoomConfig.MAHJONG_SI_JIN_DAO
			elseif bit._and(data.use_xiaoji, RoomConfig.LONG_YAN_SAN_JIN_DAO) == RoomConfig.LONG_YAN_SAN_JIN_DAO then
				huType = RoomConfig.MAHJONG_SAN_JIN_DAO
			elseif bit._and(data.use_xiaoji, RoomConfig.LONG_YAN_SAN_YOU) == RoomConfig.LONG_YAN_SAN_YOU then
				huType = RoomConfig.MAHJONG_SAN_YOU
			elseif bit._and(data.use_xiaoji, RoomConfig.LONG_YAN_SHUANG_YOU) == RoomConfig.LONG_YAN_SHUANG_YOU then
				huType = RoomConfig.MAHJONG_SHUANG_YOU
			elseif bit._and(data.use_xiaoji, RoomConfig.LONG_YAN_DAN_YOU) == RoomConfig.LONG_YAN_DAN_YOU then
				huType = RoomConfig.MAHJONG_DAN_YOU
			end

			card_part:showHuAnimate(view_id,m_table, huType)
			--card_part:showOutCard(view_id,hu_card) --胡牌的时候，不需要再出 胡的牌
		end
	end
	checkMa(0)

end

return LYTablePart