--
-- Author: Your Name
-- Date: 2016-12-08 14:54:30
--

--[[
	龙岩的牌局结束界面处理
--]]

local GameEndLayer = import(".GameEndLayer")
local LYGameEndLayer = class("LYGameEndLayer",GameEndLayer)

function LYGameEndLayer:setData(data , tablepos)
	-- body
	local date_txt =os.date("%Y%m%d %H:%M")
	self.node.time_txt:setString(date_txt)

	if data.selectWayNum ==  RoomConfig.PlayRule[3] then
		self.node.wanfa_text:setString(string_table.ly_ban_zi_mo)
	elseif data.selectWayNum ==  RoomConfig.PlayRule[4] then
		self.node.wanfa_text:setString(string_table.ly_quan_zi_mo)
	end	

	local user = global:getGameUser()
	local m_id = user:getProp("uid")

	for i,v in ipairs(data.players) do
		self.node.result_list:insertDefaultItem(i-1)
		local item = self.node.result_list:getItem(i-1)
		local info_txt = item:getChildByName("info_txt")
		local score_txt = item:getChildByName("score_txt")
		local card_node = item:getChildByName("card_node")
		local card_node1 = item:getChildByName("card_node_1")
		local hu_card = card_node1:getChildByName("hu_card")
		local banker_icon = item:getChildByName("banker_icon")
		local hua_list_node = item:getChildByName("hua_list")
		local info  = v.name .. " " .. v.desc
		info_txt:setString(info)
		score_txt:setString(v.coin)

		if data.dealerpos == v.tablepos then
			banker_icon:show()
		end

		if v.tablepos == tablepos then
			local resource_name = self:getEndType(v)
			self.node.title:ignoreContentAdaptWithSize(true)
			self.node.title:loadTexture(resource_name,1)
		end

		local x_offset = 0
		local content_size = nil 
		if data.downcards[i] ~= nil and data.downcards[i].cards ~= nil then --存在碰杠的牌
			for j,k in ipairs(data.downcards[i].cards) do
				local card_num = 3
				local card_value = {}
				local end_card_value = k.value or k.cardValue  					--字段命名可能不一致 容错

				if k.type == RoomConfig.Peng or k.type == RoomConfig.Chi then
					card_value[1] = bit._and(bit.rshift(end_card_value,0),0xff)
					card_value[2] = bit._and(bit.rshift(end_card_value,8),0xff)
					card_value[3] = bit._and(bit.rshift(end_card_value,16),0xff)
				elseif k.type == RoomConfig.MingGang or k.type == RoomConfig.BuGang or k.type == RoomConfig.AnGang then
					card_num =  4
					card_value[1] = bit._and(end_card_value,0xff)
					card_value[2] = card_value[1]
					card_value[3] = card_value[1]
					card_value[4] = card_value[1]
				end
			
				for m=1,card_num do
					local card = self.card_sprite:createWithData(RoomConfig.MySeat,card_value[m])
					content_size = card:getContentSize()
					content_size.width = content_size.width -2
					local index = m
					local offset_y = 0
				

					x_offset = (index-1+(j-1)*3)*content_size.width-content_size.width/2+(j-1)*content_size.width/10
					local pos = cc.p(x_offset,offset_y)
					if index == 4 then
						index = 2
						offset_y = -content_size.height/10
						pos = cc.p((index-1+(j-1)*3)*content_size.width-content_size.width/2+(j-1)*content_size.width/10,offset_y)
					end
					card:setPosition(pos)
					card_node:addChild(card)
				end
			end
		end

		if x_offset > 0 then
			x_offset = x_offset + content_size.width/3
		end

		--这里显示胡牌
		if data.hucards[i] > 0 then
			card_node1:show()
			local frame_name = self.card_sprite:getFrameName(RoomConfig.MySeat,data.hucards[i])
			hu_card:loadTexture(frame_name,1)

			if data.baocard then
				local bao1 = bit._and(data.baocard,0xff);
				local bao2 = bit._and(bit.rshift(data.baocard,8),0xff)
				if bao1 == data.hucards[i] or bao2 == data.hucards[i] then
					hu_card:setColor({r=255,g=255,b=0})
				end
			end			
		end

		--todo 这里添加花牌列表
		if data.huaList ~= nil then
			for k,v in ipairs(data.huaList[i].cardvalue) do
				local hua_node = hua_list_node:getChildByName("hua" .. k)
				local frame_name = self.card_sprite:getFrameName(RoomConfig.MySeat, v)
				hua_node:loadTexture(frame_name,1)
				hua_node:show()
			end
		end

		--创建手牌
		-- for i,v in ipairs(data.handcard) do
		for j,k in ipairs(data.handcard[i].cardvalue) do
			local card = self.card_sprite:createWithData(RoomConfig.MySeat,k)
			local content_size = card:getContentSize()
			content_size.width = content_size.width -2
			if x_offset == 0 then
				x_offset = -content_size.width
			end
			
			local pos = cc.p(j*content_size.width+x_offset,0)
			card:setPosition(pos)
			card_node:addChild(card)
		end
	end
end

return LYGameEndLayer