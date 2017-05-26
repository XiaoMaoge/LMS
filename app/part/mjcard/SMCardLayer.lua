--[[
	云南的打牌界面处理
--]]
require("bit")

local CardLayer = import(".CardLayer")
local SMCardLayer = class("SMCardLayer",CardLayer)

function SMCardLayer:onCreate()
	SMCardLayer.super.onCreate(self)

	self.tipCardYJ = 0
	self.baocard1 = 0
	self.baocard2 = 0
	self.baocard_color = {r = 255, g = 255, b = 0}
	self.handCardNum = 16

    self.fCardScale = 1.0    -- 牌的缩放，当牌为13张的时候会进行牌的缩放操作

    self.bIsSanMingGame = false         -- 是否是三明游戏
    self.fOffsetX = 0                   -- x坐标的偏移量

    local iLeftMoveNum = bit.lshift(1, 24)
    local iGetNum = bit._and(globlerule, iLeftMoveNum)
    if iGetNum ~= 0 then
        self.bIsSanMingGame = true
        self.fOffsetX = 60

        self.node.hcard_node1:setScale(self.fCardScale)
        local pos = cc.p(self.node.hcard_node1:getPosition())
        self.node.hcard_node1:setPosition(pos.x + 75, pos.y)
    else
        self.bIsSanMingGame = false
        self.fOffsetX = 0
    end

	self.timer = nil;

    -- 隐藏胡的特效
    self.node.hu_btn:hide()
    -- 隐藏胡的牌
    self.node.hu_sprite_parent:hide();
	for i = 1, 4 do
		self.node["hu_sprite_" .. i]:hide()
	end

	self:setGangPicState(false)
    -- 防止按钮的特效被释放
    self.node.hu_btn:retain()
    self.node["checkhua_btn"]:show()
end
--点击花牌按钮
function SMCardLayer:CheckHuaClick()
    self.part:CheckHuaClick()
end

--云南杠牌处理
function SMCardLayer:GangPicClick()
	-- body
    self.part:gangClick() --杠的测试
	self:setGangPicState(false)
end

--杠的同牌不同组合 的选择列表
function SMCardLayer:showGangList(gangList)
	--显示可以杠的列表
	self.node.ma_list2:show()
	self.node.ma_list2:removeAllChildren()
	self.node.ma_list2:setItemModel(self.node.ma_panel1)

	local size_x = 0
	local size_y = self.node.ma_list2:getContentSize().height

	for i,v in ipairs(gangList) do
		self.node.ma_list2:insertDefaultItem(i-1)
		local item = self.node.ma_list2:getItem(i-1)
		for j = 1,4 do
			local c1 = bit._and(bit.rshift(v.cardValue,(j-1)*8),0xff)
			local type,value = self.card_factory:decodeValue(c1)
    		local ma = item:getChildByName("ma" .. j)
			local texture_name = string.format("%s/room/resource/mj/mine/M_%s_%d.png",self.res_base, RoomConfig.CardType[type],value)
			ma:loadTexture(texture_name,1)
			size_x = size_x + ma:getContentSize().width
			self:setBaoCard(ma, c1)
		end
		size_x = size_x +5
	end
	size_x = size_x -5
	local size = cc.size(size_x,size_y)
	self.node.ma_list2:setContentSize(size)

	self.node.ma_list2:forceDoLayout()
	self.node.ma_list2:jumpToPercentHorizontal(50)
	self.node.ma_list2:addEventListener(function(ref,event)
		-- body
		if event == 1 then
	
			local select_index = self.node.ma_list2:getCurSelectedIndex()
			--发送请求杠牌
			self:hideOpt()
            self.part.mo_card = false
			self.part:requestOptCard(RoomConfig.Gang,gangList[select_index+1].cardValue)
		end
	end)
end

--杠的不同牌 单个选择列表
function SMCardLayer:showGangSelect(gangList)
	-- body
	self.node.ma_list1:show()
	local size_x = 0
	local size_y = self.node.ma_list1:getContentSize().height
	for i,v in ipairs(gangList) do
		self.node.ma_list1:insertDefaultItem(i-1)
		local item = self.node.ma_list1:getItem(i-1)
		local c1 = bit._and(v,0xff)
		local type,value = self.card_factory:decodeValue(c1)
    	local ma = item:getChildByName("ma1")
    	size_x = size_x + ma:getContentSize().width+3
		local texture_name = string.format("%s/room/resource/mj/mine/M_%s_%d.png",self.res_base, RoomConfig.CardType[type],value)
		ma:loadTexture(texture_name,1)
		self:setBaoCard(ma, c1)
	end

	local size = cc.size(size_x,size_y)
	self.node.ma_list1:setContentSize(size)
	self.node.ma_list1:jumpToPercentHorizontal(50)

	self.node.ma_list1:addEventListener(function(ref,event)
		-- body
		if event == 1 then
			local select_index = self.node.ma_list1:getCurSelectedIndex()
			local c1 = bit._and(gangList[select_index + 1],0xff)
			self.part:selectGang(c1)
		end
	end)
end

--显示碰杠过操作
function SMCardLayer:showOpt(type,value)
	-- body
	self.card_touch_enable  = false
	if type == RoomConfig.MingGang then
		self.node.gang_btn:show()
		self.node.peng_btn:show()
		self.node.guo_btn:show()
	elseif type == RoomConfig.AnGang or type == RoomConfig.BuGang then
		self.node.gang_btn1:show()
		self.node.guo_btn:show()
	elseif type == RoomConfig.Peng then
		self.node.peng_btn:show()
		self.node.guo_btn:show()
	elseif type == RoomConfig.Hu then --胡的显示
	elseif type == RoomConfig.CHI then --吃的显示
		self.node.peng_btn:show()
		self.node.chi_btn:show()
	elseif type == RoomConfig.MAHJONG_OPERTAION_POP_LAST then
		print("self:showSelectBaoCardOnLayer(value.ocard)->",value.ocard)
		self:showSelectBaoCardOnLayer(value.ocard)	
	end

	for i,v in ipairs(self.card_list[RoomConfig.HandCard][RoomConfig.MySeat]) do
		for j,k in ipairs(value.mcard) do
			if v.card_value == k then
				local content_size = v.card_sprite:getContentSize()
				local pos = cc.pAdd(v.card_pos,cc.p(0,content_size.height*self.StandCardOffset))
				v.card_sprite:setPosition(pos)
			end
		end
	end
end

-- 设置宝牌
function SMCardLayer:setBaoCard(card, value)
	if card == nil or value == nil then
		return
	end

	if value == self.baocard1 or value == self.baocard2 then
		card:setColor(self.baocard_color)
	end
end

function SMCardLayer:refreshOtherCard(viewId,cardList)
	-- body
	local card_list = self.card_list[RoomConfig.HandCard][viewId]
	for i,v in ipairs(card_list) do
		v.card_sprite:removeSelf()
	end
	self.card_list[RoomConfig.HandCard][viewId] = {}

	local num = #cardList
	local num1 = self.handCardNum - num --#self.card_list[RoomConfig.DownCard][viewId]
	for i,v in ipairs(cardList) do
		local pos = nil
		local card = self.card_factory:createWithData(viewId,v)
		local size = card:getContentSize()
		size.width = size.width - 2
		size.height = size.height +10
		if viewId == RoomConfig.DownSeat then --下家从上往下列牌
			pos = cc.p(0,(num/2-i-1+num1*0.7)*size.height/2)
		elseif viewId == RoomConfig.FrontSeat then --对家从右到左排列
			size.width = size.width/2
			pos =cc.p((num/2-i+0.5+num1*0.7)*size.width,0)
		elseif viewId == RoomConfig.UpSeat then --上家从下到上排列
			pos = cc.p(0,(i-num/2-2-num1*0.7)*size.height/2)
			card:setLocalZOrder(num - i)
		end
		card:setPosition(pos)
		self.node["hcard_node"..viewId]:addChild(card)
		self:setBaoCard(card, v)

		local card_panel = {
			card_sprite = card,
			card_value = v,
			card_pos = cc.p(card:getPosition())
		}
		table.insert(self.card_list[RoomConfig.HandCard][viewId],card_panel)
	end
end

--玩家牌被吃碰了移除最后出的牌
function SMCardLayer:removeLastCard(lastOpt,value)
	-- body
	if self.last_out_card[lastOpt] then
		self:removeCurOutCard(lastOpt)
	end
    -- 2017-3-19 01:21:08 杠时value发送错误，因此不能移除杠后的桌面上的一张牌
    -- 取出杠的牌值，etc: 如果杠牌的值是0x11 那么value中存放的是 0x11||0x11<<8||0x11<<16
    local iValue = bit._and(value, 0xff)
    local out_card = self.card_list[RoomConfig.OutCard][lastOpt]
    local out_card_size = #out_card
    for i=out_card_size,1,-1 do
    	if out_card[i].card_value == iValue then
            if out_card[i].card_sprite then
                out_card[i].card_sprite:removeSelf()
            end
            table.remove(out_card,i)
			break
		end
    end

