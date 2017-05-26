-- local BasePart = require("packages.mvc.BasePart")
local CURRENT_MODULE_NAME = ...
local HelpPart = class("HelpPart",cc.load('mvc').PartBase) --登录模块
HelpPart.DEFAULT_VIEW = "HelpLayer"

--[
-- @brief 构造函数
--]
function HelpPart:ctor(owner)
    HelpPart.super.ctor(self, owner)
    self:initialize()
end

--[
-- @override
--]
function HelpPart:initialize()
	
end

--激活模块
function HelpPart:activate(data)
	HelpPart.super.activate(self,CURRENT_MODULE_NAME)
	self.view:selectChoose(2)--大田/规则的 默认选择在此设值
end

function HelpPart:deactivate()
	if self.view ~= nil then
		self.view:removeSelf()
  		self.view = nil
  	end
end

function HelpPart:selectChoose(rule_type)
	-- body
	self.view:selectChoose(rule_type)
end

function HelpPart:selectrule(rule_type)
	-- body
	self.view:selectrule(rule_type)
end

function HelpPart:getPartId()
	-- body
	return "HelpPart"
end

return HelpPart 