--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local ReadyLayer = import(".ReadyLayer")
local SMReadyLayer = class("SMReadyLayer", ReadyLayer)
local truncateString = import("app.part.commonTools.truncateString")

function SMReadyLayer:ctor(...)
    SMReadyLayer.super.ctor(self, ...)

    self:initData()
end

function SMReadyLayer:hideInviteBtn()
    self.node.invite_btn:hide()
end

function SMReadyLayer:showInviteBtn()
    self.node.invite_btn:show()
end

-- 初始数据
function SMReadyLayer:initData()
    for i = 1, 4 do
        self.node["head_node" .. i]:hide()
        self.node["imageView_offline" .. i]:hide()
        self.node["read_icon" .. i]:hide()
    end    
end

function SMReadyLayer:showPlayer(playerInfo)
	-- body
	if playerInfo.view_id and playerInfo.view_id >= 1 and playerInfo.view_id <= 4 then
        -- 将相对应位置的节点设置为可见状态
        self.node["head_node" .. playerInfo.view_id]:show()
        self.node["imageView_offline" .. playerInfo.view_id]:hide()

        -- 如果不是自己的位置，则判断其是否在牌桌上（自己在牌桌上的话说明自己已经准备好了）
        if playerInfo.view_id ~= RoomConfig.MySeat then
            if 1 == playerInfo.gamestate or nil == playerInfo.gamestate then    -- 在桌上
                self.node["read_icon" .. playerInfo.view_id]:show()
            else    -- 在大厅或者离线
                self.node["read_icon" .. playerInfo.view_id]:hide()
            end
        else
            self.node["read_icon" .. playerInfo.view_id]:show()
        end

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

-- 某玩家上线/离线设置
function SMReadyLayer:offlinePlayer(offlinePos,online)
    local name = self.node['name' .. offlinePos]
    local nodeOffline = self.node['imageView_offline' .. offlinePos]
    local nodeReadyHand = self.node["read_icon" .. offlinePos]
    if online then
        name:setColor( { r = 255, g = 255, b = 255 })
        nodeOffline:hide()
        nodeReadyHand:show()
    else
        name:setColor( { r = 255, g = 0, b = 0 })
        nodeOffline:show()
        nodeReadyHand:hide()
    end
end

return SMReadyLayer
--endregion
