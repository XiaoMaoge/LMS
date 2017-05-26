local CardLayer = class("CardLayer",cc.load("mvc").ViewBase)
local CURRENT_MODULE_NAME = ...
--[[
	界面处理需要保证就算是错误数据也做到不崩溃
	在获取到数据的时候进行checkData操作
]]
CardLayer.GetCardOffsetX = 1/5 --摸牌的位置偏移量
CardLayer.OutCardOffset = 6/5 --出牌位置偏移量
CardLayer.OutCardSortOffsetCol = 2/3 --出牌位置排列列偏移量
CardLayer.OutCardSortOffsetRow = 4/5 --出牌位置排列行偏移量
CardLayer.PengCardOffset = 1/3 --碰杠的偏移量
CardLayer.GangCardOffset = 1/6 --杠的牌的y轴偏移量
CardLayer.OutCardCol = 9 --出牌队列有多少列
CardLayer.OutCardRow = 2 --出牌队列有多少行
CardLayer.StandCardOffset = 1/6 --立起的牌的偏移量
CardLayer.OutCardTime = 0.05 --出牌时间
CardLayer.AddCardTime = 0.0
CardLayer.fLiftCardOffsetY = 0.2        -- 向上提起牌的Y坐标的偏移量（牌的高的百分比）


function CardLayer:onCreate()
	-- body
	self:init("CardLayer")
	self.card_list = {}
	self.card_list[RoomConfig.HandCard] = {} --手牌队列
	self.card_list[RoomConfig.DownCard] = {} --碰杠队列
	self.card_list[RoomConfig.OutCard] = {} --出牌队列

    self.tableLiftCardValueAndPos = { }     -- 储存提起牌的值与未被提起的位置
    self.fSelectOutCardBeganPosX = 0.0      -- 选择的要出的牌的x坐标（用于取消选择的该牌时恢复X坐标）
    self.fSelectOutCardBeganPosY = 0.0      -- 选择的要出的牌的y坐标(用于判断选中的牌是否向上拖动)
    self.bSelectOutCardMoved = false        -- 要选择的牌是否被移动了
    self.iSelectCardLocalZOrder = 0         -- 选择的牌的ZOrder

 	for i=1,RoomConfig.TableSeatNum do
 		self.card_list[RoomConfig.HandCard][i] = {} --手牌队列
		self.card_list[RoomConfig.DownCard][i] = {} --碰杠队列
		self.card_list[RoomConfig.OutCard][i] = {} --出牌队列
 	end
 	self.last_out_card = {} --出牌列表
	self._touchListener = cc.EventListenerTouchOneByOne:create()
    self._touchListener:setSwallowTouches(false)
    self._touchListener:registerScriptHandler(handler(self, CardLayer.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
    self._touchListener:registerScriptHandler(handler(self, CardLayer.onTouchMoved), cc.Handler.EVENT_TOUCH_MOVED)
    self._touchListener:registerScriptHandler(handler(self, CardLayer.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED)
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._touchListener, self)

    self.card_touch_enable = false --是否可以点击牌
    self.select_card = {} --当前选择的牌的信息
    self.out_line = 0 --出牌的线超过这个位置就是出牌
    self.node.root:runAction(self.node.animation)
  	self.card_factory = import(".CardFactory",CURRENT_MODULE_NAME)
  	self.card_factory:init(self.res_base)
  	self.node.ma_list1:setItemModel(self.node.ma_panel)
  	self.node.ma_list1:hide()
  	if self.node.opt_card_list then
        self.node.opt_card_list:addEventListener(handler(self,CardLayer.optListEvent))
  	end
  	self:setGangPicState(false)

    -- 设置不吞噬触控事件
    self.node.bao_select_layer:setSwallowTouches(false)

end


function CardLayer:PengClick()
	-- body
	self.part:requestOpt(MahjongOperation.PENG)
	self:hideOpt()
	self.card_touch_enable = false
end

function CardLayer:GangClick()
	-- body
	self.part:requestOpt(MahjongOperation.MING_GANG)
	self:hideOpt()
	self.card_touch_enable = false
	self:setGangPicState(false)
end

function CardLayer:GuoClick()
	-- body
	self.part:requestOpt(MahjongOperation.CANCEL)
	self:sortHandCard(RoomConfig.MySeat) --放下举起的牌
	self:hideOpt()
	self.card_touch_enable = true
end

function CardLayer:HuClick()
	-- body
end

function CardLayer:ChiClick()
	-- body
	self.part:doChiClick()
	self.card_touch_enable = false
end

function CardLayer:hideOpt()
	-- body
	self.node.gang_btn:hide()
	self.node.gang_btn1:hide()
	self.node.peng_btn:hide()
	self.node.guo_btn:hide()
	self.node.opt_card_list:hide()
	self.node.chi_list:hide()

	self.node.ma_list1:hide() --隐藏掉 杠的单个选择列表
	self.node.ma_list2:hide() --隐藏掉 杠的组合选择列表

	self.node.baoSelect1:hide()
	self.node.baoSelect2:hide()
	print("this is hide opt ---------------------------------------------")
end

function CardLayer:refreshOtherCard(viewId,cardList)
	-- body
	local card_list = self.card_list[RoomConfig.HandCard][viewId]
	for i,v in ipairs(card_list) do
		v.card_sprite:removeSelf()
	end
	self.card_list[RoomConfig.HandCard][viewId] = {}

	local num = #cardList
	local num1 = RoomConfig.HandCardNum-num --#self.card_list[RoomConfig.DownCard][viewId]
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

		local card_panel = {
			card_sprite = card,
			card_value = v,
			card_pos = cc.p(card:getPosition())
		}

		table.insert(self.card_list[RoomConfig.HandCard][viewId],card_panel)
	end
end

--重新设置手牌
function CardLayer:resetHandCard(viewId,cardList)
	-- body
	------------删除手牌重新生成手牌数据
	self.card_list[RoomConfig.HandCard][viewId] = {}

	local num = #cardList
	for i,v in ipairs(cardList) do --计算牌的位置
		local pos = nil
		local card = self.card_factory:createWithData(viewId,v,true)--self:createHandCard(v.view_id,v.value[i])
		local size = card:getContentSize()
		size.width = size.width - 2
		-- if v.view_id == RoomConfig.MySeat then --有数据的手牌
		pos = cc.p((i-num/2-1-self.GetCardOffsetX)*size.width,0)
		if viewId == RoomConfig.MySeat then
			card:addTouchEventListener(handler(self,CardLayer.touchCardEvent)) --自己的牌需要添加触碰事件
		end
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
function CardLayer:resetDownCard(viewId,cardList)
	-- body
    local card_list = self.card_list[RoomConfig.DownCard][viewId]
	self.card_list[RoomConfig.DownCard][viewId] = {}
	local card_data = {}
	for i,v in ipairs(cardList) do
		local peng_card_list = {} --碰杠的牌以表结构保存
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
			card_data = {mcard={c1,c1,c1,c1}}
			local pos1 = nil
			local pos2 = nil
			local pos3 = nil
			local pos4 = nil
			local size = card1:getContentSize()
			if viewId == RoomConfig.MySeat then --有数据的手牌
				size.width = size.width * 1.42
				size.width = size.width - 2
				pos1 = cc.p((-RoomConfig.HandCardNum/2-0.5+(1+(i-1)*3+self.PengCardOffset)*0.7-self.GetCardOffsetX)*size.width+ (i -2)*self.PengCardOffset*size.width,0)
				pos2 = cc.p((-RoomConfig.HandCardNum/2-0.5+(2+(i-1)*3+self.PengCardOffset)*0.7-self.GetCardOffsetX)*size.width+ (i -2)*self.PengCardOffset*size.width,0)
				pos3 = cc.p((-RoomConfig.HandCardNum/2-0.5+(3+(i-1)*3+self.PengCardOffset)*0.7-self.GetCardOffsetX)*size.width+ (i -2)*self.PengCardOffset*size.width,0)
				pos4 = cc.p((-RoomConfig.HandCardNum/2-0.5+(2+(i-1)*3+self.PengCardOffset)*0.7-self.GetCardOffsetX)*size.width+ (i -2)*self.PengCardOffset*size.width,0+size.height * self.GangCardOffset)
			elseif viewId == RoomConfig.DownSeat then
				pos1 = cc.p(0,(-RoomConfig.HandCardNum/2)*size.height*self.OutCardSortOffsetCol - (1-(i-1)*3)*size.height*self.OutCardSortOffsetCol + (i -2)*self.PengCardOffset*size.height)
				pos2 = cc.p(0,(-RoomConfig.HandCardNum/2)*size.height*self.OutCardSortOffsetCol - (2-(i-1)*3)*size.height*self.OutCardSortOffsetCol + (i -2)*self.PengCardOffset*size.height)
				pos3 = cc.p(0,(-RoomConfig.HandCardNum/2)*size.height*self.OutCardSortOffsetCol - (3-(i-1)*3)*size.height*self.OutCardSortOffsetCol + (i -2)*self.PengCardOffset*size.height)
				pos4 = cc.p(0,(-RoomConfig.HandCardNum/2)*size.height*self.OutCardSortOffsetCol - (2-(i-1)*3)*size.height*self.OutCardSortOffsetCol + (i -2)*self.PengCardOffset*size.height+size.width * self.GangCardOffset)
			elseif viewId == RoomConfig.FrontSeat then
				size = cc.size(size.width*0.7,size.height*0.7)
				pos1 =cc.p((-RoomConfig.HandCardNum/2 - 1)*size.width+(1+(i-1)*3+self.PengCardOffset)*size.width+(i -2)*self.PengCardOffset*size.width,0)
				pos2 =cc.p((-RoomConfig.HandCardNum/2 - 1)*size.width+(2+(i-1)*3+self.PengCardOffset)*size.width+(i -2)*self.PengCardOffset*size.width,0)
				pos3 =cc.p((-RoomConfig.HandCardNum/2 - 1)*size.width+(3+(i-1)*3+self.PengCardOffset)*size.width+(i -2)*self.PengCardOffset*size.width,0)
				pos4 =cc.p((-RoomConfig.HandCardNum/2 - 1)*size.width+(2+(i-1)*3+self.PengCardOffset)*size.width+(i -2)*self.PengCardOffset*size.width,0+size.height * self.GangCardOffset)
				card:setScale(0.7)
			elseif viewId == RoomConfig.UpSeat then
				pos1 = cc.p(0,(RoomConfig.HandCardNum/2+0.5)*size.height*self.OutCardSortOffsetCol-(1+(i-1)*3)*size.height*self.OutCardSortOffsetCol - (i -2)*self.PengCardOffset*size.height)
				pos2 = cc.p(0,(RoomConfig.HandCardNum/2+0.5)*size.height*self.OutCardSortOffsetCol-(2+(i-1)*3)*size.height*self.OutCardSortOffsetCol - (i -2)*self.PengCardOffset*size.height)
				pos3 = cc.p(0,(RoomConfig.HandCardNum/2+0.5)*size.height*self.OutCardSortOffsetCol-(3+(i-1)*3)*size.height*self.OutCardSortOffsetCol - (i -2)*self.PengCardOffset*size.height)
				pos4 = cc.p(0,(RoomConfig.HandCardNum/2+0.5)*size.height*self.OutCardSortOffsetCol-(2+(i-1)*3)*size.height*self.OutCardSortOffsetCol - (i -2)*self.PengCardOffset*size.height+size.width * self.GangCardOffset)
			end

			card1:setPosition(pos1)
			card2:setPosition(pos2)
			card3:setPosition(pos3)
			card4:setPosition(pos4)
			self.node["hcard_node" .. viewId]:addChild(card1)
			self.node["hcard_node" .. viewId]:addChild(card2)
			self.node["hcard_node" .. viewId]:addChild(card3)
			self.node["hcard_node" .. viewId]:addChild(card4)
			table.insert(peng_card_list,card1)
			table.insert(peng_card_list,card2)
			table.insert(peng_card_list,card3)
			table.insert(peng_card_list,card4)
			table.insert(self.card_list[RoomConfig.DownCard][viewId],{card_sprite=peng_card_list,card_value=card_data}) --碰杠牌的数据结构
		elseif v.type  == RoomConfig.Peng or v.type == RoomConfig.Chi then --直接使用数据创建三张牌
			local card_value = v.cardValue  -- 字段命名可能不一致
			local c1 = bit._and(card_value,0xff)
			local c2 = bit._and(bit.rshift(card_value,8),0xff)
			local c3 = bit._and(bit.rshift(card_value,16),0xff)
			card_data = {mcard={c1,c2,c3}}
			print("this is create peng card :",c1,c2,c3)
			local card1 = self.card_factory:createDownCardWithData(viewId,c1)
			local card2 = self.card_factory:createDownCardWithData(viewId,c2)
			local card3 = self.card_factory:createDownCardWithData(viewId,c3)

			local size = card1:getContentSize()
			local pos1 = nil
			local pos2 = nil
			local pos3 = nil
			if viewId == RoomConfig.MySeat then 
				size = card1:getContentSize() --获取第一张手牌的大小计算碰杠牌的位置
				size.width = size.width * 1.42
				size.width = size.width - 2
				pos1 = cc.p((-RoomConfig.HandCardNum/2-0.5+(1+(i-1)*3+self.PengCardOffset)*0.7-self.GetCardOffsetX)*size.width + (i-2)*self.PengCardOffset*size.width,0)
				pos2 = cc.p((-RoomConfig.HandCardNum/2-0.5+(2+(i-1)*3+self.PengCardOffset)*0.7-self.GetCardOffsetX)*size.width + (i-2)*self.PengCardOffset*size.width,0)
				pos3 = cc.p((-RoomConfig.HandCardNum/2-0.5+(3+(i-1)*3+self.PengCardOffset)*0.7-self.GetCardOffsetX)*size.width + (i-2)*self.PengCardOffset*size.width,0)
			elseif viewId == RoomConfig.DownSeat then
				pos1 = cc.p(0,(-RoomConfig.HandCardNum/2)*size.height*self.OutCardSortOffsetCol - (1-(i-1)*3)*size.height*self.OutCardSortOffsetCol + (i -2)*self.PengCardOffset*size.height)
				pos2 = cc.p(0,(-RoomConfig.HandCardNum/2)*size.height*self.OutCardSortOffsetCol - (2-(i-1)*3)*size.height*self.OutCardSortOffsetCol + (i -2)*self.PengCardOffset*size.height)
				pos2 = cc.p(0,(-RoomConfig.HandCardNum/2)*size.height*self.OutCardSortOffsetCol - (3-(i-1)*3)*size.height*self.OutCardSortOffsetCol + (i -2)*self.PengCardOffset*size.height)
			elseif viewId == RoomConfig.FrontSeat then
				size = cc.size(size.width*0.7,size.height*0.7)
				pos1 =cc.p((-RoomConfig.HandCardNum/2 - 1)*size.width+(1+(i-1)*3+self.PengCardOffset)*size.width+(i -2)*self.PengCardOffset*size.width,0)
				pos2 =cc.p((-RoomConfig.HandCardNum/2 - 1)*size.width+(2+(i-1)*3+self.PengCardOffset)*size.width+(i -2)*self.PengCardOffset*size.width,0)
				pos3 =cc.p((-RoomConfig.HandCardNum/2 - 1)*size.width+(3+(i-1)*3+self.PengCardOffset)*size.width+(i -2)*self.PengCardOffset*size.width,0)
				card1:setScale(0.7)
				card2:setScale(0.7)
				card3:setScale(0.7)
			elseif viewId == RoomConfig.UpSeat then
				pos1 = cc.p(0,(RoomConfig.HandCardNum/2+0.5)*size.height*self.OutCardSortOffsetCol-(1+(i-1)*3)*size.height*self.OutCardSortOffsetCol - (i -2)*self.PengCardOffset*size.height)
				pos2 = cc.p(0,(RoomConfig.HandCardNum/2+0.5)*size.height*self.OutCardSortOffsetCol-(2+(i-1)*3)*size.height*self.OutCardSortOffsetCol - (i -2)*self.PengCardOffset*size.height)
				pos3 = cc.p(0,(RoomConfig.HandCardNum/2+0.5)*size.height*self.OutCardSortOffsetCol-(3+(i-1)*3)*size.height*self.OutCardSortOffsetCol - (i -2)*self.PengCardOffset*size.height)
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

--重置已经出的牌
function CardLayer:resetOutCard(viewId,cardList)
	-- body
	print("this is reset out card:",viewId,#cardList)
	local card_list = self.card_list[RoomConfig.OutCard][viewId]
	for i,v in ipairs(card_list) do
        if v.card_sprite then
            v.card_sprite:removeSelf()
        end
	end
	self.card_list[RoomConfig.OutCard][viewId] = {}

	for i,v in ipairs(cardList) do
		print("this is reset out card:",v)
		self:addDownCard(viewId,v)
	end
end

--重置自己的手牌和碰杠的牌
function CardLayer:refreshMyCard(hcardList,dcardList,ocardList)
	-- body
	-- self:removeCurOutCard(RoomConfig.MySeat)
	self.node["hcard_node".. RoomConfig.MySeat]:removeAllChildren()
	self:resetDownCard(RoomConfig.MySeat,dcardList)
	self:resetHandCard(RoomConfig.MySeat,hcardList)
	self:resetOutCard(RoomConfig.MySeat,ocardList)
    self:sortHandCard(RoomConfig.MySeat)

	self.node.marker:hide()
end

function CardLayer:showTingCard(value)
	-- body
	local isTing = #value
	if isTing > 0 then
		self.node.ting_node:show()
		self.node.ting_card_list:removeAllChildren()
        --ting_card_list  ting_card_node
		for i,v in ipairs(value) do
			local card = self.card_factory:createWithData(RoomConfig.MySeat,v) 
            -- 需求更改成滑块
--			local content_size = card:getContentSize()
--			local pos = cc.p(content_size.width*i,0)
--			card:setPosition(pos)
            
            card:setScale(0.95)
 			self.node.ting_card_list:addChild(card)
		end
	elseif isTing == 0 then
		self.node.ting_node:hide()
	end
end

--显示/刷新 左上角的2张牌
function CardLayer:refreshBaoCardOnLayer(baoCard)
	-- body
	print("refreshBaoCard2",baoCard,self.node.bao1)
	if baoCard and self.node.bao1 then
		print("refreshBaoCard3")
		local bao1 = bit._and(baoCard,0xff);
		local bao2 = bit._and(bit.rshift(baoCard,8),0xff)
		print("refreshBaoCard4",bao1,bao2)

		local type,value = self.card_factory:decodeValue(bao1)
		local texture_name = string.format("%s/room/resource/mj/mine/M_%s_%d.png",self.res_base, RoomConfig.CardType[type],value)
		print("bao1Name->",texture_name)

		self.node.bao1:loadTexture(texture_name,1)
		self.node.bao1:show()

		type,value = self.card_factory:decodeValue(bao2)
		texture_name = string.format("%s/room/resource/mj/mine/M_%s_%d.png",self.res_base, RoomConfig.CardType[type],value)
		print("bao2Name->",texture_name)

		self.node.bao2:loadTexture(texture_name,1)
		self.node.bao2:show()
	end
end

--显示 2张抓尾的宝牌
function CardLayer:showSelectBaoCardOnLayer(baoCard)
	-- body
	if baoCard then
		local bao1 = bit._and(baoCard,0xff);
		local bao2 = bit._and(bit.rshift(baoCard,8),0xff)

		local type,value = self.card_factory:decodeValue(bao1)
		local texture_name = string.format("%s/room/resource/mj/mine/M_%s_%d.png",self.res_base, RoomConfig.CardType[type],value)
		print("selectbao1Name->",texture_name)

		self.node.baoSelect1:loadTexture(texture_name,1) --baoSelect1
		self.node.baoSelect1:show()

		if(bao2 == 0) then
			bao2 = 1
			print("error:bao2 is 0")
		end

		type,value = self.card_factory:decodeValue(bao2)
		texture_name = string.format("%s/room/resource/mj/mine/M_%s_%d.png",self.res_base, RoomConfig.CardType[type],value)
		print("selectbao2Name->",texture_name)

		self.node.baoSelect2:loadTexture(texture_name,1)
		self.node.baoSelect2:show()

		self.node.baoSelect1:setTouchEnabled(true)
        self.node.baoSelect1:addTouchEventListener(function(sender,eventType)
        	if eventType == ccui.TouchEventType.ended then
               print("touch baoSelect1")
               --[[ --点击抓尾的牌 的处理
                    CCMenuItemSprite* mi=(CCMenuItemSprite*)pSender;
				    long cards=(long)mi->getUserData();
				    CCLog("cards->%ld",cards);
				    
				    PlayerTableOperationMsg msg;
				    
				    msg.operation=MAHJONG_OPERTAION_POP_LAST;//吃听也是发吃给服务器
				    
				    msg.card_value=(int)cards;
				    msg.player_table_pos=m_playerTablePos;
				    msg.unused1 = appGetGlobal()->getRoomId();
				    //
				    appGetConnection()->sendMsg(&msg);
				    
				    //移除
				    remove_operation_menu();
				    ]]

				--点击抓尾的牌 的处理
				--self.node.baoSelect1:hide()
				--self.node.baoSelect2:hide()

				self.part:doBaoCardClick(1)
				self:hideOpt() --在该方法中，隐藏掉 尾牌的选择
				self.card_touch_enable = false

				--local tmpBaoCard = 0x2114
				--self:refreshBaoCardOnLayer(tmpBaoCard)
			end
		end)

		self.node.baoSelect2:setTouchEnabled(true)
        self.node.baoSelect2:addTouchEventListener(function(sender,eventType)
        	if eventType == ccui.TouchEventType.ended then
                print("touch baoSelect2")
                --self.node.baoSelect1:hide()
			    --self.node.baoSelect2:hide()

			    --点击抓尾的牌 的处理
			    self.part:doBaoCardClick(2)
				self:hideOpt()
				self.card_touch_enable = false

			    --local tmpBaoCard = 0x1519
				--self:refreshBaoCardOnLayer(tmpBaoCard)
			end
		end)
		self.card_touch_enable = false
	end
end


--摸牌
function CardLayer:getCard(value)
	-- body
	local card = self.card_factory:createWithData(RoomConfig.MySeat,value,true) --只有自己有摸牌动作
	local size = card:getContentSize()
	local card_num = #self.card_list[RoomConfig.HandCard][RoomConfig.MySeat]
	local card_num1 = #self.card_list[RoomConfig.DownCard][RoomConfig.MySeat]
	size.with = size.width -2
	local pos =cc.p((card_num-RoomConfig.HandCardNum/2+card_num1*2.1+card_num1*self.PengCardOffset)*size.width+120,0)
	card:setPosition(pos)
	-- card:setTag(card_num + 1)
	card:setTag(value)
	card:addTouchEventListener(handler(self,CardLayer.touchCardEvent)) --自己的牌需要添加触碰事件
	self.node.hcard_node1:addChild(card)
	local card_data = {
		card_sprite = card,
		card_value =value,
		card_pos = cc.p(card:getPosition())
	}
	table.insert(self.card_list[RoomConfig.HandCard][RoomConfig.MySeat],card_data)
end

function CardLayer:onTouchBegan(touches,event)
	-- body
    self.bSelectOutCardMoved = false

    if self.select_card.card and self.card_touch_enable == true then
        self.iSelectCardLocalZOrder = self.select_card.card:getLocalZOrder()
        self.select_card.card:setLocalZOrder(999)
    end
	return true
end

function CardLayer:onTouchMoved(touches,event)
	local touch_pos = touches:getLocation()
	print("this is on onTouchMoved:",self.card_touch_enable)
	if self.select_card.card and self.card_touch_enable == true then
		local node_pos = self.node.hcard_node1:convertToNodeSpace(touch_pos)

        self.select_card.card:setPosition(node_pos)
        -- 如果牌被向上提起超过15像素，则认为该牌被向上拖动了
        if math.abs(node_pos.y - self.fSelectOutCardBeganPosY) > 15 and false == self.bSelectOutCardMoved then
            self.bSelectOutCardMoved = true
        end
        -- 如果向上拖动后，玩家又不想出该牌的处理方式
        if math.abs(node_pos.y - self.fSelectOutCardBeganPosY) <= 15 and true == self.bSelectOutCardMoved then
            self.bSelectOutCardMoved = false
        end
	end
end

function CardLayer:onTouchEnded(touches,event)
	-- body
	local touch_pos = touches:getLocation()
	print("this is on Touchended 1 self.select_card.card:",self.card_touch_enable, self.select_card.card)
	if self.select_card.card then
--		if touch_pos.y > self.out_line then
--			self.card_touch_enable = false
--			self.part:requestOutCard(self.select_card.card:getTag())
--			self.select_card.card:hide()

--			self.select_card = {}
--			--print("requestOutCard:", self.select_card.card:getTag());
--		elseif self.select_card.stand == false then --选择的牌要提起
--			local content_size = self.select_card.card:getContentSize()
--			local pos = cc.pAdd(self.select_card.pos,cc.p(0,content_size.height*self.StandCardOffset))
--			self.select_card.card:setPosition(pos)
--			self.select_card.card:setLocalZOrder(0)
--			self.select_card.stand = true
--			print("self.select_card.stand = false:")
--		elseif self.select_card.stand == true then
--			print("self.select_card.stand = true, requestOutCard", self.select_card.card:getTag())
--			self.card_touch_enable = false
--			self.part:requestOutCard(self.select_card.card:getTag())
--			self.select_card.card:hide()
--			self.select_card = {}
--		end
--		self:hideOpt()
        
        self.select_card.card:setLocalZOrder(self.iSelectCardLocalZOrder)
        -- 如果牌向上提起则将牌打出
        if true == self.bSelectOutCardMoved then
            self.bSelectOutCardMoved = false

            self.card_touch_enable = false
            self.part:requestOutCard(self.select_card.card:getTag())
            self.select_card.card:hide()
            self.select_card = { }
        else
            if true == self.select_card.stand then
                -- 如果牌是被提起状态，将牌恢复为原来的位置
                self.card_touch_enable = true
                self.select_card.card:setPosition(cc.p(self.fSelectOutCardBeganPosX, 0.0))
                self.select_card = { }
            elseif false == self.select_card.stand then
                -- 如果牌是未被提起状态，将牌提起
                self.card_touch_enable = true
                local cardSize = self.select_card.card:getContentSize()
                local pos = cc.pAdd(self.select_card.pos, cc.p(0, cardSize.height * self.StandCardOffset))
                self.select_card.card:setPosition(pos)
                self.select_card.card:setLocalZOrder(0)
                self.select_card.stand = true
            end
        end
        self:hideOpt()
	end
	print("this is on Touchended 2:",self.card_touch_enable)
end


-- 展示出牌的动画
function CardLayer:outCard(viewId,value)
	-- body
 	local card = self.card_factory:createWithData(RoomConfig.MySeat,value) --出牌的牌 是用自己的牌的大小来显示的

	local sex = self.part:getPlayerInfo(viewId).sex;
 	local card_type,card_value = self.card_factory:decodeValue(value)
 	self:playCardEffect(card_type , card_value , sex)

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

function CardLayer:showHuCardSp(viewId,value)
	local card = self.card_factory:createWithData(RoomConfig.MySeat,value) --出牌的牌 是用自己的牌的大小来显示的

	local sex = self.part:getPlayerInfo(viewId).sex;
 	local card_type,card_value = self.card_factory:decodeValue(value)
 	self:addChild(card,20)
 	card:setAnchorPoint(cc.p(0.5,0.5))
 	local pos = cc.p(0,0)
 	if viewId == RoomConfig.MySeat then --结束时最后一张牌
		pos = cc.p(640,255)
	elseif viewId == RoomConfig.DownSeat then
		pos = cc.p(960,390)
	elseif viewId == RoomConfig.FrontSeat then
		pos =cc.p(640,577)
	elseif viewId == RoomConfig.UpSeat then
		pos = cc.p(320,390)
	end
	card:setPosition(pos)
end

--移除当前出的牌
function CardLayer:removeCurOutCard(viewId)
	-- body
	if self.last_out_card[viewId] ~= nil then
		self.last_out_card[viewId]:stopAllActions()
		self.last_out_card[viewId]:removeSelf()
		self.last_out_card[viewId] = nil
	end
end


function CardLayer:turnSeat(viewId)
	-- body
	self.select_card = {}
    local smPart = self.part.owner -- self:getPart("TablePart")
	if viewId == RoomConfig.MySeat then --轮到自己操作才能操作牌
        if smPart.no_Touch == true then 
            self.card_touch_enable = false
        else
            self.card_touch_enable = true
        end
        
        self.part.mo_card = false
	    
	else
        self.part.mo_card = true
	    self.card_touch_enable = false
	end

end

--加入一个操作显示
function CardLayer:showAddOpt(optList)
	-- bod
	self.opt_list = optList
	self.node.opt_card_list:removeAllChildren()
  	self.node.opt_card_list:setItemModel(self.node.opt_card_panel)
  	self.node.opt_card_list:show()
  	self.card_touch_enable = true
  	for i,v in ipairs(optList) do
		self.node.opt_card_list:insertDefaultItem(i-1)
		local item = self.node.opt_card_list:getItem(i-1)
		local opt_btn = item:getChildByName("opt_btn")
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
		end
		local texture_name = string.format("%s/room/resource/mj/%s",self.res_base,pic_name)
		opt_btn:loadTexture(texture_name,1)
	end
	self.node.opt_card_list:forceDoLayout()
	self.node.opt_card_list:jumpToPercentHorizontal(100)
end

function CardLayer:setGangPicState(enable)
	-- body
	if self.node.gang_pic_btn then
		if enable then
			self.node.gang_pic_btn:setTouchEnabled(true)
			self.node.gang_pic_btn:setEnabled(true)
		else
			self.node.gang_pic_btn:setTouchEnabled(false)
			self.node.gang_pic_btn:setEnabled(false)
		end
	end
end

function CardLayer:optListEvent(ref,event)
	-- body
	if event == 1 and self.opt_list then
		local cur_select = self.node.opt_card_list:getCurSelectedIndex()
		self.card_touch_enable = false
		self:hideOpt()

        -- 将所有提上来的牌恢复为原来的位置      
        self:resetLiftCardPos()

		self.part:optClick(self.opt_list[cur_select + 1])
		self.opt_list = nil
	end
end

--显示碰杠过操作
-- function CardLayer:showOpt(type,value)
-- 	-- body
-- 	self.card_touch_enable  = false
-- 	if type == RoomConfig.MingGang then
-- 		self.node.gang_btn:show()
-- 		self.node.peng_btn:show()
-- 		self.node.guo_btn:show()
-- 	elseif type == RoomConfig.AnGang or type == RoomConfig.BuGang then
-- 		self.node.gang_btn1:show()
-- 		self.node.guo_btn:show()
-- 	elseif type == RoomConfig.Peng then
-- 		self.node.peng_btn:show()
-- 		self.node.guo_btn:show()
-- 	elseif type == RoomConfig.Hu then --红中麻将自动就胡了
-- 	end

-- 	for i,v in ipairs(self.card_list[RoomConfig.HandCard][RoomConfig.MySeat]) do
-- 		for j,k in ipairs(value.mcard) do
-- 			if v.card_value == k then
-- 				local content_size = v.card_sprite:getContentSize()
-- 				local pos = cc.pAdd(v.card_pos,cc.p(0,content_size.height*self.StandCardOffset))
-- 				v.card_sprite:setPosition(pos)
-- 			end
-- 		end
-- 	end
-- end

--玩家牌被吃碰了移除最后出的牌
function CardLayer:removeLastCard(lastOpt,value)
	-- body
	if self.last_out_card[lastOpt] then
		self:removeCurOutCard(lastOpt)
	end
    
    local out_card = self.card_list[RoomConfig.OutCard][lastOpt]
    local out_card_size = #out_card
    for i=out_card_size,1,-1 do
    	if out_card[i].card_value == value then
			out_card[i].card_sprite:removeSelf()
			table.remove(out_card,i)
			break
		end
    end
end

function CardLayer:showHuAnimate(viewId,maList)
	-- body
	local card_node = self.node["hcard_node" .. viewId]
	local pos = cc.p(card_node:getPosition())
	self.node.hu_sprite:setPosition(pos)
	self.node.hu_sprite:show()
    self.node.animation:setLastFrameCallFunc(function()
    	-- body
    	if #maList > 0 then
	    	self.node.ma_list1:show()
	    	local function addMa(i)
	    		-- body
	    		if i > #maList then
	    			return
	    		end

	    		local type,value = self.card_factory:decodeValue(maList[i])
	    		self.node.ma_list1:insertDefaultItem(i-1)
	    		local item = self.node.ma_list1:getItem(i-1)
	    		local ma = item:getChildByName("ma1")
				local texture_name = string.format("%s/room/resource/mj/mine/M_%s_%d.png",self.res_base, RoomConfig.CardType[type],value)
				print("this is ma:",i,#maList,texture_name,ma)
				ma:loadTexture(texture_name,1)
				ma:fadeIn({time= 0.5,onComplete=function()
					-- body
					addMa(i+1)
				end})
				
	    	end
	    	addMa(1)
		end
    end)
	self.node.animation:play("hu_animate",false)
end

--玩家吃,碰,杠
--value= {mcard={2,3},ocard = 1}
function CardLayer:optCard(viewId,type,value,lastOpt)
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
				pos = cc.p((-RoomConfig.HandCardNum/2-0.5+(index+card_num1*3+self.PengCardOffset)*0.7-self.GetCardOffsetX)*size.width+ (card_num1 -1)*self.PengCardOffset*size.width,offset_y)
			elseif viewId == RoomConfig.DownSeat then
				local offset_y = 0
				local index=  i
				if index == 4 then
					offset_y = size.width * self.GangCardOffset
					index = 2
				end
				pos = cc.p(0,(-RoomConfig.HandCardNum/2)*size.height*self.OutCardSortOffsetCol - (index-card_num1*3)*size.height*self.OutCardSortOffsetCol + (card_num1 -1)*self.PengCardOffset*size.height+offset_y)
			elseif viewId == RoomConfig.FrontSeat then
				local offset_y = 0
				local index=  i
				if index == 4 then
					offset_y = size.height * self.GangCardOffset
					index = 2
				end
				size = cc.size(size.width*0.7,size.height*0.7)
				pos =cc.p((-RoomConfig.HandCardNum/2 - 1.5)*size.width+(index+card_num1*3+self.PengCardOffset)*size.width+(card_num1 -1)*self.PengCardOffset*size.width,0+offset_y)
				card:setScale(0.7)
			elseif viewId == RoomConfig.UpSeat then
				local offset_y = 0
				local index=  i
				if index == 4 then
					offset_y = size.width * self.GangCardOffset
					index = 2
				end
				pos = cc.p(0,(RoomConfig.HandCardNum/2+0.5)*size.height*self.OutCardSortOffsetCol-(index+card_num1*3)*size.height*self.OutCardSortOffsetCol - (card_num1 -1)*self.PengCardOffset*size.height+offset_y)
			end

			card:setPosition(pos)
			self.node["hcard_node" .. viewId]:addChild(card)

			table.insert(peng_card_list,card)
		elseif type == RoomConfig.Peng  or type == RoomConfig.Chi then
			if viewId == RoomConfig.MySeat then --有数据的手牌
				size.width = size.width*1.42
				size.width = size.width - 2
				pos = cc.p((-RoomConfig.HandCardNum/2-0.5+(i+card_num1*3+self.PengCardOffset)*0.7-self.GetCardOffsetX)*size.width + (card_num1-1)*self.PengCardOffset*size.width,0)
			elseif viewId == RoomConfig.DownSeat then
				pos = cc.p(0,(-RoomConfig.HandCardNum/2)*size.height*self.OutCardSortOffsetCol - (i-card_num1*3)*size.height*self.OutCardSortOffsetCol + (card_num1 -1)*self.PengCardOffset*size.height)
			elseif viewId == RoomConfig.FrontSeat then
				size = cc.size(size.width*0.7,size.height*0.7)
				pos =cc.p((-RoomConfig.HandCardNum/2 - 1.5)*size.width+(i+card_num1*3+self.PengCardOffset)*size.width+(card_num1 -1)*self.PengCardOffset*size.width,0)
				card:setScale(0.7)
			elseif viewId == RoomConfig.UpSeat then
				pos = cc.p(0,(RoomConfig.HandCardNum/2+0.5)*size.height*self.OutCardSortOffsetCol-(i+card_num1*3)*size.height*self.OutCardSortOffsetCol - (card_num1 -1)*self.PengCardOffset*size.height)
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

	local sex = self.part:getPlayerInfo(viewId).sex;
	local seat_id = self.part:getPlayerInfo(viewId).seat_id;
	self:playOperateEffect(type , sex , seat_id)

end


function CardLayer:touchCardEvent(touch,event)
	-- body
	print("This is touch card event :",self.select_card.card)
	if self.card_touch_enable == false then
		self.select_card = {}
		return
	end

	if event == 0 then
		if self.select_card.card then --如果有选择牌并且选择的是当前的牌
			if self.select_card.card:getTag() == touch:getTag() and self.select_card.card == touch and self.select_card.stand == true then
				-- print("This is touch card event :",self.select_card.card:getTag(),touch:getTag())
				-- self.select_card.card:setPosition(self.select_card.pos)
                -- 将牌打出
                self.card_touch_enable = false
                self.part:requestOutCard(self.select_card.card:getTag())
                self.select_card.card:hide()
                self.select_card = { }
			else
				self.select_card.card:setPosition(self.select_card.pos)
				self.select_card = {
				card = touch,
				stand  = false, --选择的牌是否立起
				pos = cc.p(touch:getPosition())}
				self.select_card.card:setLocalZOrder(RoomConfig.HandCardNum)

                -- 记录下该麻将的x，y坐标
                self.fSelectOutCardBeganPosX = self.select_card.card:getPositionX()
                self.fSelectOutCardBeganPosY = self.select_card.card:getPositionY()
			end
		else
			self.select_card = {
			card = touch,
			stand  = false, --选择的牌是否立起
			pos = cc.p(touch:getPosition())}
			self.select_card.card:setLocalZOrder(RoomConfig.HandCardNum)
            -- 记录下该麻将的x，y坐标
            self.fSelectOutCardBeganPosX = self.select_card.card:getPositionX()
            self.fSelectOutCardBeganPosY = self.select_card.card:getPositionY()
		end

		-- if self.select_card.card == nil then
		-- 	self.select_card = {
		-- 	card = touch,
		-- 	stand  = false, --选择的牌是否立起
		-- 	pos = cc.p(touch:getPosition())}
		-- 	self.select_card.card:setLocalZOrder(RoomConfig.HandCardNum)
		-- end
	elseif event == 2 then

	end
end

--[[
游戏开始创建手牌
牌摆放的顺序很重要会影响碰杠的牌的摆放
--]]
function CardLayer:createCardWithData(data)
	-- body
	for i,v in ipairs(data) do
		local content_pos = cc.p(self.node["hcard_node" .. v.view_id]:getPosition())
		
		if v.num > RoomConfig.HandCardNum then
			v.num = RoomConfig.HandCardNum
		end
		
		for i=1,v.num do --计算牌的位置
			local pos = nil
			local card = self.card_factory:createWithData(v.view_id,v.value[i],true)--self:createHandCard(v.view_id,v.value[i])
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
function CardLayer:sortHandCard(viewId,optCard)
	-- 手牌
	local card_list = self.card_list[RoomConfig.HandCard][viewId]
	local card_num = #card_list


		--吃碰杠的牌
	local card_list1 = self.card_list[RoomConfig.DownCard][viewId]
	local card_num1 = #card_list1

	print("This is sort hand card:",card_num,card_num1)

	if (optCard and (optCard == RoomConfig.Peng or optCard == RoomConfig.Chi)) or card_num == (RoomConfig.HandCardNum + 1)then --碰完牌要把一张牌放到摸牌位
		local card = card_list[card_num].card_sprite --最后一张牌移位
		-- card:setTag(card_num)
		card_num = card_num - 1
		local size = card:getContentSize()
		size.with = size.width -2
		local pos = cc.p((card_num-RoomConfig.HandCardNum/2+card_num1*3*0.7+card_num1*self.PengCardOffset)*size.width,0)
		card:setPosition(pos)
	end



	for i=1,card_num do
		local v = card_list[i]
		local size = v.card_sprite:getContentSize()
		local pos = nil
		size.width = size.width -2
		-- v.card_sprite:setTag(i) --重新排列索引 
		local start_pos = (-self.GetCardOffsetX-RoomConfig.HandCardNum/2)*size.width --起始点位置
		local down_card_size = ((card_num1*3+self.PengCardOffset)*0.7+card_num1*self.PengCardOffset)*size.width
		if card_num1 == 0 then
				down_card_size = 0
		end
		pos = cc.p(start_pos+down_card_size+(i-1)*size.width,0)--cc.p((card_num1*3*0.7+card_num1*self.PengCardOffset)*size.width + (i-1-RoomConfig.HandCardNum/2-self.GetCardOffsetX)*size.width,0)
		v.card_sprite:setPosition(pos)
		v.card_pos = pos
	end
end



function CardLayer:addDownCard(viewId,value)
	-- body
	local sprite = self.card_factory:createDownCardWithData(viewId,value)--ccui.ImageView:create()
	-- sprite:loadTexture(frame_name,1)
	local card_list = self.card_list[RoomConfig.OutCard][viewId]
	local card_num= #card_list
	local content_size = sprite:getContentSize()
	local col = card_num%self.OutCardCol --当前牌应该放在第几列
	local row = math.floor(card_num/self.OutCardCol)  --当前牌应该放在第几行
	local pos = nil

	if viewId == RoomConfig.MySeat then
		pos = cc.p((col - self.OutCardCol/2)*content_size.width,-row*content_size.height*self.OutCardSortOffsetRow)
	elseif viewId == RoomConfig.DownSeat then
		pos = cc.p(row*content_size.width,(col - self.OutCardCol/2)*content_size.height*self.OutCardSortOffsetCol)
		sprite:setLocalZOrder(self.OutCardCol*self.OutCardRow - (row+1)*col)
	elseif viewId == RoomConfig.FrontSeat then
		pos = cc.p((self.OutCardCol/2-col)*content_size.width,row*content_size.height*self.OutCardSortOffsetRow)
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

			--显示出牌标记位置
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
function CardLayer:addOutCard(viewId,value)
	-- body
	print("CardLayer:addOutCard, viewId, value, self.last_out_card[viewId]", viewId, value, self.last_out_card[viewId])
	if self.last_out_card[viewId] then
		local card_list = self.card_list[RoomConfig.OutCard][viewId]
		local card_num= #card_list
		local sprite = self.card_factory:createDownCardWithData(viewId,value)--ccui.ImageView:create()
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
		local actions = {
					cc.Spawn:create(cc.MoveTo:create(CardLayer.AddCardTime,wold_pos),cc.ScaleTo:create(CardLayer.AddCardTime,0.5)),
				}
		local seq = transition.sequence(actions)
		transition.execute(self.last_out_card[viewId],seq,{removeSelf= false,onComplete=function()
			-- body
			if self.last_out_card[viewId] then
				self:addDownCard(viewId,value)
				self:removeCurOutCard(viewId)
			end
		end})
	end


	
end

--获取播放吃碰杠的坐标
function CardLayer:getOptPos(viewId)
	-- body
	local card = self.card_list[RoomConfig.HandCard][viewId][1].card_sprite
 	local content_size = card:getContentSize()
	local pos = nil
	if viewId == RoomConfig.MySeat then
		pos = cc.p(0,content_size.height*self.OutCardOffset)
	elseif viewId == RoomConfig.DownSeat then
		pos = cc.p(-content_size.width*self.OutCardOffset,0)
	elseif viewId == RoomConfig.FrontSeat then
		pos =cc.p(0,-content_size.height*self.OutCardOffset/2)
	elseif viewId == RoomConfig.UpSeat then
		pos = cc.p(content_size.width*self.OutCardOffset,0)
	end
	return self.node["hcard_node"..viewId],pos
end

--zhongqy 出牌音效
function CardLayer:playCardEffect(card_type , card_value , sex) --牌类型 ， 牌数值 ， 出牌人性别
	global:getAudioModule():playSound("res/sound/dapai.wav",false)

	local sound_type = tostring(card_type)
	local sound_value = tostring(card_value)

	local sex = tostring(sex)  --模拟性别 2：男 其他：女
	local mp3_name
	if sex == "2" then
		if sound_type == "0" then
			mp3_name = string.format("res/sound/man/%dwan.mp3", sound_value)
		elseif sound_type == "1" then
			mp3_name = string.format("res/sound/man/%dtiao.mp3", sound_value)
		elseif sound_type == "2" then
			mp3_name = string.format("res/sound/man/%dtong.mp3", sound_value)
		elseif sound_type == "3" then
			mp3_name = string.format("res/sound/man/zi%d.mp3", sound_value)
		end
	else
		if sound_type == "0" then
			mp3_name = string.format("res/sound/female/g_%dwan.mp3", sound_value)
		elseif sound_type == "1" then
			mp3_name = string.format("res/sound/female/g_%dtiao.mp3", sound_value)
		elseif sound_type == "2" then
			mp3_name = string.format("res/sound/female/g_%dtong.mp3", sound_value)
		elseif sound_type == "3" then
			mp3_name = string.format("res/sound/female/zi%d.mp3", sound_value)
		end
	end
	global:getAudioModule():playSound(mp3_name,false)
end

function CardLayer:playOperateEffect(operate_type , sex , seat) 	--操作类型（胡 碰 杠）出牌人性别 出牌人位置
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


function CardLayer:setAutoOutCard(state)
	-- body
	if state then
        self.node.auto_node:show()
        self:hideOpt()
	else
        self.node.auto_node:hide() 
	end
end

function CardLayer:AutoClick()
	-- body
	self.part:setAutoOutCard(false)
end

function CardLayer:showChiList(chiList)
	--显示可以杠的列表
	print("this is  show chil list ---------------------------------------:",#chiList)
	self.node.chi_list:show()
	self.node.chi_list:removeAllChildren()
	self.node.chi_list:setItemModel(self.node.chiPanel)
	self.card_touch_enable = false
	local size_x = 0
	local size_y = self.node.chi_list:getContentSize().height

	for i,v in ipairs(chiList) do
		self.node.chi_list:insertDefaultItem(i-1)
		local item = self.node.chi_list:getItem(i-1)
		for j,k in ipairs(v) do
			-- local c1 = bit._and(bit.rshift(v,(j-1)*8),0xff)
			local type,value = self.card_factory:decodeValue(k)
    		local ma = item:getChildByName("ma" .. j)
			local texture_name = string.format("%s/room/resource/mj/mine/M_%s_%d.png",self.res_base, RoomConfig.CardType[type],value)
			ma:loadTexture(texture_name,1)

			size_x = size_x + ma:getContentSize().width
		end
		size_x = size_x + 8
	end

	size_x = size_x - 8
	local size = cc.size(size_x,size_y)
	self.node.chi_list:setContentSize(size)

	self.node.chi_list:forceDoLayout()
	self.node.chi_list:jumpToPercentHorizontal(50)
	self.node.chi_list:addEventListener(function(ref,event)
		print("this is chi event listener -----------:",ref,event)
		if event == 1 then
			local select_index = self.node.chi_list:getCurSelectedIndex()
			self.part:sendChilReq(chiList[select_index+1])
			--发送请求吃牌
		end
	end)
end


--杠的同牌不同组合 的选择列表
function CardLayer:showGangList(gangList)
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
			self.part:requestOptCard(RoomConfig.Gang,gangList[select_index+1].cardValue)
		end
	end)
end

--杠的不同牌 单个选择列表
function CardLayer:showGangSelect(gangList)
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
function CardLayer:showOpt(type,value)
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

-- 将可以吃的牌向上提起(只有自己碰牌时才会调用)
function CardLayer:liftCanChiCard()
    -- 防错处理如果有牌被提起则将牌设置成未被提起的状态
    self:resetLiftCardPos()

    -- 获取可以吃牌有多少组
    local tableChiValue = self.part:getChiList()
    local chi_list = { }
    for i = 1, 4 do
        local v = bit._and(bit.rshift(tableChiValue.chicardvalue,(i - 1) * 8), 0xff)
        if v > 0 then
            table.insert(chi_list, v)
        end
    end

    -- 如果存在多组吃，则会使玩家选择吃哪一组牌，此时跳过接下来的提牌的功能
    local iChiCount = table.maxn(chi_list)
    if iChiCount > 2 then
        return
    end

    -- 将牌的位置向上提起
    local tableHandCard = self.card_list[RoomConfig.HandCard][RoomConfig.MySeat]

    local iTempNum1 = 0      -- 记录吃的第一张要碰的牌有多少张，如果有多张则提起最后一张
    local iTempNum2 = 0      -- 记录吃的第二张要碰的牌有多少张，如果有多张则提起最后一张

    for k, v in pairs(tableHandCard) do
        if chi_list[1] == v.card_value then
            iTempNum1 = iTempNum1 + 1
        elseif chi_list[2] == v.card_value then
            iTempNum2 = iTempNum2 + 1
        end
    end
    
    local iCountNum1 = 0
    local iCountNum2 = 0

    for k, v in pairs(tableHandCard) do
        -- 查看self.tableLiftCardValueAndPos表中是否已经提起过该牌，防止吃碰杠冲突,牌被碰提起过一次再次被吃杠提起
        local bIsLift1 = false
        local bIsLift2 = false
        for m, n in pairs(self.tableLiftCardValueAndPos) do
            if n.iPosInHandCard == k and n.iCardValue == chi_list[1] then
                bIsLift1 = true
                break
            end
        end

        for m, n in pairs(self.tableLiftCardValueAndPos) do
            if n.iPosInHandCard == k and n.iCardValue == chi_list[2] then
                bIsLift2 = true
                break
            end
        end

        if false == bIsLift1 then
            if v.card_value == chi_list[1] then
                iCountNum1 = iCountNum1 + 1
                if iCountNum1 == iTempNum1 then
                    local card = v.card_sprite
                    local cardSize = card:getContentSize()
                    local fCardScale = card:getScale()
                    local pos = v.card_pos
                    -- pos.y = pos.y + cardSize.height * fCardScale * self.fLiftCardOffsetY
                    pos.y = cardSize.height * fCardScale * self.fLiftCardOffsetY
                    -- 记录下牌的值以及牌的正常位置(该牌在手牌中的位置、该牌的值、该牌的未被提起的y坐标)
                    local tableTemp = { iPosInHandCard = k, iCardValue = v.card_value, cardPosY = v.card_pos.y, nodeCard = card }
                    local iTableSize = table.maxn(self.tableLiftCardValueAndPos)
                    table.insert(self.tableLiftCardValueAndPos, iTableSize + 1, tableTemp)
                    card:setPositionY(pos.y)
                end
            end
        end

        if false == bIsLift2 then
            if v.card_value == chi_list[2] then
                iCountNum2 = iCountNum2 + 1
                if iCountNum2 == iTempNum2 then
                    local card = v.card_sprite
                    local cardSize = card:getContentSize()
                    local fCardScale = card:getScale()
                    local pos = v.card_pos
                    -- pos.y = pos.y + cardSize.height * fCardScale * self.fLiftCardOffsetY
                    pos.y = cardSize.height * fCardScale * self.fLiftCardOffsetY
                    -- 记录下牌的值以及牌的正常位置(该牌在手牌中的位置、该牌的值、该牌的未被提起的y坐标)
                    local tableTemp = { iPosInHandCard = k, iCardValue = v.card_value, cardPosY = v.card_pos.y, nodeCard = card }
                    local iTableSize = table.maxn(self.tableLiftCardValueAndPos)
                    table.insert(self.tableLiftCardValueAndPos, iTableSize + 1, tableTemp)
                    card:setPositionY(pos.y)
                end
            end
        end

    end
end

-- 将可以碰的牌向上提起(只有自己吃牌时才会调用)
function CardLayer:liftCanPengCard()
    -- 防错处理如果有牌被提起则将牌设置成未被提起的状态
    self:resetLiftCardPos()

    -- 向上提牌的处理
    local tableHandCard = self.card_list[RoomConfig.HandCard][RoomConfig.MySeat]
    local iCardNum = 0      -- 改变量用于提高下面循环的执行效率，找到两张碰的牌之后便不再进行循环
    local iPengValue = self.part:getPengValue()
    for k, v in pairs(tableHandCard) do
        -- 如果手中的牌与碰的牌值一样，牌向上提起
        if v.card_value == iPengValue then
            iCardNum = iCardNum + 1

            -- 查看self.tableLiftCardValueAndPos表中是否已经提起过该牌，防止吃碰杠冲突,牌被吃提起过一次再次被碰杠提起
            local bIsLift = false
            for m, n in pairs(self.tableLiftCardValueAndPos) do
                if n.iPosInHandCard == k and n.iCardValue == iPengValue then
                    bIsLift = true
                    break
                end
            end

            if false == bIsLift then
                local card = v.card_sprite
                local cardSize = card:getContentSize()
                local fCardScale = card:getScale()
                local pos = v.card_pos
                -- pos.y = pos.y + cardSize.height * fCardScale * self.fLiftCardOffsetY
                pos.y = cardSize.height * fCardScale * self.fLiftCardOffsetY
                card:setPositionY(pos.y)

                -- 记录下牌的值以及牌的正常位置(该牌在手牌中的位置、该牌的值、该牌的未被提起的y坐标)
                local tableTemp = { iPosInHandCard = k, iCardValue = iPengValue, cardPosY = v.card_pos.y, nodeCard = card }
                local iTableSize = table.maxn(self.tableLiftCardValueAndPos)
                table.insert(self.tableLiftCardValueAndPos, iTableSize + 1, tableTemp)
            end

        end

        if 2 == iCardNum then
            break
        end
    end
end

-- 将可以杠的牌向上提起
function CardLayer:liftCanGangCard()
    -- 防错处理如果有牌被提起则将牌设置成未被提起的状态
    self:resetLiftCardPos()

    -- 向上提牌的处理
    local tableHandCard = self.card_list[RoomConfig.HandCard][RoomConfig.MySeat]
    local iGangValue = self.part:getGangValue()
    local iCardNum = 0      -- 改变量用于提高下面循环的执行效率，最多找到四张碰的牌之后便不再进行循环
    for k, v in pairs(tableHandCard) do
        -- 如果手中的牌与碰的牌值一样，牌向上提起
        if v.card_value == iGangValue then
            iCardNum = iCardNum + 1

            -- 查看self.tableLiftCardValueAndPos表中是否已经提起过该牌，防止吃碰杠冲突,牌被吃提起过一次再次被碰杠提起
            local bIsLift = false
            for m, n in pairs(self.tableLiftCardValueAndPos) do
                if n.iPosInHandCard == k and n.iCardValue == iGangValue then
                    bIsLift = true
                    break
                end
            end

            if false == bIsLift then
                local card = v.card_sprite
                local cardSize = card:getContentSize()
                local fCardScale = card:getScale()
                local pos = v.card_pos
                -- pos.y = pos.y + cardSize.height * fCardScale * self.fLiftCardOffsetY
                pos.y = cardSize.height * fCardScale * self.fLiftCardOffsetY
                card:setPositionY(pos.y)

                -- 记录下牌的值以及牌的正常位置(该牌在手牌中的位置、该牌的值、该牌的未被提起的y坐标)
                local tableTemp = { iPosInHandCard = k, iCardValue = iGangValue, cardPosY = v.card_pos.y, nodeCard = card }
                local iTableSize = table.maxn(self.tableLiftCardValueAndPos)
                table.insert(self.tableLiftCardValueAndPos, iTableSize + 1, tableTemp)
            end

        end

        if 4 == iCardNum then
            break
        end
    end
end

-- 重置被提起手牌的位置
function CardLayer:resetLiftCardPos()
    if table.maxn(self.tableLiftCardValueAndPos) > 0 then
        for k, v in pairs(self.card_list[RoomConfig.HandCard][RoomConfig.MySeat]) do
            local fPosY = 0.0
            local nodeCard = v.card_sprite
            nodeCard:setPositionY(fPosY)
        end
        self.tableLiftCardValueAndPos = { }
    end
end

return CardLayer
