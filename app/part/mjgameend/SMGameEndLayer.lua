--
-- Author: Your Name
-- Date: 2016-12-08 14:54:30
--

--[[
	云南的牌局结束界面处理
--]]

local GameEndLayer = import(".GameEndLayer")
local SMGameEndLayer = class("SMGameEndLayer",GameEndLayer)
local truncateString = import("app.part.commonTools.truncateString")

function SMGameEndLayer:onCreate()
	-- body
	SMGameEndLayer.super.onCreate(self);
	self.baocard1 = 0;
	self.baocard2 = 0;
	self.baocard_color = {r = 255, g = 255, b = 0};
end

-- 设置宝牌
function SMGameEndLayer:setBaoCard(card, value)
	if card == nil or value == nil then
		return;
	end

	if value == self.baocard1 or value == self.baocard2 then
		card:setColor(self.baocard_color);
	end
end

function SMGameEndLayer:setData(oldData , tablepos)
	-- body
	local date_txt =os.date("%Y%m%d %H:%M")
	self.node.time_txt:setString(date_txt)

	local data = oldData.data;
	--print("SMGameEndLayer", oldData, data);

	self.baocard1 = oldData.baocard;
	-- print(data);
    -- 胡牌的位置
    local iHuPos = oldData.data.huois

	local user = global:getGameUser()
	local m_id = user:getProp("uid")

	for i,v in ipairs(data.players) do
		self.node.result_list:insertDefaultItem(i-1)
		local item = self.node.result_list:getItem(i-1)
		local info_txt = item:getChildByName("info_txt")
		local score_txt = item:getChildByName("score_txt")
        local score_txt_min = item:getChildByName("score_txt_min")
		local card_node = item:getChildByName("card_node")
		local card_node1 = item:getChildByName("card_node_1")
		local hu_card = card_node1:getChildByName("hu_card")
		local banker_icon = item:getChildByName("banker_icon")

        local hu_icon = card_node1:getChildByName("hu_icon")
        local strName = truncateString:getMaxLenString(v.name, 10)
		local info  = strName .. " " .. v.desc
		info_txt:setString(info)

        -- 根据分数的不同显示不同的颜色（负分为红色，非负为绿色）
        if v.coin < 0 then
            score_txt:hide()

            score_txt_min:show()
            score_txt_min:setString(tostring( math.abs(v.coin)))
        else
            score_txt:show()
            score_txt:setString(tostring( math.abs(v.coin)))

            score_txt_min:hide()
        end
        
		if data.dealerpos == v.tablepos then
			banker_icon:show()
        else
            banker_icon:hide()
		end

		if v.tablepos == tablepos then
			local resource_name = self:getEndType(v)
			self.node.title:ignoreContentAdaptWithSize(true)
			self.node.title:loadTexture(resource_name,1)
		end

		local x_offset = 0
		local content_size = nil 
		local gang_num = 0;
		if data.downcards[i] ~= nil and data.downcards[i].cards ~= nil then --存在碰杠的牌
			for j, k in ipairs(data.downcards[i].cards) do
				local card_num = 3
				local card_value = {}


				local end_card_value = k.value or k.cardValue  					--字段命名可能不一致 容错

				if k.type == RoomConfig.Peng or k.type == RoomConfig.Chi then
					card_value[1] = bit._and(bit.rshift(end_card_value,0),0xff)
					card_value[2] = bit._and(bit.rshift(end_card_value,8),0xff)
					card_value[3] = bit._and(bit.rshift(end_card_value,16),0xff)
                elseif k.type == 0x40 then
                    card_num = 2
                    card_value[1] = bit._and(bit.rshift(end_card_value,0),0xff)
					card_value[2] = bit._and(bit.rshift(end_card_value,8),0xff)
				elseif k.type == RoomConfig.MingGang or k.type == RoomConfig.BuGang or k.type == RoomConfig.AnGang then
					card_num =  4
					card_value[1] = bit._and(end_card_value,0xff)
					card_value[2] = card_value[1]
					card_value[3] = card_value[1]
					card_value[4] = card_value[1]
				end
			
				for m=1,card_num do
					local card = nil;
					if k.type == RoomConfig.AnGang and m ~= 4 then
						card = self.card_sprite:createEndCard(nil);
					else
						card = self.card_sprite:createEndCard(card_value[m]);
					end
					content_size = card:getContentSize()
					content_size.width = content_size.width - 2
					local index = m
					local offset_y = 0
				
					self:setBaoCard(card, card_value[m]);
					-- x_offset = (index-1+(j-1)*3)*content_size.width-content_size.width/2+(j-1)*content_size.width/10
					local pos = nil
					if index == 4 then
						index = 2
						offset_y = -content_size.height/10
						pos = cc.p((index-1+(j-1)*3)*content_size.width-content_size.width/2+(j-1)*content_size.width/10,offset_y)
					else
						x_offset = (index-1+(j-1)*3)*content_size.width-content_size.width/2+(j-1)*content_size.width/10
						pos = cc.p(x_offset,offset_y)
					end
					card:setPosition(pos)
					card_node:addChild(card)
				end
			end
		end

		if x_offset > 0 then
			x_offset = x_offset + content_size.width/3
		end

		if data.hucards[i] > 0 then
--			local frame_name = self.card_sprite:getFrameName(RoomConfig.MySeat,data.hucards[i])
--			hu_card:loadTexture(frame_name,1)
--			card_node1:show();
--			self:setBaoCard(hu_card, data.hucards[i]);
            local card = self.card_sprite:createEndCard(data.hucards[i])
            card:setScale(0.7)
            local parent = hu_card:getParent()
            local pos = cc.p(hu_card:getPosition())
            card:setPosition(pos)
            parent:addChild(card)


            hu_icon:show()
        else
            hu_icon:hide()
		end

		--创建手牌
		-- for i,v in ipairs(data.handcard) do
		for j,k in ipairs(data.handcard[i].cardvalue) do
			local card = self.card_sprite:createEndCard(k)
			local content_size = card:getContentSize()
			content_size.width = content_size.width -2
			if x_offset == 0 then
				x_offset = -content_size.width * 1.5
			end
			
			self:setBaoCard(card, k);
			local pos = cc.p(j*content_size.width+x_offset,0)
			card:setPosition(pos)
			card_node:addChild(card)
		end
	end
end

return SMGameEndLayer