end

-- 设置游金提示牌
function SMCardLayer:showTipCardYJ(cardvalue)
	for i,v in ipairs(self.card_list[RoomConfig.HandCard][RoomConfig.MySeat]) do
		if v ~= nil and v.card_value ~= nil and v.card_value == cardvalue then
			-- 提示游金牌
			if v.card_sprite ~= nil then
				v.card_pos = cc.p(v.card_pos.x, v.card_pos.y + v.card_sprite:getContentSize().height / 4)
				v.card_sprite:setPosition(v.card_pos)
			end
		end
	end

	self.card_touch_enable  = true
end

--重新设置手牌
function SMCardLayer:resetHandCard(viewId,cardList)
	-- body
	------------删除手牌重新生成手牌数据
	self.card_list[RoomConfig.HandCard][viewId] = {}

	local num = #cardList
	for i,v in ipairs(cardList) do --计算牌的位置
		local pos = nil
		local card = self.card_factory:createWithData(viewId,v,true)    --self:createHandCard(v.view_id,v.value[i])
        -- 如果牌为13张则进行牌的缩放
--        if true == self.bIsSanMingGame then
--            card:setScale(self.fCardScale)
--        end
--
		local size = card:getContentSize()
		size.width = size.width - 2
		-- if v.view_id == RoomConfig.MySeat then --有数据的手牌
		pos = cc.p((i-num/2-1-self.GetCardOffsetX)*size.width,0)
		if viewId == RoomConfig.MySeat then
			card:addTouchEventListener(handler(self,CardLayer.touchCardEvent)) --自己的牌需要添加触碰事件
		end

		self:setBaoCard(card, v)
		-- card:setTag(i) --牌的索引
		card:setTag(v)
		card:setPosition(pos)
		self.node["hcard_node"..viewId]:addChild(card)
		local card_panel = {
			card_sprite = card,
			card_value = v, --只有自己的手牌有数据其他的都是nil
			card_pos = cc.p(card:getPosition())
		}
		table.insert(self.card_list[RoomConfig.HandCard][viewId],card_panel)
	end
end

