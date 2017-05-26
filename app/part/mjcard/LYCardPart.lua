local CURRENT_MODULE_NAME = ...
local CardPart = import(".CardPart")
local LYCardPart = class("LYCardPart",CardPart)
LYCardPart.DEFAULT_VIEW = "LYCardLayer"

--杠牌事件处理
function LYCardPart:gangClick()
	-- body
	-- self.gang_data = {
	-- 	0x31323231,0x33333331,0x34343431,0x32323231,0x33333333
	-- }
	if self.gang_list then
		local size = #self.gang_list
		if size == 1 then --只有一个直接杠
			self.server_data =  self.gang_list[1].cardValue
			self:requestOpt(MahjongOperation.MING_GANG)
			self.view:hideOpt()
		elseif size > 1 and size <= 4 then --可以杠的列表小于等于4直接列出杠的情况 
			self.view:showGangList(self.gang_list) --列出刚的相信列表
		else
			local gang_list = {}
			local gang_list1 = {}
			for i,v in ipairs(self.gang_list) do
				local c1 = bit._and(v.cardValue,0xff)
				gang_list[c1] = v --以值为索引防止重复
			end

			for k,v in pairs(gang_list) do
				table.insert(gang_list1,v)
			end

			self.view:showGangSelect(gang_list1) --列出杠的选择列表
		end
	end
end

function LYCardPart:optClick(type)
	-- body
	print("LYCardPart:optClick_type->",type);
	if type == RoomConfig.Chi then
		self:doChiClick()
	elseif type == RoomConfig.Gang then
		self:gangClick()
	elseif type == RoomConfig.MAHJONG_CHA_PAI then
		self:doChaClick()
	elseif type == RoomConfig.MAHJONG_DAN_YOU then
		self:doDanyouClick()
		self.mo_card = false
	elseif type == RoomConfig.MAHJONG_SHUANG_YOU then
		self:doShuangyouClick()
		self.mo_card = false
	elseif type == RoomConfig.MAHJONG_SAN_YOU then
		self:doSanyouClick()
		self.mo_card = false	
	else
		if self.cha_data ~= nil and type ~= RoomConfig.MAHJONG_CHA_PAI then
			self.cha_data = nil
			if type ==  RoomConfig.MAHJONG_OPERTAION_CANCEL then
				self.view:set_card_touch_enable(true)
				return
			end
		end

		if self.danyou_data ~= nil and type ~= RoomConfig.MAHJONG_DAN_YOU then
			self.danyou_data = nil
			if type ==  RoomConfig.MAHJONG_OPERTAION_CANCEL then
				self.view:set_card_touch_enable(true)
				return
			end			
		end

		self:requestOpt(type)
	end
end

--点击查牌后，事件进入这里的处理
function LYCardPart:doChaClick()
	local cha_list = self.cha_data
    --存在多个牌时，不能直接点查
    local count = #cha_list;
    
    print("doChaClick cha_count_total = ",count)
  
  	if count == 1 then
	    self.server_data = cha_list[1]
	    self.view:hideOpt()
	    self.view:set_card_touch_enable(false)
	    self.view:outCard(RoomConfig.MySeat, self.server_data)
	    self:requestOpt(RoomConfig.MAHJONG_CHA_PAI)
    else
    	--进入查牌状态
    	self.view:set_card_touch_enable(true)
    	print("self.cha_state = true")
    	self.cha_state = true

    	for k, v in ipairs(cha_list) do
    	--	self.view:standHandCardByValue(v)
    	end
    end

    self.cha_data = nil
end

--点击游金后，事件进入这里的处理
function LYCardPart:doDanyouClick()
	local danyou_list = self.danyou_data
    --存在多个牌时，不能直接点游金
    local count = #danyou_list;
    
    print("doDanyouClick danyou_count_total = ",count)
  
  	if count >= 1 then
	    self.server_data = danyou_list[1]
	    self.view:hideOpt()
	    self.view:set_card_touch_enable(false)
	    self.view:outCard(RoomConfig.MySeat, self.server_data)
	    self:requestOpt(RoomConfig.MAHJONG_DAN_YOU)
    else
    	--进入游金状态
    	self.view:set_card_touch_enable(true)
    	print("self.danyou_state = true")
    	self.danyou_state = true

    	-- for k, v in ipairs(cha_list) do
    	-- 	--self.view:standHandCardByValue(v)
    	-- end
    end

    self.danyou_data = nil
end

--点击三游后，事件进入这里的处理
function LYCardPart:doSanyouClick()
    print("doSanyouClick")  
  	self.view:hideOpt()
	self.view:set_card_touch_enable(false)
	self.view:outCard(RoomConfig.MySeat, self.server_data)
	self:requestOpt(RoomConfig.MAHJONG_SAN_YOU)
