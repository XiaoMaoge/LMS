local ReadyLayer = class("ReadyLayer",cc.load("mvc").ViewBase)
local truncateString = import("app.part.commonTools.truncateString")
--[[
	界面处理需要保证就算是错误数据也做到不崩溃
	在获取到数据的时候进行checkData操作
]]

function ReadyLayer:onCreate() --传入数据
	-- body
	self:init("ReadyLayer")
end

--显示所有玩家
function ReadyLayer:initPlayer(playerList)
	-- 自己永远是node1
	if playerList then
		for k,v in ipairs(playerList) do
			if k > 4 then
				return
			else
				self:showPlayer(v)
			end
		end

		local player_size = #playerList 
		if player_size >= 4 then --房间满人不需要邀请
			self.node.invite_btn:hide()
		else
			self.node.invite_btn:show()
		end
	end
end

-- 隐藏邀请按钮
function ReadyLayer:hideInviteBtn()
	self.node.invite_btn:hide()
end

function ReadyLayer:showPlayer(playerInfo)
	-- body
	if playerInfo.view_id and playerInfo.view_id >= 1 and playerInfo.view_id <= 4 then
		local head_node = self.node["head_node" .. playerInfo.view_id]
		local name = self.node['name' .. playerInfo.view_id]
		local coin = self.node['coin' .. playerInfo.view_id]
		head_node:show()
        -- 如果玩家名称超过10个字符则截取并添加“...”
        local strName = truncateString:getMaxLenString(playerInfo.name, 10)

		name:setString(strName)
		name:setColor({r=255,g=255,b=255})		--初始化白色
		coin:setString(playerInfo.coin)
		
		if playerInfo.intable == 0 then
            self:offlinePlayer(playerInfo.view_id,false)
		end

		print("---playerInfo.targetPlayerName : ",playerInfo.targetPlayerName)
		print("---playerInfo.headImgUrl : ",playerInfo.headImgUrl)
		if playerInfo.targetPlayerName ~= nil then
			if playerInfo.targetPlayerName and playerInfo.targetPlayerName ~= "" then
				self.part:loadHeadImg(playerInfo.targetPlayerName,head_node)
			end
		else 	
			if playerInfo.headImgUrl and playerInfo.headImgUrl ~= "" then
				self.part:loadHeadImg(playerInfo.headImgUrl,head_node)
			end
		end
	end
end

function ReadyLayer:hidePlayer(num)
	local head_node = self.node["head_node" .. num]
	head_node:hide()
end

function ReadyLayer:offlinePlayer(offlinePos,online)
	local name = self.node['name' .. offlinePos]
	if online then
	   name:setColor({r=255,g=255,b=255})
    else
        name:setColor({r=255,g=0,b=0})
    end
end

function ReadyLayer:setTableID(tableId)
	-- body
	self.node.room_id_txt:setString(string.format(string_table.room_id_txt,tableId))
end

--获取座位坐标列表
function ReadyLayer:getPosTable()
	-- body
	local pos_table = {}
	for i=1,RoomConfig.TableSeatNum do
		local head_node = self.node["head_bg" .. i]
		local head_content = head_node:getContentSize()
		local pos 
		if i == RoomConfig.DownSeat or i == RoomConfig.FrontSeat then
			pos = cc.pSub(cc.p(head_node:getPosition()),cc.p(head_content.width*2/5,0))
		else 
			pos = cc.pAdd(cc.p(head_node:getPosition()),cc.p(head_content.width*4/5,0)) 
		end
		table.insert(pos_table,pos)
	end
	return pos_table
end

function ReadyLayer:showVipInfo()
	-- body
	self.node.vip_layer:show()
end

--邀请好友
function ReadyLayer:InviteFriendsClick()
	-- body
	self.part:inviteFriends()
end

--解散房间
function ReadyLayer:CloseRoomClick()
	-- body
	self.part:closeRoom()
end

function ReadyLayer:MaskClick()
	-- body
	self.part:maskClick()
end

function ReadyLayer:ExitClick()
	self.part:exitClick()
end

-- -- 房间规则信息
-- function ReadyLayer:HelpPicClick()
-- 	print("HelpPicClick..........................");
-- 	-- self.part:showHelpInfo();
-- 	self.part.owner:showHelpInfo();
-- end

return ReadyLayer