--重置碰杠的牌
function SMCardLayer:resetDownCard(viewId,cardList)
	-- body
    local card_list = self.card_list[RoomConfig.DownCard][viewId]
	self.card_list[RoomConfig.DownCard][viewId] = {}
	local card_data = {}
	local peng_card_list = {} --碰杠的牌以表结构保存

	for i,v in ipairs(cardList) do
        peng_card_list = {}
		if v.type  == RoomConfig.MingGang or v.type == RoomConfig.BuGang or v.type == RoomConfig.AnGang then--如果是其他人暗杠是看不到牌的 --自己暗杠可以看到一张牌
			local card_value = v.cardValue  --杠只有一张牌 字段命名可能不一致
			local c1 = bit._and(card_value,0xff)
			local c2 = c1
			local c3 = c1 
			local c4 = c1 
			if v.type == RoomConfig.AnGang and viewId == RoomConfig.MySeat then
				c1 = RoomConfig.EmptyCard
				c2 = RoomConfig.EmptyCard
				c3 = RoomConfig.EmptyCard
			end
			local card1 = self.card_factory:createDownCardWithData(viewId,c1)
			local card2 = self.card_factory:createDownCardWithData(viewId,c2)
			local card3 = self.card_factory:createDownCardWithData(viewId,c3)
			local card4 = self.card_factory:createDownCardWithData(viewId,c4)
			self:setBaoCard(card1, c1)
			self:setBaoCard(card2, c2)
			self:setBaoCard(card3, c3)
			self:setBaoCard(card4, c4)

			card_data = {mcard={c1,c1,c1,c1}}
			local pos1 = nil
			local pos2 = nil
			local pos3 = nil
			local pos4 = nil
			local size = card1:getContentSize()
			if viewId == RoomConfig.MySeat then --有数据的手牌
				size.width = size.width * 1.42
				size.width = size.width - 2
				pos1 = cc.p((-self.handCardNum/2-0.5+(1+(i-1)*3+self.PengCardOffset)*0.7-self.GetCardOffsetX)*size.width+ (i -2)*self.PengCardOffset*size.width + self.fOffsetX,0)
				pos2 = cc.p((-self.handCardNum/2-0.5+(2+(i-1)*3+self.PengCardOffset)*0.7-self.GetCardOffsetX)*size.width+ (i -2)*self.PengCardOffset*size.width + self.fOffsetX,0)
				pos3 = cc.p((-self.handCardNum/2-0.5+(3+(i-1)*3+self.PengCardOffset)*0.7-self.GetCardOffsetX)*size.width+ (i -2)*self.PengCardOffset*size.width + self.fOffsetX,0)
				pos4 = cc.p((-self.handCardNum/2-0.5+(2+(i-1)*3+self.PengCardOffset)*0.7-self.GetCardOffsetX)*size.width+ (i -2)*self.PengCardOffset*size.width + self.fOffsetX,0+size.height * self.GangCardOffset)
			elseif viewId == RoomConfig.DownSeat then
				pos1 = cc.p(0,(-self.handCardNum/2)*size.height*self.OutCardSortOffsetCol - (1-(i-1)*3)*size.height*self.OutCardSortOffsetCol + (i -2)*self.PengCardOffset*size.height)
				pos2 = cc.p(0,(-self.handCardNum/2)*size.height*self.OutCardSortOffsetCol - (2-(i-1)*3)*size.height*self.OutCardSortOffsetCol + (i -2)*self.PengCardOffset*size.height)
				pos3 = cc.p(0,(-self.handCardNum/2)*size.height*self.OutCardSortOffsetCol - (3-(i-1)*3)*size.height*self.OutCardSortOffsetCol + (i -2)*self.PengCardOffset*size.height)
				pos4 = cc.p(0,(-self.handCardNum/2)*size.height*self.OutCardSortOffsetCol - (2-(i-1)*3)*size.height*self.OutCardSortOffsetCol + (i -2)*self.PengCardOffset*size.height+size.width * self.GangCardOffset)
			elseif viewId == RoomConfig.FrontSeat then
				size = cc.size(size.width*0.7,size.height*0.7)
				pos1 =cc.p((-self.handCardNum/2 - 1)*size.width+(1+(i-1)*3+self.PengCardOffset)*size.width+(i -2)*self.PengCardOffset*size.width,0)
				pos2 =cc.p((-self.handCardNum/2 - 1)*size.width+(2+(i-1)*3+self.PengCardOffset)*size.width+(i -2)*self.PengCardOffset*size.width,0)
				pos3 =cc.p((-self.handCardNum/2 - 1)*size.width+(3+(i-1)*3+self.PengCardOffset)*size.width+(i -2)*self.PengCardOffset*size.width,0)
				pos4 =cc.p((-self.handCardNum/2 - 1)*size.width+(2+(i-1)*3+self.PengCardOffset)*size.width+(i -2)*self.PengCardOffset*size.width,0+size.height * self.GangCardOffset)
				card:setScale(0.7)
			elseif viewId == RoomConfig.UpSeat then
				pos1 = cc.p(0,(self.handCardNum/2+0.5)*size.height*self.OutCardSortOffsetCol-(1+(i-1)*3)*size.height*self.OutCardSortOffsetCol - (i -2)*self.PengCardOffset*size.height)
				pos2 = cc.p(0,(self.handCardNum/2+0.5)*size.height*self.OutCardSortOffsetCol-(2+(i-1)*3)*size.height*self.OutCardSortOffsetCol - (i -2)*self.PengCardOffset*size.height)
				pos3 = cc.p(0,(self.handCardNum/2+0.5)*size.height*self.OutCardSortOffsetCol-(3+(i-1)*3)*size.height*self.OutCardSortOffsetCol - (i -2)*self.PengCardOffset*size.height)
				pos4 = cc.p(0,(self.handCardNum/2+0.5)*size.height*self.OutCardSortOffsetCol-(2+(i-1)*3)*size.height*self.OutCardSortOffsetCol - (i -2)*self.PengCardOffset*size.height+size.width * self.GangCardOffset)
			end

            card1:setPosition(pos1)
            card2:setPosition(pos2)
            card3:setPosition(pos3)
            card4:setPosition(pos4)
            self.node["hcard_node" .. viewId]:addChild(card1)
            self.node["hcard_node" .. viewId]:addChild(card2)
            self.node["hcard_node" .. viewId]:addChild(card3)
            self.node["hcard_node" .. viewId]:addChild(card4)
            table.insert(peng_card_list, card1)
            table.insert(peng_card_list, card2)
            table.insert(peng_card_list, card3)
            table.insert(peng_card_list, card4)
            table.insert(self.card_list[RoomConfig.DownCard][viewId], { card_sprite = peng_card_list, card_value = card_data })
            -- 碰杠牌的数据结构
            -- elseif v.type  == RoomConfig.MAHJONG_OPERTAION_JIN_KAN then
        elseif v.type == 0x40 then
            -- 因为部分手机无法读取到金坎配置 才把类型写死
            local card_value = v.cardValue
            local c1 = bit._and(card_value, 0xff)
            local c2 = bit._and(bit.rshift(card_value, 8), 0xff)
            local card1 = self.card_factory:createDownCardWithData(viewId, c1)
            local card2 = self.card_factory:createDownCardWithData(viewId, c2)
            self:setBaoCard(card1, c1);
            self:setBaoCard(card2, c2);
            local size = card1:getContentSize()
            local pos1 = nil
            local pos2 = nil

            if viewId == RoomConfig.MySeat then 
				size = card1:getContentSize() --获取第一张手牌的大小计算碰杠牌的位置
				size.width = size.width * 1.42
				size.width = size.width - 2
				pos1 = cc.p((-self.handCardNum/2-0.5+(1+(i-1)*3+self.PengCardOffset)*0.7-self.GetCardOffsetX)*size.width + (i-2)*self.PengCardOffset*size.width + self.fOffsetX,0)
				pos2 = cc.p((-self.handCardNum/2-0.5+(2+(i-1)*3+self.PengCardOffset)*0.7-self.GetCardOffsetX)*size.width + (i-2)*self.PengCardOffset*size.width + self.fOffsetX,0)
			elseif viewId == RoomConfig.DownSeat then
				pos1 = cc.p(0,(-self.handCardNum/2)*size.height*self.OutCardSortOffsetCol - (1-(i-1)*3)*size.height*self.OutCardSortOffsetCol + (i -2)*self.PengCardOffset*size.height)
				pos2 = cc.p(0,(-self.handCardNum/2)*size.height*self.OutCardSortOffsetCol - (2-(i-1)*3)*size.height*self.OutCardSortOffsetCol + (i -2)*self.PengCardOffset*size.height)
			elseif viewId == RoomConfig.FrontSeat then
				size = cc.size(size.width*0.7,size.height*0.7)
				pos1 =cc.p((-self.handCardNum/2 - 1)*size.width+(1+(i-1)*3+self.PengCardOffset)*size.width+(i -2)*self.PengCardOffset*size.width+ 40,0)
				pos2 =cc.p((-self.handCardNum/2 - 1)*size.width+(2+(i-1)*3+self.PengCardOffset)*size.width+(i -2)*self.PengCardOffset*size.width+ 40,0)
				card1:setScale(0.7)
				card2:setScale(0.7)
			elseif viewId == RoomConfig.UpSeat then
				pos1 = cc.p(0,(self.handCardNum/2+0.5)*size.height*self.OutCardSortOffsetCol-(1+(i-1)*3)*size.height*self.OutCardSortOffsetCol - (i -2)*self.PengCardOffset*size.height)
				pos2 = cc.p(0,(self.handCardNum/2+0.5)*size.height*self.OutCardSortOffsetCol-(2+(i-1)*3)*size.height*self.OutCardSortOffsetCol - (i -2)*self.PengCardOffset*size.height)
			end

            card1:setPosition(pos1)
            card2:setPosition(pos2)

            self.node["hcard_node" .. viewId]:addChild(card1)
            self.node["hcard_node" .. viewId]:addChild(card2)

            table.insert(peng_card_list, card1)
            table.insert(peng_card_list, card2)

            table.insert(self.card_list[RoomConfig.DownCard][viewId], { card_sprite = peng_card_list, card_value = card_data })
            -- 碰杠牌的数据结构
        elseif v.type == RoomConfig.Peng or v.type == RoomConfig.Chi then
            -- 直接使用数据创建三张牌
            local card_value = v.cardValue
            -- 字段命名可能不一致
            local c1 = bit._and(card_value, 0xff)
            local c2 = bit._and(bit.rshift(card_value, 8), 0xff)
            local c3 = bit._and(bit.rshift(card_value, 16), 0xff)
            card_data = { mcard = { c1, c2, c3 } }
            print("this is create peng card :", c1, c2, c3)
            local card1 = self.card_factory:createDownCardWithData(viewId, c1)
            local card2 = self.card_factory:createDownCardWithData(viewId, c2)
            local card3 = self.card_factory:createDownCardWithData(viewId, c3)
            self:setBaoCard(card1, c1)
            self:setBaoCard(card2, c2)
            self:setBaoCard(card3, c3)

			local size = card1:getContentSize()
			local pos1 = nil
			local pos2 = nil
			local pos3 = nil
			if viewId == RoomConfig.MySeat then 
				size = card1:getContentSize() --获取第一张手牌的大小计算碰杠牌的位置
				size.width = size.width * 1.42
				size.width = size.width - 2
				pos1 = cc.p((-self.handCardNum/2-0.5+(1+(i-1)*3+self.PengCardOffset)*0.7-self.GetCardOffsetX)*size.width + (i-2)*self.PengCardOffset*size.width + self.fOffsetX,0)
				pos2 = cc.p((-self.handCardNum/2-0.5+(2+(i-1)*3+self.PengCardOffset)*0.7-self.GetCardOffsetX)*size.width + (i-2)*self.PengCardOffset*size.width + self.fOffsetX,0)
				pos3 = cc.p((-self.handCardNum/2-0.5+(3+(i-1)*3+self.PengCardOffset)*0.7-self.GetCardOffsetX)*size.width + (i-2)*self.PengCardOffset*size.width + self.fOffsetX,0)
			elseif viewId == RoomConfig.DownSeat then
				pos1 = cc.p(0,(-self.handCardNum/2)*size.height*self.OutCardSortOffsetCol - (1-(i-1)*3)*size.height*self.OutCardSortOffsetCol + (i -2)*self.PengCardOffset*size.height)
				pos2 = cc.p(0,(-self.handCardNum/2)*size.height*self.OutCardSortOffsetCol - (2-(i-1)*3)*size.height*self.OutCardSortOffsetCol + (i -2)*self.PengCardOffset*size.height)
				pos2 = cc.p(0,(-self.handCardNum/2)*size.height*self.OutCardSortOffsetCol - (3-(i-1)*3)*size.height*self.OutCardSortOffsetCol + (i -2)*self.PengCardOffset*size.height)
			elseif viewId == RoomConfig.FrontSeat then
				size = cc.size(size.width*0.7,size.height*0.7)
				pos1 =cc.p((-self.handCardNum/2 - 1)*size.width+(1+(i-1)*3+self.PengCardOffset)*size.width+(i -2)*self.PengCardOffset*size.width,0)
				pos2 =cc.p((-self.handCardNum/2 - 1)*size.width+(2+(i-1)*3+self.PengCardOffset)*size.width+(i -2)*self.PengCardOffset*size.width,0)
				pos3 =cc.p((-self.handCardNum/2 - 1)*size.width+(3+(i-1)*3+self.PengCardOffset)*size.width+(i -2)*self.PengCardOffset*size.width,0)
				card1:setScale(0.7)
				card2:setScale(0.7)
				card3:setScale(0.7)
			elseif viewId == RoomConfig.UpSeat then
				pos1 = cc.p(0,(self.handCardNum/2+0.5)*size.height*self.OutCardSortOffsetCol-(1+(i-1)*3)*size.height*self.OutCardSortOffsetCol - (i -2)*self.PengCardOffset*size.height)
				pos2 = cc.p(0,(self.handCardNum/2+0.5)*size.height*self.OutCardSortOffsetCol-(2+(i-1)*3)*size.height*self.OutCardSortOffsetCol - (i -2)*self.PengCardOffset*size.height)
				pos3 = cc.p(0,(self.handCardNum/2+0.5)*size.height*self.OutCardSortOffsetCol-(3+(i-1)*3)*size.height*self.OutCardSortOffsetCol - (i -2)*self.PengCardOffset*size.height)
			end

			card1:setPosition(pos1)
			card2:setPosition(pos2)
			card3:setPosition(pos3)
			self.node["hcard_node" .. viewId]:addChild(card1)
			self.node["hcard_node" .. viewId]:addChild(card2)
			self.node["hcard_node" .. viewId]:addChild(card3)

			table.insert(peng_card_list,card1)
			table.insert(peng_card_list,card2)
			table.insert(peng_card_list,card3)
			table.insert(self.card_list[RoomConfig.DownCard][viewId],{card_sprite=peng_card_list,card_value=card_data}) --碰杠牌的数据结构
		end
	end
end

