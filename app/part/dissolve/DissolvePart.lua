-- local BasePart = require("packages.mvc.BasePart")
local CURRENT_MODULE_NAME = ...
local DissolvePart = class("DissolvePart",cc.load('mvc').PartBase) --登录模块
DissolvePart.DEFAULT_VIEW = "DissolveLayer"

--[
-- @brief 构造函数
--]
function DissolvePart:ctor(owner)
    DissolvePart.super.ctor(self, owner)
    self:initialize()
end

--[
-- @override
--]
function DissolvePart:initialize()
	
end

--激活模块
function DissolvePart:activate()
	DissolvePart.super.activate(self,CURRENT_MODULE_NAME)
    self.view:hideDissolveBgNodeWithDelayTimeAction()

	self.view:LayerInit(false)
	print("this is DissolvePart:activate----------------------------------------------------  ")
end

function DissolvePart:setShowFirstState(bState)
    self.view:setShowFirstState(bState)
end

function DissolvePart:deactivate()
	self.view:removeSelf()
  	self.view = nil
  	print("this is DissolvePart:deactivate----------------------------------------------------  ")
end

function DissolvePart:closeClick()
	-- body
	self.view:CloseClick()
end

function DissolvePart:getPlayerInfo(viewId)
	return self.owner:getPlayerInfo(viewId)
end

function DissolvePart:changeSeatToView(seatId)
	return self.owner:changeSeatToView(seatId)
end

function DissolvePart:setData(data , playerList ,m_seat_id)
	--self.view:LayerInit(true)

    self.view:SetData(data , playerList , m_seat_id)

	if data.mCloseStatus == 1 then
        
	else
        self.view:hideDissolveBgNodeWithDelayTimeAction(true)
	end
end

function DissolvePart:showCloseVipRoomTips(playerName,playerIndex)
	-- body
	self.owner:showCloseVipRoomTips(playerName,playerIndex)
end

function DissolvePart:getPartId()
	-- body
	return "DissolvePart"
end

return DissolvePart 