end

--点击双游后，事件进入这里的处理
function LYCardPart:doShuangyouClick()
    print("doShuangyouClick")  
  	self.view:hideOpt()
	self.view:set_card_touch_enable(false)
	self.view:outCard(RoomConfig.MySeat, self.server_data)
	self:requestOpt(RoomConfig.MAHJONG_SHUANG_YOU)
end

function LYCardPart:set_card_touch_enable(enable)
	self.view:set_card_touch_enable(false)
end

function LYCardPart:setChalist(chalist)
	-- body
	print("LYCardPart:setChalist ", chalist)
	self.cha_data = chalist	
end

function LYCardPart:setDanyoulist(danyoulist)
	-- body
	print("LYCardPart:setDanyoulist ", danyoulist)
	self.danyou_data = danyoulist	
end

function LYCardPart:ntfGangList(gangList)
	-- body
	self.gang_list = gangList
	self.view:setGangPicState(true)
end

--返回当前选择的牌的值
function LYCardPart:selectGang(value)
	-- body
	local gang_list = {}
	for i,v in ipairs(self.gang_data) do
		local c1 = bit._and(v,0xff)
		print("this is select gang:",c1,value)
		if c1 == value then
			table.insert(gang_list,v)
		end
	end
	
	if #gang_list == 1 then
		self:requestOpt(MahjongOperation.MING_GANG)
	else
		self.view:showGangList(gang_list)
	end
	
end

function LYCardPart:getCard(data, force) --摸牌 数据和UI处理
	-- body
	print("LYCardPart:getCard self.mo_card, force", self.mo_card, force)
	if self.mo_card == false or force == true then
		self:removeOutCard(RoomConfig.MySeat)
		table.insert(self.card_list,data)
		if force == nil then
			self.mo_card = true
		end
		print("LYCardPart:getCard ", self.mo_card)
		self.view:getCard(data)
	end
end

function LYCardPart:showChaPai(card)
	print("LYCardPart:showChaPai card = ", card)
	self.view:showChaPai(card)
end

function LYCardPart:hideChaPai()
	self.view:hideChaPai()
end


--���ܹ����� 向服务器发送操作请求
function LYCardPart:requestOpt(type)
	-- body
	if RoomConfig.Ai_Debug then
		local ai_mode = global:getModuleWithId(ModuleDef.AI_MOD)
		ai_mode:requestMOpt(type)
	else
		local player_table_operation = ycmj_message_pb.PlayerTableOperationMsg()
		if type == MahjongOperation.AN_GANG or type == MahjongOperation.BU_GANG or type == MahjongOperation.MING_GANG or type == RoomConfig.Gang then
		   player_table_operation.operation = MahjongOperation.MING_GANG --不管啥杠服务器自己知道是啥杠
		   print("self.server_data_gang->",self.server_data)
		   self.mo_card = false
		else
            player_table_operation.operation = type
		end

		print("LYCardPart:requestOpt optType, cha_state", type, self.cha_state)
		if self.cha_state ~= nil then
			if type == MahjongOperation.CHU and self.cha_state == true then
				self.cha_state = false
				player_table_operation.operation = MahjongOperation.CHA_PAI
			end
		end

		print("LYCardPart:requestOpt optType, danyou_state", type, self.danyou_state)
		if self.danyou_state ~= nil then
			if type == MahjongOperation.CHU and self.danyou_state == true then
				self.danyou_state = false
				player_table_operation.operation = MahjongOperation.DAN_YOU
			end
		end

		if type == MahjongOperation.QIANG_JIN or type == MahjongOperation.SAN_JIN_DAO or type == MahjongOperation.SI_JIN_DAO
		 or type == MahjongOperation.WU_JIN_DAO  or type == MahjongOperation.LIU_JIN_DAO then
			player_table_operation.operation = MahjongOperation.HU
		end

		player_table_operation.card_value = self.server_data
        player_table_operation.player_table_pos = self.m_seat_id
		local net_mode = global:getModuleWithId(ModuleDef.NET_MOD)
		print("LYCardPart:requestOpt operation",player_table_operation.operation)
		if SocketConfig.IS_SEQ == false then		
			local buff_str = player_table_operation:SerializeToString()
			local buff_lenth = player_table_operation:ByteSize()
			net_mode:sendMsg(buff_str,buff_lenth,MsgDef.MSG_PLAYER_OPERATION,SocketConfig.GAME_ID)
		elseif SocketConfig.IS_SEQ == true then
			net_mode:sendProtoMsgWithSeq(player_table_operation,MsgDef.MSG_PLAYER_OPERATION,SocketConfig.GAME_ID)
		end
	end
	self.server_data = nil
	self.danyou_data = nil
	self.cha_data = nil
	self.view:setGangPicState(false)