--显示/刷新 左上角的2张牌
function SMCardLayer:refreshBaoCardOnLayer(baoCard)
	-- body
	self.card_factory:setBaoPai1(nil)
	self.card_factory:setBaoPai2(nil)
	print("refreshBaoCard2",baoCard,self.node.bao1)
	if baoCard and self.node.bao1 then
		print("refreshBaoCard3")
		self.baocard1 = bit._and(baoCard,0xff)
		self.baocard2 = bit._and(bit.rshift(baoCard,8),0xff)
		print("refreshBaoCard4",self.baocard1,self.baocard2)

		local type,value = self.card_factory:decodeValue(self.baocard1)
		if value ~= nil and value > 0 then 
			local texture_name = string.format("%s/room/resource/mj/mine/M_%s_%d.png",self.res_base, RoomConfig.CardType[type],value)
			print("bao1Name->",texture_name)
			self.node.bao1:loadTexture(texture_name,1)
			self.node.bao1:show()
			self.node.kuang1:show()
		else
			print("bao1->hide")
			self.node.bao1:hide()
			self.node.kuang1:hide()
		end

		-- type,value = self.card_factory:decodeValue(self.baocard2)
		-- texture_name = string.format("%s/room/resource/mj/mine/M_%s_%d.png",self.res_base, RoomConfig.CardType[type],value)
		-- print("bao2Name->",texture_name)

		-- self.node.bao2:loadTexture(texture_name,1)
		-- self.node.bao2:show()
	end
end

--显示 2张抓尾的宝牌
function SMCardLayer:showSelectBaoCardOnLayer(baoCard)
	
end

-- 展示出牌的动画
function SMCardLayer:outCard(viewId,value)
    -- 
 	local card = self.card_factory:createWithData(RoomConfig.MySeat,value) --出牌的牌 是用自己的牌的大小来显示的
	self:setBaoCard(card, value)

	local sex = self.part:getPlayerInfo(viewId).sex
 	local card_type,card_value = self.card_factory:decodeValue(value)
 	self:playCardEffect(card_type, card_value , sex)

 	-- self.node["hcard_node" .. viewId]:addChild(card)
 	self:addChild(card)
 	local content_size = card:getContentSize()
	local pos = cc.p(self.node['hcard_node' .. viewId]:getPosition())
	card:setPosition(pos)
	
	if viewId == RoomConfig.MySeat then --结束时最后一张牌
		if self.select_card.card then
			pos = cc.p(self.select_card.card:getPosition())
			pos = self.node["hcard_node" .. viewId]:convertToWorldSpace(pos)
			card:setPosition(pos)
		end
		pos = cc.p(0,content_size.height*self.OutCardOffset)
	elseif viewId == RoomConfig.DownSeat then
		pos = cc.p(-content_size.width*CardLayer.OutCardOffset,0)
	elseif viewId == RoomConfig.FrontSeat then
		pos =cc.p(0,-content_size.height*CardLayer.OutCardOffset/2)
	elseif viewId == RoomConfig.UpSeat then
		pos = cc.p(content_size.width*CardLayer.OutCardOffset,0)
	end
	pos = self.node["hcard_node" .. viewId]:convertToWorldSpace(pos)
	local actions = {
						cc.Spawn:create(cc.MoveTo:create(CardLayer.OutCardTime,pos),cc.ScaleTo:create(CardLayer.OutCardTime+0.3,1)),
					}
	local seq = transition.sequence(actions)
	self:removeCurOutCard(viewId)
	self.last_out_card[viewId] = card
	transition.execute(card,seq,{removeSelf= false,onComplete=function()
		-- body
		if RoomConfig.Ai_Debug then
			local ai_mod = global:getModuleWithId(ModuleDef.AI_MOD)
			if ai_mod:checkPengGang() == false then
				ai_mod:turnSeat()
			end
		else
			self:addOutCard(viewId,value)
		end
	end})

end

function SMCardLayer:showHuCardSp(viewId,value)
	-- local card = self.card_factory:createWithData(RoomConfig.MySeat,value) --出牌的牌 是用自己的牌的大小来显示的
	-- self:setBaoCard(card, value)
    -- card:setScale(0.8)

	-- local sex = self.part:getPlayerInfo(viewId).sex
 	-- local card_type,card_value = self.card_factory:decodeValue(value)
 	-- self:addChild(card,20)
 	-- card:setAnchorPoint(cc.p(0.5,0.5))
 	-- local pos = cc.p(self.node["zcard_node" .. viewId]:getPosition())
    -- pos.x = pos.x + 120
    -- pos.y = pos.y - 50

-- -- 	if viewId == RoomConfig.MySeat then --结束时最后一张牌

-- --		pos = cc.p(670,100)
-- --	elseif viewId == RoomConfig.DownSeat then
-- --		-- pos = cc.p(960,390)
-- --        pos = cc.p(960,330)
-- --	elseif viewId == RoomConfig.FrontSeat then
-- --		pos =cc.p(640,577)
-- --	elseif viewId == RoomConfig.UpSeat then
-- --		pos = cc.p(400,390)
-- --	end
	-- card:setPosition(pos)
	
	local hucard = self.node["hucard_" .. viewId];
    self.card_factory:addSpriteFrames()
	local sprite = self.card_factory:createDownCardWithData(viewId,value)
	-- local type,value = self.card_factory:decodeValue(value)
	-- local texture_name = string.format("%s/room/resource/mj/%s/%s_%s_%d.png", self.res_base, cardpos, cardStart, RoomConfig.CardType[type], value)
	hucard:hide();
	self.node["Node_effec_" .. viewId]:addChild(sprite, -1);
    -- hucard:loadTexture(texture_name,1)
    
    -- local nodetemp = self.node["zcard_node_" .. viewId]
    -- local pos = cc.p(nodetemp:getPosition())
    -- hucard:setPosition(pos)
end

--加入一个操作显示
function SMCardLayer:showAddOpt(optList)
	-- bod
	self.opt_list = optList
	self.node.opt_card_list:removeAllChildren()
  	self.node.opt_card_list:setItemModel(self.node.opt_card_panel)
  	self.node.opt_card_list:show()
  	self.card_touch_enable = false
  	for i,v in ipairs(optList) do
		self.node.opt_card_list:insertDefaultItem(i-1)
		local item = self.node.opt_card_list:getItem(i-1)
		local opt_btn = item:getChildByName("opt_btn")
        opt_btn:show()
		local pic_name = ""
		if v == RoomConfig.MAHJONG_OPERTAION_CANCEL then
			pic_name = "cancel_bt.png"
		elseif v == RoomConfig.MAHJONG_OPERTAION_CHI then
			pic_name = "chi.png"
		elseif v == RoomConfig.MAHJONG_OPERTAION_PENG then
			pic_name = "peng_bt.png"
		elseif v == RoomConfig.MAHJONG_OPERTAION_AN_GANG or v == RoomConfig.MAHJONG_OPERTAION_MING_GANG or v == RoomConfig.Gang then
			pic_name = "gang_bt.png"
		elseif v == RoomConfig.MAHJONG_OPERTAION_HU then
			pic_name = "hu.png"

            -- 胡按钮显示胡的特效
            local parent = opt_btn:getParent()
            -- self.node.hu_btn:retain()
            self.node.hu_btn:removeFromParent()
            parent:addChild(self.node.hu_btn)
            local pos = cc.p(opt_btn:getPosition())
            self.node.hu_btn:setPosition(pos)
            self.node.hu_btn:show()
            -- local texture_name = string.format("%s/room/resource/mj/%s", self.res_base, pic_name)
            -- self.node.Sprite_huBtn_ani2:setTexture(texture_name)
            self.node.Sprite_huBtn_ani2:hide()
            self.node.animation:play("hu_animate", true)
		elseif v == RoomConfig.MAHJONG_SAN_JIN_DAO then
			pic_name = "sanjindao_bt.png"

            -- 胡按钮显示胡的特效
            local parent = opt_btn:getParent()
            -- self.node.hu_btn:retain()
            self.node.hu_btn:removeFromParent()
            parent:addChild(self.node.hu_btn)
            local pos = cc.p(opt_btn:getPosition())
            self.node.hu_btn:setPosition(pos)
            self.node.hu_btn:show()
            -- local texture_name = string.format("%s/room/resource/mj/%s", self.res_base, pic_name)
            -- self.node.Sprite_huBtn_ani2:setTexture(texture_name)
            self.node.Sprite_huBtn_ani2:hide()
            self.node.animation:play("hu_animate", true)
		elseif v == RoomConfig.MAHJONG_DAN_YOU then
			pic_name = "youjin_bt.png"
        elseif v == 0x40 then
			pic_name = "jinkan_bt.png"
		elseif v == RoomConfig.MAHJONG_SHUANG_YOU then
			pic_name = "shuangyou_bt.png"

            -- 胡按钮显示胡的特效
            local parent = opt_btn:getParent()
            -- self.node.hu_btn:retain()
            self.node.hu_btn:removeFromParent()
            parent:addChild(self.node.hu_btn)
            local pos = cc.p(opt_btn:getPosition())
            self.node.hu_btn:setPosition(pos)
            self.node.hu_btn:show()
            -- local texture_name = string.format("%s/room/resource/mj/%s", self.res_base, pic_name)
            -- self.node.Sprite_huBtn_ani2:setTexture(texture_name)
            self.node.Sprite_huBtn_ani2:hide()
            self.node.animation:play("hu_animate", true)
		elseif v == RoomConfig.MAHJONG_SAN_YOU then
			pic_name = "sanyou_bt.png"

            -- 胡按钮显示胡的特效
            local parent = opt_btn:getParent()
            -- self.node.hu_btn:retain()
            self.node.hu_btn:removeFromParent()
            parent:addChild(self.node.hu_btn)
            local pos = cc.p(opt_btn:getPosition())
            self.node.hu_btn:setPosition(pos)
            self.node.hu_btn:show()
            -- local texture_name = string.format("%s/room/resource/mj/%s", self.res_base, pic_name)
            -- self.node.Sprite_huBtn_ani2:setTexture(texture_name)
            self.node.Sprite_huBtn_ani2:hide()
            self.node.animation:play("hu_animate", true)
		elseif v == RoomConfig.MAHJONG_QIANG_JIN then
			pic_name = "qiangjin_bt.png"

            -- 胡按钮显示胡的特效
            local parent = opt_btn:getParent()
            -- self.node.hu_btn:retain()
            self.node.hu_btn:removeFromParent()
            parent:addChild(self.node.hu_btn)
            local pos = cc.p(opt_btn:getPosition())
            self.node.hu_btn:setPosition(pos)
            self.node.hu_btn:show()
            -- local texture_name = string.format("%s/room/resource/mj/%s", self.res_base, pic_name)
            -- self.node.Sprite_huBtn_ani2:setTexture(texture_name)
            self.node.Sprite_huBtn_ani2:hide()
            self.node.animation:play("hu_animate", true)
		end
		local texture_name = string.format("%s/room/resource/mj/%s",self.res_base,pic_name)
        
		opt_btn:loadTexture(texture_name,1)
	end
	self.node.opt_card_list:forceDoLayout()
	self.node.opt_card_list:jumpToPercentHorizontal(100)
