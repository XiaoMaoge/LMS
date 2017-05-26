-- local BasePart = require("packages.mvc.BasePart")
local CURRENT_MODULE_NAME = ...
local TipsPart = class("TipsPart",cc.load('mvc').PartBase) --登录模块
TipsPart.DEFAULT_VIEW = "TipsLayer"
TipsPart.ZORDER = 13

--[
-- @brief 构造函数
--]
function TipsPart:ctor(owner)
    TipsPart.super.ctor(self, owner)
    self:initialize()
end

--[
-- @override
--]
function TipsPart:initialize()
	
end

--激活模块
function TipsPart:activate(info)
    self.zorder = TipsPart.ZORDER
    TipsPart.super.activate(self,CURRENT_MODULE_NAME)
	self.view:setInfo(info)
end

function TipsPart:deactivate()
	if self.view then
		self.view:removeFromParent()
		self.view = nil 
	end
end

function TipsPart:getPartId()
	-- body
	return "TipsPart"
end

return TipsPart 