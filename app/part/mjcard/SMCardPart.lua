local CURRENT_MODULE_NAME = ...
local CardPart = import(".CardPart")
local SMCardPart = class("SMCardPart",CardPart)
SMCardPart.DEFAULT_VIEW = "SMCardLayer"

SMCardPart.DEFAULT_PART = {
	"CardOptPart",
    'BroadcastPart',--加入小喇叭节点
    "CheckHuaPart",
}

--����ģ�� --CardPart初始化
function SMCardPart:activate(data)
	 CardPart.super.activate(self, CURRENT_MODULE_NAME)
	-- local card_data = self:createDebugData()
	-- for i,v in ipairs(cardData) do
	-- 	if v.view_id == 1 then
	-- 		self.card_list = v.value
	-- 	end
	-- end
	self.handCardNum = 13;
	self.opt_list = {}
	self.m_seat_id = data.mtablePos
	self.card_list = data.mcards.cardvalue
	self.mo_card = false

    


    -- 根据游戏的不同设置不同的手牌数量
    -- 三明13张
    if bit._and(globlerule, bit.lshift(1, 24)) ~= 0 then
        self.handCardNum = 13
    end

    -- 大田麻将
    if bit._and(globlerule, bit.lshift(1, 25)) ~= 0 then
        self.handCardNum = 16
    end

    -- 三明16张
    if bit._and(globlerule, bit.lshift(1, 26)) ~= 0 then
        self.handCardNum = 16
    end

	local card_data =  { --自己初始的牌由data.mcards.cardvalue决定，其他人的默认RoomConfig.HandCardNum 13 张
					 {view_id = 1,num = #data.mcards.cardvalue,value=data.mcards.cardvalue},
					 {view_id = 2,num = self.handCardNum,value={}},
					 {view_id = 3,num = self.handCardNum,value={}},
					 {view_id = 4,num = self.handCardNum,value={}},
					}

	self:handlePlayerCard(card_data);
	self.out_card_list = data.playercard  --�Ѿ������� 玩家已经出了的牌
	self.hu_card_list = data.playerhucards --������ 玩家胡的牌
	self.down_card_list = data.playerdowncards --�����ܵ��� 玩家吃/碰/杠的牌  
	local cur_seat_id = data.chucardplayerindex -- 出牌玩家的座位
	local cur_view_id = self:changeSeatToView(cur_seat_id) -- 出牌玩家相对于自己的座位
	
	if data.chucard and data.chucard > 0 then --�����������˳��� -- 当前操作玩家打出的牌，断线重链时此字段有值
		self:outCard(cur_view_id,data.chucard)
	end

	self:turnSeat(cur_view_id,nil,data.playeroperationtime)
	self.view:createCardWithData(card_data)

	--data.baocard = 0x1121 --宝牌测试数据
	self:refreshBaoCardOnPart(data.baocard)

	local down_cards = {}  --处理断线重连，需要展示已经吃杠碰的牌的情况
	local m_view_id = 0
	for i=1,4 do
		local num = 0
		local view_id = self:changeSeatToView(i-1)
		local down_card = data.playerdowncards[i]
		down_cards[view_id] = down_card and down_card.cards or {}
	end
	--print("This is down_card[1]::-----------------------------------------------------------------------------------,",#down_cards[1])
	self:refreshMyCard(data.mcards.cardvalue,down_cards[1],{})
	for i=2,4 do
		local down_card = down_cards[i]
		for _,card in ipairs(down_card) do
			local card_value = card.cardValue
			local c1 = bit._and(card_value,0xff)
			local c2 = bit._and(bit.rshift(card_value,8),0xff)
			local c3 = bit._and(bit.rshift(card_value,16),0xff)
			local card_data = {mcard={c1,c2},ocard=c3}
			self:optCard(i,card.type,card_data,true)
		end
	end

	local out_cards = {}
	for i=1,4 do
		local view_id = self:changeSeatToView(i-1)
		local out_card = data.playercard[i]
		out_cards[view_id] = out_card and out_card.cardvalue or {}
		--print("---------------SMCardPart:activate")
		self.view:resetOutCard(view_id, out_cards[view_id])
	end

    -- 公告
    local broadcast_node = self:getPart("BroadcastPart")
    if broadcast_node then
        broadcast_node:activate(self.view.node.broadcast_node)
        broadcast_node:isShowBroadcastNode(false)
    end

    -- 出牌前胡的处理(天胡、三金倒、抢金等)
	if data.baocard and data.baocard > 0 then
		local huCard = bit._and(bit.rshift(data.baocard,16),0xff)
		if huCard and huCard > 0 then
            -- self.mo_card = true
            if 1 ~= data.chucard then
                self:getHuCard(huCard)
            end
		end
	end
end

--CheckHuaClick
function SMCardPart:CheckHuaClick()
    local type = 0x5C000000  --MSG_GAME_PLAYER_TABLE_OPERATION=  0xc30062 MAHJONG_OPERTAION_NOTIFY_LOOK_HUA =0x5C000000;
	self:requestOpt(type)
end

--查花弹框
function SMCardPart:checkHua(data) 
    print("查花弹框  查花弹框 查花弹框"..data) 
--    for k,v in pairs(data) do 
--        print(k,v)
--    end
    local checkhua_part =self:getPart("CheckHuaPart")
    chahua_part:activate(data)
end
-- 出牌前胡的处理(天胡、三金倒、抢金等)
function SMCardPart:getHuCard(data)
	table.insert(self.card_list,data)
	self.view:getCard(data)
end

--function CardPart:setMoCardState(bState)
--    self.mo_card = bState
--end

function SMCardPart:resetOutCard(viewId,cardList)
	--print("---------------SMCardPart:resetOutCard")
	self.view:resetOutCard(viewId, cardList)
end

function SMCardPart:optCard(viewId,type,value,hideCardOptPart) --执行玩家 viewId 类型 type 的吃杠碰操作 
	-- body
    if type == RoomConfig.Chi or type == RoomConfig.Peng or type == RoomConfig.MingGang then
        self:removeOutCard(self.last_opt_id)
    end

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

	elseif type == RoomConfig.BuGang then
	elseif type == RoomConfig.BuHua  then--补花
	elseif type == RoomConfig.MAHJONG_OPERTAION_POP_LAST then --更新宝牌
		self:refreshBaoCardOnPart(value.ocard)
		return
	end

	--补花判断
	if type ~= RoomConfig.BuHua then
		self.view:optCard(viewId,type,value,self.last_opt_id)
	end

	if hideCardOptPart == nil or hideCardOptPart ~= true then
		local node,pos = self.view:getOptPos(viewId)
		local card_opt_part = self:getPart("CardOptPart") -- 展示碰杠那个字
		card_opt_part:activate(pos,type,node)
	end
	-- self.view:turnSeat(viewId)
	-- self.owner:turnSeat(viewId)
end

-- 处理玩家手牌
function SMCardPart:handlePlayerCard(card_data)
	for i=2,4 do
		local playerInfo = self:getPlayerInfo(i);
		if playerInfo == nil then
			card_data[i].num = 0;
		end
	end
end

--杠牌事件处理
function CardPart:gangClick()
	if self.gang_list then
		self.mo_card = false
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

function SMCardPart:optClick(type)
	-- body
	print("SMCardPart:optClick_type->",type);
	if type == RoomConfig.Chi then
		self:doChiClick()
	elseif type == RoomConfig.Gang then
		self:gangClick()
	else
		self:requestOpt(type)
	end
end


function SMCardPart:ntfGangList(gangList)
	-- body
	self.gang_list = gangList
	self.view:setGangPicState(true)
end

--返回当前选择的牌的值
function SMCardPart:selectGang(value)
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

--���ܹ����� 向服务器发送操作请求
function SMCardPart:requestOpt(type)
	-- body
	if RoomConfig.Ai_Debug then
		local ai_mode = global:getModuleWithId(ModuleDef.AI_MOD)
		ai_mode:requestMOpt(type)
	else
		local player_table_operation = ycmj_message_pb.PlayerTableOperationMsg()
		if type == MahjongOperation.AN_GANG or type == MahjongOperation.BU_GANG or type == MahjongOperation.MING_GANG or type == RoomConfig.Gang then
		   player_table_operation.operation = MahjongOperation.MING_GANG --不管啥杠服务器自己知道是啥杠
		   print("self.server_data_gang->",self.server_data)
		elseif type == RoomConfig.MAHJONG_SAN_JIN_DAO then
            player_table_operation.operation = RoomConfig.MAHJONG_SAN_JIN_DAO
        elseif type == RoomConfig.MAHJONG_QIANG_JIN then
			player_table_operation.operation = RoomConfig.MAHJONG_QIANG_JIN
		-- elseif type == RoomConfig.MAHJONG_DAN_YOU or type == RoomConfig.MAHJONG_SHUANG_YOU or type == RoomConfig.MAHJONG_SAN_YOU then
		-- 	player_table_operation.operation = RoomConfig.MAHJONG_OPERTAION_CANCEL;
			-- return;
		--elseif type == RoomConfig.MAHJONG_OPERTAION_JIN_KAN then 
        elseif type == 0x40 then -- 因为部分手机无法读取到金坎配置 才把类型写死
            --player_table_operation.operation = RoomConfig.MAHJONG_OPERTAION_JIN_KAN
            player_table_operation.operation = 0x40
            print(" operation operation ------jinkan ")
		else
            player_table_operation.operation = type
		end

		-- if type == RoomConfig.MAHJONG_DAN_YOU then
		-- 	print("oooooooooooooooooooooooooooooooooooooooooooo");
		-- end
        if type ~= 0x5C000000 then 
		    player_table_operation.card_value = self.server_data
            player_table_operation.player_table_pos = self.m_seat_id
        end
		local net_mode = global:getModuleWithId(ModuleDef.NET_MOD)

		if SocketConfig.IS_SEQ == false then		
			local buff_str = player_table_operation:SerializeToString()
			local buff_lenth = player_table_operation:ByteSize()
			-- print("操作码： ", player_table_operation.operation);
			net_mode:sendMsg(buff_str,buff_lenth,MsgDef.MSG_PLAYER_OPERATION,SocketConfig.GAME_ID)
		elseif SocketConfig.IS_SEQ == true then
			-- print("操作码： ", player_table_operation.operation);
			net_mode:sendProtoMsgWithSeq(player_table_operation,MsgDef.MSG_PLAYER_OPERATION,SocketConfig.GAME_ID)
		end
	end
	self.server_data = nil
	self.view:setGangPicState(false)
end

function SMCardPart:showHuAnimate(viewId,maList, type)
	local node,pos = self.view:getOptPos(viewId)
	local card_opt_part = self:getPart("CardOptPart") -- 展示碰杠那个字
	-- print(node, pos, debug.traceback());
	card_opt_part:activate(pos,type,node)

	print("showHuAnimate dddddddddffffffffff", type);
	if type == RoomConfig.MAHJONG_OPERTAION_HU  then
        self.view:showHuAnimate(viewId,maList)
	end
end

function SMCardPart:changeViewToSeat(seatId)
	-- body
	if self.m_seat_id then
		-- print("计算结果", seatId, self.m_seat_id, (self.m_seat_id - seatId + 4)%4 + 1);
		return (seatId + self.m_seat_id + 2)%4 + 1
	end
end

-- 显示游金的提示牌
function SMCardPart:showTipCardYJ(cardvalue)
	self.view:showTipCardYJ(cardvalue);
end

-- 规则
function SMCardPart:showHelpInfo()
	-- local room_rule_part = self:getPart("RoomRulePart") -- 展示碰杠那个字
	-- room_rule_part:activate()
	self.owner:showHelpInfo();
end

-- 规则
function SMCardPart:showHelpInfoBtn()
	self.view:showHelpInfoBtn();
end

return SMCardPart