end

function CardLayer:optListEvent(ref,event)
	-- body
    local cur_select = self.node.opt_card_list:getCurSelectedIndex()
    local item = self.node.opt_card_list:getItem(cur_select)
    item:setAnchorPoint(cc.p(0.5, 0.5))
    if 0 == event then
        -- 对选择的按钮进行缩放处理
        item:setScale(1.1)     
	elseif event == 1 and self.opt_list then
        -- 对选择的按钮进行缩放处理
        item:setScale(1.0)
        
		
		self.card_touch_enable = false
		self:hideOpt()

        -- 将所有提上来的牌恢复为原来的位置
        for k, v in pairs(self.card_list[RoomConfig.HandCard][RoomConfig.MySeat]) do
            local fPosY = 0.0
            local nodeCard = v.card_sprite
            nodeCard:setPositionY(fPosY)
        end
        self.tableLiftCardValueAndPos = { }

        -- 设置隐藏胡的特效按钮
        self.node.hu_btn:hide()
        self.node.animation:stop()
        self.node.animation:resume()

        self.tableLiftCardValueAndPos = { }

		self.part:optClick(self.opt_list[cur_select + 1])
		self.opt_list = nil
	end
end

-- 添加出的牌到桌面
-- CardLayer.OutCardCol = 9 --出牌队列有多少列
-- CardLayer.OutCardRow = 2 --出牌队列有多少行
function SMCardLayer:addDownCard(viewId,value)
	local sprite = self.card_factory:createDownCardWithData(viewId,value)--ccui.ImageView:create()
	self:setBaoCard(sprite, value)
	-- sprite:loadTexture(frame_name,1)
    local card_list = self.card_list[RoomConfig.OutCard][viewId]
    local card_num = #card_list
    local content_size = sprite:getContentSize()
    local col = card_num % self.OutCardCol -- 当前牌应该放在第几列
    local row = math.floor(card_num / self.OutCardCol)  -- 当前牌应该放在第几行
    local pos = nil
    local fCardScale = sprite:getScale()

	if viewId == RoomConfig.MySeat then
        -- pos = cc.p((col - self.OutCardCol / 2) * content_size.width, - row * content_size.height * self.OutCardSortOffsetRow)

        pos = cc.p((col - self.OutCardCol / 2 + 0.5) * content_size.width, - row * content_size.height * self.OutCardSortOffsetRow)
	elseif viewId == RoomConfig.DownSeat then
		pos = cc.p(row*content_size.width,(col - self.OutCardCol/2)*content_size.height*self.OutCardSortOffsetCol)
		sprite:setLocalZOrder(self.OutCardCol*self.OutCardRow - (row+1)*col)
	elseif viewId == RoomConfig.FrontSeat then
		-- pos = cc.p((self.OutCardCol/2-col)*content_size.width,row*content_size.height*self.OutCardSortOffsetRow)
        pos = cc.p((self.OutCardCol / 2 - col - 0.5) * content_size.width, row * content_size.height * self.OutCardSortOffsetRow)
		sprite:setLocalZOrder(self.OutCardRow - row)
	elseif viewId == RoomConfig.UpSeat then
		pos = cc.p(-row*content_size.width,(self.OutCardCol/2-col)*content_size.height*self.OutCardSortOffsetCol)
	end

	sprite:setPosition(pos)
	local card_panel = {
			card_sprite = sprite,
			card_value = value
		}
	table.insert(self.card_list[RoomConfig.OutCard][viewId],card_panel)

	self.node["ocard_node" .. viewId]:addChild(sprite)

	-- 显示出牌标记位置
	self.node.marker:show()
	self.node.marker:stopAllActions()
	local world_pos = sprite:convertToWorldSpace(sprite:getAnchorPointInPoints())
	world_pos = cc.pAdd(world_pos,cc.p(0,content_size.height/2))
	self.node.marker:setPosition(world_pos)
	local actions = {
						cc.MoveBy:create(0.5,cc.p(0,10)),
						cc.MoveBy:create(0.5,cc.p(0,-10)),
					}
	local seq = transition.sequence(actions)
	local action = cc.RepeatForever:create(seq)
	self.node.marker:runAction(action)

end

--增加一张牌到出牌队列
function SMCardLayer:addOutCard(viewId,value)
	-- body
	if self.last_out_card[viewId] then
		local card_list = self.card_list[RoomConfig.OutCard][viewId]
		local card_num= #card_list
		local sprite = self.card_factory:createDownCardWithData(viewId,value)--ccui.ImageView:create()
		self:setBaoCard(sprite, value)
		local content_size = sprite:getContentSize()
		local col = card_num%self.OutCardCol --当前牌应该放在第几列
		local row = math.floor(card_num/self.OutCardCol)  --当前牌应该放在第几行
		local pos = nil

		if viewId == RoomConfig.MySeat then
			pos = cc.p((col - self.OutCardCol/2)*content_size.width,-row*content_size.height*self.OutCardSortOffsetRow)
		elseif viewId == RoomConfig.DownSeat then
			pos = cc.p(row*content_size.width,(col - self.OutCardCol/2)*content_size.height*self.OutCardSortOffsetCol)
		elseif viewId == RoomConfig.FrontSeat then
			pos = cc.p((self.OutCardCol/2-col)*content_size.width,row*content_size.height*self.OutCardSortOffsetRow)
		elseif viewId == RoomConfig.UpSeat then
			pos = cc.p(-row*content_size.width,(self.OutCardCol/2-col)*content_size.height*self.OutCardSortOffsetCol)
		end
		local wold_pos = self.node["ocard_node" .. viewId]:convertToWorldSpace(pos)

        self:addDownCard(viewId,value)
		local actions = {
					cc.Spawn:create(cc.MoveTo:create(CardLayer.AddCardTime,wold_pos),cc.ScaleTo:create(CardLayer.AddCardTime,0.5)),
				}
		local seq = transition.sequence(actions)
		transition.execute(self.last_out_card[viewId],seq,{removeSelf= false,onComplete=function()
			-- body
			if self.last_out_card[viewId] then
				-- self:addDownCard(viewId,value)
				self:removeCurOutCard(viewId)
			end
		end})
	end
end

