-- local BasePart = require("packages.mvc.BasePart")
local CURRENT_MODULE_NAME = ...
local HelpPart = import(".HelpPart")
local SMHelpPart = class("SMHelpPart",HelpPart) 
SMHelpPart.DEFAULT_VIEW = "SMHelpLayer"

--激活模块
function SMHelpPart:activate(data)
	SMHelpPart.super.activate(self,CURRENT_MODULE_NAME)
	self.view:selectChoose(2)--大田/规则的 默认选择在此设值
end

function SMHelpPart:deactivate()
	if self.view ~= nil then
		self.view:removeSelf()
  		self.view = nil
  	end
end

function SMHelpPart:selectChoose(rule_type)
	-- body
	self.view:selectChoose(rule_type)
end

function SMHelpPart:selectrule(rule_type)
	-- body
	self.view:selectrule(rule_type)
end




return SMHelpPart 