end

function LYCardPart:optCard(viewId,type,value,hideCardOptPart) --执行玩家 viewId 类型 type 的吃杠碰操作 
	-- body
	self:removeOutCard(self.last_opt_id)
	if type == RoomConfig.Chi then
	elseif type == RoomConfig.Peng then --����Ҫ���Լ��Ķ���ɾ�������ƣ��ӳ��ƶ�����ɾ��������
		if viewId == RoomConfig.MySeat then
			local card_size = #self.card_list --如果是自己的操作，则从手牌中移除相应的牌
			local to_remove_card = {}
			for j,k in ipairs(value.mcard) do
				for i=card_size,1,-1 do
					if self.card_list[i] == k then
						table.insert(to_remove_card, {idx = i, card = k})
						table.remove(self.card_list,i)
						break
					end
				end
			end
			if #to_remove_card ~= #(value.mcard) then --服务器重复发消息等原因导致手牌中无牌可删除 这里加一个保护
				for k,v in pairs(to_remove_card) do
					table.insert(self.card_list, v.idx, v.card)
				end
				return
			end
		end
		
	elseif type == RoomConfig.AnGang then  --�Լ������ĸ��ǰ���

	elseif type == RoomConfig.MingGang then

	elseif type == RoomConfig.BuHua then
	elseif type == RoomConfig.JinPai then --更新宝牌
		self:refreshBaoCardOnPart(value.ocard)

		self.bao1 = bit._and(value.ocard,0xff);
		self.bao2 = bit._and(bit.rshift(value.ocard,8),0xff)
		return
	end
	if type ~= RoomConfig.BuHua then
		self.view:optCard(viewId,type,value,self.last_opt_id) --UI展示玩家吃,碰,杠
	end
	
	if hideCardOptPart == nil or hideCardOptPart ~= true then
		local node,pos = self.view:getOptPos(viewId)
		local card_opt_part = self:getPart("CardOptPart") -- 展示碰杠补花那个字
		card_opt_part:activate(pos,type,node)
	end
	-- self.view:turnSeat(viewId)
	-- self.owner:turnSeat(viewId)
end

function LYCardPart:requestOutCard(value) --向服务器请求出牌
	-- body
	print("this is send card:",value)
	if RoomConfig.Ai_Debug then
		local ai_mode =global:getModuleWithId(ModuleDef.AI_MOD)
		ai_mode:requestOutCard(value)
	else
		local player_table_operation = ycmj_message_pb.PlayerTableOperationMsg()
		player_table_operation.operation = MahjongOperation.CHU
		player_table_operation.card_value = value
        player_table_operation.player_table_pos = self.m_seat_id
		local net_mode = global:getModuleWithId(ModuleDef.NET_MOD)
		self.mo_card = false

		if self.cha_state ~= nil then
			if self.cha_state == true then
				self.cha_state = false
				player_table_operation.operation = MahjongOperation.CHA_PAI
			end
		end

		if self.danyou_state ~= nil then
			if self.danyou_state == true then
				self.danyou_state = false
				player_table_operation.operation = MahjongOperation.DAN_YOU
			end
		end

		if SocketConfig.IS_SEQ == false then
			local buff_str = player_table_operation:SerializeToString()
			local buff_lenth = player_table_operation:ByteSize()
			net_mode:sendMsg(buff_str,buff_lenth,MsgDef.MSG_PLAYER_OPERATION,SocketConfig.GAME_ID)
		elseif SocketConfig.IS_SEQ == true then
			net_mode:sendProtoMsgWithSeq(player_table_operation,MsgDef.MSG_PLAYER_OPERATION,SocketConfig.GAME_ID)
		end
	end
	self:showOutCard(RoomConfig.MySeat,value)
	self.view:setGangPicState(false)
	self.server_data = nil
	self.danyou_data = nil
	self.cha_data = nil
end

function LYCardPart:resetOutCard(viewId,cardList)
	self.view:resetOutCard(viewId, cardList)
end

function LYCardPart:showHuAnimate(viewId,maList, type)
	if type then
		local node,pos = self.view:getOptPos(viewId)
		local card_opt_part = self:getPart("CardOptPart") -- 展示碰杠那个字
		-- print(node, pos, debug.traceback());
		card_opt_part:activate(pos,type,node)
	else
		self.view:showHuAnimate(viewId,maList)
	end	
end

return LYCardPart
