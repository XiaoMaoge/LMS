local SmallUserInfoLayer = class("SmallUserInfoLayer",cc.load("mvc").ViewBase)
local truncateString = import("app.part.commonTools.truncateString")
--[[
	界面处理需要保证就算是错误数据也做到不崩溃
	在获取到数据的时候进行checkData操作
]]
function SmallUserInfoLayer:onCreate()
	-- body
	self:init("SmallUserInfoLayer")
end

function SmallUserInfoLayer:CloseClick()
    self.part:deactivate()
end


function SmallUserInfoLayer:setPlayerInfo(player_info , posX , posY , viewId , diamond,isVip)
    -- body
    self.node.id:setString(player_info.playerIndex)
    -- 如果玩家名称超过10个字符则截取并添加“...”
    local strName = truncateString:getMaxLenString(player_info.name, 10)
    self.node.name:setString(strName)
    if isVip == false then
        self.node.coin_txt:setString(string_table.gold)
    else
        self.node.coin_txt:setString(string_table.score)
    end
    self.node.coin:setString(player_info.coin)
    self.node.ip:setString(player_info.ip)
    for i,v in ipairs(diamond) do
        local playerPos = self.part:changeSeatToView(i) - 1
        if playerPos == 0 then
            playerPos = 4
        end
        if playerPos == viewId then
            self.node.diamond:setString(v)
        end
    end     

    print("---player_info.headImgUrl : ",player_info.headImgUrl,player_info.targetPlayerName)   
        if player_info.headImgUrl and player_info.headImgUrl ~= "" then
            self.part:loadHeadImg(player_info.headImgUrl)
        elseif player_info.targetPlayerName and player_info.targetPlayerName ~= "" then
            self.part:loadHeadImg(player_info.targetPlayerName)
        end

    local viewId = tostring(viewId)
    local pos = pos
    if viewId == "1" then
        pos =cc.p(posX+270 , posY+100)
    elseif viewId == "2" then
        pos =cc.p(posX-260 , posY)
    elseif viewId == "3" then
        pos =cc.p(posX-250 , posY-90)
    elseif viewId == "4" then
        pos =cc.p(posX+270 , posY)
    end
    self.node.bg:setPosition(pos)
end

function SmallUserInfoLayer:getHeadNode()
    -- body
    return self.node.head_sprite
end

return SmallUserInfoLayer