function SMCardLayer:playOperateEffect(operate_type , sex , seat) 	--操作类型（胡 碰 杠）出牌人性别 出牌人位置
   local sex = tostring(sex)
   local mp3_name = nil
   local sex_name = "man"
   
   if sex ~=  "2" then
   		sex_name = "female"
   end

	if operate_type == MahjongOperation.CHI then --吃
			mp3_name = "res/sound/".. sex_name .. "/chi.mp3"
    elseif operate_type == MahjongOperation.PENG then --碰
			mp3_name = "res/sound/".. sex_name .. "/peng0.mp3"
    elseif operate_type == MahjongOperation.MING_GANG or operate_type == MahjongOperation.AN_GANG or operate_type == MahjongOperation.BU_GANG then --杠
		    mp3_name = "res/sound/".. sex_name .. "/gang0.mp3"
    elseif operate_type == MahjongOperation.PLAYER_HU_CONFIRMED then --胡
			mp3_name = "res/sound/".. sex_name .. "/hu.mp3"
		--为什么加下面的语句， lxb 注释掉了
		--if seat == RoomConfig.MySeat and sex ~= "2" then
		--	mp3_name = "res/sound/female/hu1.mp3"
		--end
	elseif operate_type == MahjongOperation.MAHJONG_QIANG_JIN then --抢金
			mp3_name = "res/sound/".. sex_name .. "/qiangjin.mp3"
	elseif operate_type == MahjongOperation.MAHJONG_SAN_JIN_DAO then --
			mp3_name = "res/sound/".. sex_name .. "/peng0.mp3"
	elseif operate_type == MahjongOperation.MAHJONG_SI_JIN_DAO then --
			mp3_name = "res/sound/".. sex_name .. "/peng0.mp3"
	elseif operate_type == MahjongOperation.MAHJONG_WU_JIN_DAO then --
			mp3_name = "res/sound/".. sex_name .. "/peng0.mp3"
	elseif operate_type == MahjongOperation.MAHJONG_LIU_JIN_DAO then --
			mp3_name = "res/sound/".. sex_name .. "/peng0.mp3"
	elseif operate_type == MahjongOperation.MAHJONG_DAN_YOU then --
			mp3_name = "res/sound/".. sex_name .. "/peng0.mp3"
	elseif operate_type == MahjongOperation.MAHJONG_SHUANG_YOU then --
			mp3_name = "res/sound/".. sex_name .. "/peng0.mp3"
	elseif operate_type == MahjongOperation.MAHJONG_SAN_YOU then --
			mp3_name = "res/sound/".. sex_name .. "/peng0.mp3"
	elseif operate_type == MahjongOperation.MAHJONG_CHA_PAI then --
			mp3_name = "res/sound/".. sex_name .. "/peng0.mp3"
	elseif operate_type == MahjongOperation.MAHJONG_CHA_HUA then --
			mp3_name = "res/sound/".. sex_name .. "/peng0.mp3"
    elseif operate_type == MahjongOperation.PLAYER_HU_CONFIRMED then --自摸
			mp3_name = "res/sound/".. sex_name .. "/zimo0.mp3"
		if seat == RoomConfig.MySeat and sex ~= "2" then
			mp3_name = "res/sound/female/zimo111.mp3"
		end
	end

	if mp3_name == nil then
		return 
	end
   global:getAudioModule():playSound(mp3_name,false)
end

--摸牌
function SMCardLayer:getCard(value)
    local card = self.card_factory:createWithData(RoomConfig.MySeat, value, true) -- 只有自己有摸牌动作

--    -- 如果牌为13张则进行牌的缩放
--    if true == self.bIsSanMingGame then
--        card:setScale(self.fCardScale)
--    end

    self:setBaoCard(card, value)
    local size = card:getContentSize()
    local card_num = #self.card_list[RoomConfig.HandCard][RoomConfig.MySeat]
    local card_num1 = #self.card_list[RoomConfig.DownCard][RoomConfig.MySeat]

    size.with = size.width - 2

    -- 如果是13张牌的时候需要向右偏移--策划需求
    local handCardOffsetFor13 = 0
    if handCardNumFlag == 13 then
        handCardOffsetFor13 = handCardOffsetFor13 + 30
    end

    
    local iHandCardNum = table.maxn(self.card_list[RoomConfig.HandCard][RoomConfig.MySeat])
    local nodeCard = self.card_list[RoomConfig.HandCard][RoomConfig.MySeat][iHandCardNum]
    local fPosX = nodeCard.card_sprite:getPositionX()
    local fPosY = nodeCard.card_sprite:getPositionY()

    local pos = cc.p(0.0, 0.0)
	pos = cc.p(fPosX + size.with * 0.5 + 85, fPosY)

    -- if true == self.bIsSanMingGame then
    --     local fScale = card:getScale()
    --     pos = cc.p(fPosX + size.with * 0.5 + 80, fPosY)
    -- else
    --     pos = cc.p((card_num - self.handCardNum / 2 + card_num1 * 2.1 + card_num1 * self.PengCardOffset) * size.width + handCardOffsetFor13, 0)
    -- end

    card:setPosition(pos)
    -- card:setTag(card_num + 1)
    card:setTag(value)
    card:addTouchEventListener(handler(self, CardLayer.touchCardEvent)) -- 自己的牌需要添加触碰事件
    self.node.hcard_node1:addChild(card)
    local card_data = {
        card_sprite = card,
        card_value = value,
        card_pos = cc.p(card:getPosition())
    }
    table.insert(self.card_list[RoomConfig.HandCard][RoomConfig.MySeat], card_data)
end

