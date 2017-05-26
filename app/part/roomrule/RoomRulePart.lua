-- local BasePart = require("packages.mvc.BasePart")
local CURRENT_MODULE_NAME = ...
local RoomRulePart = class("RoomRulePart",cc.load('mvc').PartBase) --登录模块
RoomRulePart.DEFAULT_VIEW = "RoomRuleLayer"

--[
-- @brief 构造函数
--]
function RoomRulePart:ctor(owner)
    RoomRulePart.super.ctor(self, owner)
    self:initialize()
end

--[
-- @override
--]
function RoomRulePart:initialize()
	
end

--激活模块
function RoomRulePart:activate(quanNum, quanTotal)
	RoomRulePart.super.activate(self,CURRENT_MODULE_NAME)
	self.view:showData(quanNum, quanTotal);
end

function RoomRulePart:deactivate()
	self.view:removeSelf()
 	self.view =  nil
end

function RoomRulePart:getPartId()
	-- body
	return "RoomRulePart"
end

return RoomRulePart 