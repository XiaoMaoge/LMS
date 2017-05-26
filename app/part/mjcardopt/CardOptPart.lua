-- local BasePart = require("packages.mvc.BasePart")
local CURRENT_MODULE_NAME = ...
local CardOptPart = class("CardOptPart",cc.load('mvc').PartBase) --登录模块
CardOptPart.DEFAULT_PART = {}
CardOptPart.DEFAULT_VIEW = "CardOptNode"
--[
-- @brief 构造函数
--]
function CardOptPart:ctor(owner)
    CardOptPart.super.ctor(self, owner)
    self:initialize()
end

--[
-- @override
--]
function CardOptPart:initialize()
	
end

--激活模块
function CardOptPart:activate(pos,type,node)
	self.view = global:importViewWithName(CURRENT_MODULE_NAME,self.DEFAULT_VIEW,self)
	self.view:setPosition(pos)
    -- self.view:bindPart(self) --界面绑定到当前组件
   	-- if self.owner.view ~= nil then
   	-- 	self.owner.view:addChild(self.view)
   	-- end
   	node:addChild(self.view, 1000)
   	self.view:playAnimate(type)
end

function CardOptPart:deactivate()
    if self.view ~= nil then
    	self.view:removeSelf()
    	self.view =  nil
	end
	print("this is deactivate------:",self.view)
end

local view_id = 2
function CardOptPart:animateOver()
	-- body
	self:deactivate()
	if RoomConfig.Ai_Debug then
		local ai_mode = global:getModuleWithId(ModuleDef.AI_MOD)
		ai_mode:requestOpt(1)
	end
end

function CardOptPart:getPartId()
	-- body
	return "CardOptPart"
end

return CardOptPart 