--玩家吃,碰,杠
--value= {mcard={2,3},ocard = 1}
function SMCardLayer:optCard(viewId,type,value,lastOpt)
	-- 删除吃碰杠的牌
	print("this is optCard:",viewId,type,value,lastOpt)
	self.card_touch_enable = false
	local card_list =self.card_list[RoomConfig.HandCard][viewId]
	local card_size = #self.card_list[RoomConfig.HandCard][viewId]
	if viewId == RoomConfig.MySeat then --自己的牌需要根据数据删除。其他人的牌就随便删除两-三张
		for j,v in ipairs(value.mcard) do
			for i=card_size,1,-1 do
				local del_card =v
				
				if del_card == RoomConfig.EmptyCard then --暗杠需要根据第四张牌的值判断删除那些牌
					del_card = value.mcard[4] or RoomConfig.EmptyCard
				end
				
				if card_list[i].card_value and card_list[i].card_value == del_card then
					card_list[i].card_sprite:removeSelf()
					table.remove(card_list,i)
					card_size = card_size - 1
					break
				end
			end
		end
	else
		if type ~= RoomConfig.BuGang then
			local remove_card_num = 3
			for i=card_size,card_size-remove_card_num+1,-1 do
				card_list[i].card_sprite:removeSelf()
				table.remove(card_list,i)
			end
		end
	end
    --创建吃碰杠的牌 基于手牌的位置偏移
	local card_list1 = self.card_list[RoomConfig.DownCard][viewId]
	local card_num1 = #self.card_list[RoomConfig.DownCard][viewId]
	local down_card = {}
	for i,v in ipairs(value.mcard) do
		down_card[i] = v
	end
	print("this is opt card:",type,card_num1,#down_card)
	
	if value.ocard then
		table.insert(down_card,1,value.ocard)
	end

    local iTemp = table.maxn(down_card)
    local iLastValue = down_card[iTemp]

    --if type ~= RoomConfig.Peng and type ~= RoomConfig.Chi and type ~= RoomConfig.MAHJONG_OPERTAION_JIN_KAN then 
    if type ~= RoomConfig.Peng and type ~= RoomConfig.Chi and type ~= 0x40 then  -- 因为部分手机无法读取到金坎配置 才把类型写死
        down_card = { }
        if type == RoomConfig.AnGang then
            for i = 1, 4 do
                table.insert(down_card, RoomConfig.EmptyCard)
            end
            down_card[4] = iLastValue
        else
            for i = 1, 4 do
                table.insert(down_card, iLastValue)
            end
        end
    elseif type == RoomConfig.Chi then
        table.sort(down_card, function(a, b)
            return a < b
        end)
    end

    local posScend = cc.p(0.0, 0.0)

	local peng_card_list = {} --碰杠的牌以表结构保存
	for i,v in ipairs(down_card) do
		local card = nil
	    card = self.card_factory:createDownCardWithData(viewId,v)
		local size = card:getContentSize()
		if v == RoomConfig.EmptyCard and viewId == RoomConfig.DownSeat then --下家的背牌旋转了-90度宽高需要调转我也不知道为啥图片要这么出
			size = {width=size.height,height = size.width}
		end
		local pos = nil 
		if type == RoomConfig.BuGang then
			for k,j in ipairs(card_list1) do
				print("this is room config bugang:",j.card_value.mcard[1],v)
				if j.card_value.mcard[1] == v then --补杠只需要创建一张牌
					local card_sprite = j.card_sprite[2] --第二张
					local pos = cc.p(card_sprite:getPosition())
					if viewId == RoomConfig.MySeat or viewId == RoomConfig.FrontSeat then
						pos = cc.p(pos.x,pos.y+size.height*self.GangCardOffset)
					else
						pos = cc.p(pos.x,pos.y+size.width*self.GangCardOffset)
					end

					if viewId == RoomConfig.FrontSeat then
						card:setScale(0.7)
					end

					card:setPosition(pos)
					self.node["hcard_node" .. viewId]:addChild(card)
					table.insert(j.card_sprite,card)
					break
				end
			end
		elseif type == RoomConfig.MingGang or type == RoomConfig.AnGang then--如果是其他人暗杠是看不到牌的 --自己暗杠可以看到一张牌
			
			if viewId == RoomConfig.MySeat then --有数据的手牌
				size.width = size.width*1.42
				size.width = size.width - 2
				local offset_y = 0
				local index=  i
				if index == 4 then
					offset_y = size.height * self.GangCardOffset
					index = 2
				end

                pos = cc.p((-self.handCardNum/2-0.5+(index+card_num1*3+self.PengCardOffset)*0.7-self.GetCardOffsetX)*size.width+ (card_num1 -1)*self.PengCardOffset*size.width + self.fOffsetX,offset_y)
				
			elseif viewId == RoomConfig.DownSeat then
				local offset_y = 0
				local index=  i
				if index == 4 then
					offset_y = size.width * self.GangCardOffset
					index = 2
				end
				pos = cc.p(0,(-self.handCardNum/2)*size.height*self.OutCardSortOffsetCol - (index-card_num1*3)*size.height*self.OutCardSortOffsetCol + (card_num1 -1)*self.PengCardOffset*size.height+offset_y)
			elseif viewId == RoomConfig.FrontSeat then
				local offset_y = 0
				local index=  i
				if index == 4 then
					offset_y = size.height * self.GangCardOffset
					index = 2
				end
				size = cc.size(size.width*0.7,size.height*0.7)
				pos =cc.p((-self.handCardNum/2 - 1.5)*size.width+(index+card_num1*3+self.PengCardOffset)*size.width+(card_num1 -1)*self.PengCardOffset*size.width,0+offset_y)
				card:setScale(0.7)
			elseif viewId == RoomConfig.UpSeat then
				local offset_y = 0
				local index=  i
                pos = cc.p(0,(self.handCardNum/2+0.5)*size.height*self.OutCardSortOffsetCol-(index+card_num1*3)*size.height*self.OutCardSortOffsetCol - (card_num1 -1)*self.PengCardOffset*size.height+offset_y)
				if index == 4 then
					offset_y = size.width * self.GangCardOffset
					-- index = 2
                    pos = posScend
                    pos.y = pos.y + offset_y
				end

                if 2 == i then
                    posScend = pos
                end
			end

			card:setPosition(pos)
			self.node["hcard_node" .. viewId]:addChild(card)

			table.insert(peng_card_list,card)
		elseif type == RoomConfig.Peng  or type == RoomConfig.Chi then
			if viewId == RoomConfig.MySeat then --有数据的手牌
				size.width = size.width*1.42
				size.width = size.width - 2
				pos = cc.p((-self.handCardNum/2-0.5+(i+card_num1*3+self.PengCardOffset)*0.7-self.GetCardOffsetX)*size.width + (card_num1-1)*self.PengCardOffset*size.width + self.fOffsetX,0)
			elseif viewId == RoomConfig.DownSeat then
				pos = cc.p(0,(-self.handCardNum/2)*size.height*self.OutCardSortOffsetCol - (i-card_num1*3)*size.height*self.OutCardSortOffsetCol + (card_num1 -1)*self.PengCardOffset*size.height)
			elseif viewId == RoomConfig.FrontSeat then
				size = cc.size(size.width*0.7,size.height*0.7)
				pos =cc.p((-self.handCardNum/2 - 1.5)*size.width+(i+card_num1*3+self.PengCardOffset)*size.width+(card_num1 -1)*self.PengCardOffset*size.width,0)
				card:setScale(0.7)
			elseif viewId == RoomConfig.UpSeat then
				pos = cc.p(0,(self.handCardNum/2+0.5)*size.height*self.OutCardSortOffsetCol-(i+card_num1*3)*size.height*self.OutCardSortOffsetCol - (card_num1 -1)*self.PengCardOffset*size.height)
			end

			card:setPosition(pos)
			self.node["hcard_node" .. viewId]:addChild(card)

			table.insert(peng_card_list,card)

		-- elseif type == RoomConfig.MAHJONG_OPERTAION_JIN_KAN then 
        elseif type == 0x40 then  -- 因为部分手机无法读取到金坎配置 才把类型写死
			if viewId == RoomConfig.MySeat then --有数据的手牌
				size.width = size.width*1.42
				size.width = size.width - 2
				pos = cc.p((-self.handCardNum/2-0.5+(i+card_num1*3+self.PengCardOffset)*0.7-self.GetCardOffsetX)*size.width + (card_num1-1)*self.PengCardOffset*size.width + self.fOffsetX,0)
			elseif viewId == RoomConfig.DownSeat then
				pos = cc.p(0,(-self.handCardNum/2)*size.height*self.OutCardSortOffsetCol - (i-card_num1*2)*size.height*self.OutCardSortOffsetCol + (card_num1 -1)*self.PengCardOffset*size.height)
			elseif viewId == RoomConfig.FrontSeat then
				size = cc.size(size.width*0.7,size.height*0.7)
				pos =cc.p((-self.handCardNum/2 - 1.5)*size.width+(i+card_num1*2+self.PengCardOffset)*size.width+(card_num1 -1)*self.PengCardOffset*size.width + 40,0)
				card:setScale(0.7)
			elseif viewId == RoomConfig.UpSeat then
				pos = cc.p(0,(self.handCardNum/2+0.5)*size.height*self.OutCardSortOffsetCol-(i+card_num1*3)*size.height*self.OutCardSortOffsetCol - (card_num1 -1)*self.PengCardOffset*size.height)
			end

			card:setPosition(pos)
			self.node["hcard_node" .. viewId]:addChild(card)

			table.insert(peng_card_list,card)
			
		end
	end

	if type ~= RoomConfig.BuGang then --补杠不需要创建新的牌堆
		table.insert(card_list1,{card_sprite=peng_card_list,card_value=value}) --碰杠牌的数据结构
	end
	
	if viewId == RoomConfig.MySeat then
		self:sortHandCard(viewId,type)
	end

	self.node.marker:hide()

	local sex = self.part:getPlayerInfo(viewId).sex
	local seat_id = self.part:getPlayerInfo(viewId).seat_id
	self:playOperateEffect(type , sex , seat_id)

end

--[[
游戏开始创建手牌
牌摆放的顺序很重要会影响碰杠的牌的摆放
--]]
function SMCardLayer:createCardWithData(data)
	for i,v in ipairs(data) do
		local content_pos = cc.p(self.node["hcard_node" .. v.view_id]:getPosition())
		
		if v.num > self.handCardNum then
			v.num = self.handCardNum
		end
		
		for i=1,v.num do --计算牌的位置
			local pos = nil
			local card = self.card_factory:createWithData(v.view_id,v.value[i],true)--self:createHandCard(v.view_id,v.value[i])

--            if true == self.bIsSanMingGame then
--                card:setScale(self.fCardScale)
--            end

			local size = card:getContentSize()
			size.width = size.width - 2
			if v.view_id == RoomConfig.MySeat then --有数据的手牌
				pos = cc.p((i-v.num/2-1-self.GetCardOffsetX)*size.width,0)
				card:addTouchEventListener(handler(self,CardLayer.touchCardEvent)) --自己的牌需要添加触碰事件
				-- card:setTag(i) --牌的索引
				card:setTag(v.value[i])
				self.out_line = content_pos.y + size.height
			elseif v.view_id == RoomConfig.DownSeat then --下家从上往下列牌
				if v.value[i] ~= nil then
					size.height = size.height +10
				end
				pos = cc.p(0,(v.num/2-i-1)*size.height/2)
			elseif v.view_id == RoomConfig.FrontSeat then --对家从右到左排列
				if v.value[i] ~= nil then
					size.width = size.width/2
				end
				pos =cc.p((v.num/2-i+0.5)*size.width,0)
			elseif v.view_id == RoomConfig.UpSeat then --上家从下到上排列
				if v.value[i] ~= nil then
					size.height = size.height +10
				end
				pos = cc.p(0,(i-v.num/2-1)*size.height/2)
				card:setLocalZOrder(v.num - i)
			end
			card:setPosition(pos)
			self.node["hcard_node"..v.view_id]:addChild(card)

			local card_panel = {
				card_sprite = card,
				card_value = v.value[i], --只有自己的手牌有数据其他的都是nil
				card_pos = cc.p(card:getPosition())
			}

			table.insert(self.card_list[RoomConfig.HandCard][v.view_id],card_panel)
		end

		if v.value[v.num + 1] then
			self:getCard(v.value[v.num + 1])
		end
	end
end

--重新排列手牌 手牌的顺序必须和数据顺序一样。
function SMCardLayer:sortHandCard(viewId,optCard)
	-- 手牌
	local card_list = self.card_list[RoomConfig.HandCard][viewId]
	local card_num = #card_list


		--吃碰杠的牌
	local card_list1 = self.card_list[RoomConfig.DownCard][viewId]
	local card_num1 = #card_list1

	print("This is sort hand card:",card_num,card_num1)

    for i = 1, card_num do
        local v = card_list[i]
        local size = v.card_sprite:getContentSize()
        local pos = nil
        size.width = size.width - 2
        -- v.card_sprite:setTag(i) --重新排列索引
        local start_pos = 0

        -- 如果是13张牌的时候需要向右偏移--策划需求
        local handCardOffsetFor13 = 0
        if handCardNumFlag == 13 then
            handCardOffsetFor13 = handCardOffsetFor13 + 80
        end
        start_pos =(- self.GetCardOffsetX - self.handCardNum / 2) * size.width + handCardOffsetFor13
        -- 起始点位置
        local down_card_size =((card_num1 * 3 + self.PengCardOffset) * 0.7 + card_num1 * self.PengCardOffset) * size.width
        if card_num1 == 0 then
            down_card_size = 0
        end

        -- 如果是13张牌的时候需要向右偏移--策划需求【碰吃杠偏移修改】
        if handCardNumFlag == 13 then
            start_pos = start_pos - 25
        end

--        if true == self.bIsSanMingGame then
--            local fScale = v.card_sprite:getScale()
--            pos = cc.p(start_pos + down_card_size +(i - 1) * size.width * fScale, 0)
--        else
--            pos = cc.p(start_pos + down_card_size +(i - 1) * size.width, 0)
--        end
        pos = cc.p(start_pos + down_card_size +(i - 1) * size.width, 0)
        -- cc.p((card_num1*3*0.7+card_num1*self.PengCardOffset)*size.width + (i-1-self.handCardNum/2-self.GetCardOffsetX)*size.width,0)
        v.card_sprite:setPosition(pos)
        v.card_pos = pos
    end

    
	if (optCard and (optCard == RoomConfig.Peng or optCard == RoomConfig.Chi)) or card_num == (self.handCardNum + 1)then --碰完牌要把一张牌放到摸牌位
		local card = card_list[card_num].card_sprite --最后一张牌移位

		-- card:setTag(card_num)

        local pos = cc.p(0.0, 0.0)
        
        if true == self.bIsSanMingGame then
            local fCardPosX = card:getPositionX()
            local fCardPosY = card:getPositionY()

            pos = cc.p(fCardPosX + 30, fCardPosY)
        else
            card_num = card_num - 1
            local size = card:getContentSize()
            size.with = size.width - 2
            -- 如果是13张牌的时候需要向右偏移--策划需求
            local handCardOffsetFor13 = 0
            if handCardNumFlag == 13 then
                handCardOffsetFor13 = handCardOffsetFor13 + 120
            end
            pos = cc.p((card_num - self.handCardNum / 2 + card_num1 * 3 * 0.7 + card_num1 * self.PengCardOffset) * size.width + handCardOffsetFor13, 0)
        end
        
		card:setPosition(pos)
	end
end

function SMCardLayer:setGangPicState(enable)
	-- 不显示右边的杠
	self.node.gang_pic_btn:hide()
end

-- 房间规则信息
function SMCardLayer:HelpPicClick()
	print("HelpPicClick..........................")
	self.part:showHelpInfo()
end

function SMCardLayer:showHelpInfoBtn()
	print("showHelpInfoBtn..........................")
	self.node.gang_pic_btn:show()
end

-- 获取闪电特效要播放的位置
function SMCardLayer:getLightningEffecPlayPos(viewId)
    local pos = cc.p(0.0, 0.0)
    if self.node["ocard_node" .. viewId] then
        pos = cc.p(self.node["ocard_node" .. viewId])
    end
    return pos
end

function SMCardLayer:showHuAnimate(viewId,maList)
	-- body
    local hueffect_node = self.node["zcard_node_" .. viewId];
	local hueffect = self.node["hueffect_node_" .. viewId];
	local husprite = self.node["hu_sprite_" .. viewId];
	local nodeeffect = self.node["Node_effec_" .. viewId];
	
	-- 显示背景
	self.node.hu_sprite_parent:show();
	self.node.Image_huAnimationBg:show();

    -- 胡的特效缩放（策划需求）
	husprite:setPosition(hueffect:getPosition());
	husprite:show()

    -- local winSize = cc.Director:getInstance():getWinSize()
    -- self.node.Image_huAnimationBg:setScale(1.0)
    -- self.node.Image_huAnimationBg:setContentSize(cc.size(winSize.width * 1.5, winSize.height * 1.5))

	nodeeffect:setPosition(hueffect_node:getPosition());
    nodeeffect:show();

	self.node.animation:play("hu_animate",false)
	if self.timer == nil then
		self.timer = self:schedulerFunc(function() 
			if self.timer ~= nil then
				self:unScheduler(self.timer)
				self.timer = nil;
			end
			self:shakeScreen(nodeeffect);
		 end,0.9,false)
		
		local sex = self.part:getPlayerInfo(viewId).sex
		local seat_id = self.part:getPlayerInfo(viewId).seat_id
		self:playOperateEffect(MahjongOperation.PLAYER_HU_CONFIRMED,sex,seat_id)
	end
end

-- 振屏
function SMCardLayer:shakeScreen(Node_effec)
	-- local tableSize = self.part.owner.view.node.bg:getParent():getContentSize();
	-- self.part.owner.view.node.bg:getParent():setAnchorPoint(0.5, 0.5);
	-- self.part.owner.view.node.bg:getParent():setPosition(cc.p(tableSize.width / 2, tableSize.height / 2));
	
	-- local cardSize = self.part.owner.view.node.bg:getParent():getContentSize();
	-- -- Node_effec:getParent():setAnchorPoint(0.5, 0.5);
	-- -- Node_effec:getParent():setPosition(cc.p(cardSize.width / 2, cardSize.height / 2));
	
	-- local actions = {
		-- cc.Sequence:create(cc.ScaleTo:create(0.1,0.95),cc.ScaleTo:create(0.1, 1)),
	-- }
	-- local seq = transition.sequence(actions)
	-- transition.execute(self.part.owner.view.node.bg:getParent(), seq,{removeSelf= false,onComplete=function() 
		-- -- self.part.owner.view.node.bg:getParent():setAnchorPoint(0, 0);
		-- self.part.owner.view.node.bg:getParent():setPosition(cc.p(0, 0));
		-- self.node.Image_huAnimationBg:hide();
	-- end})
		 
	-- local action1 = {
		-- cc.Sequence:create(cc.ScaleTo:create(0.1,0.95), cc.ScaleTo:create(0.1, 1)),
	-- }
	-- local seq1 = transition.sequence(action1)
		 
	-- transition.execute(Node_effec:getParent(), seq1,{removeSelf= false,onComplete=function() 
		-- Node_effec:getParent():setAnchorPoint(0, 0);
		-- Node_effec:getParent():setPosition(cc.p(0, 0));
	-- end})
	
    -- 注销时间2017年3月27日16:11:09
--	local maxCount = 10;
--	local count = 0;
--	if self.shakeTimer == nil then
--		self.shakeTimer = self:schedulerFunc(function() 
--			if count >= maxCount then
--				self:unScheduler(self.shakeTimer)
--				self.shakeTimer = nil;
--				Node_effec:getParent():setPosition(cc.p(0, 0));
--			end

--			Node_effec:getParent():setPosition(cc.p((math.random(0, 10) - 5), math.random(0, 10) - 5));
--			count = count + 1;
--		 end,0.016,false)
--	end
end

-- 重置自己的手牌和碰杠的牌
function SMCardLayer:refreshMyCard(hcardList, dcardList, ocardList)
    -- body
    -- self:removeCurOutCard(RoomConfig.MySeat)
    self.node["hcard_node" .. RoomConfig.MySeat]:removeAllChildren()
    self:resetDownCard(RoomConfig.MySeat, dcardList)
    self:resetHandCard(RoomConfig.MySeat, hcardList)
    self:resetOutCard(RoomConfig.MySeat, ocardList)
    self:sortHandCard(RoomConfig.MySeat)

    -- self.node.marker:hide()
end

return SMCardLayer