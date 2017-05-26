-- local BasePart = require("packages.mvc.BasePart")
local CURRENT_MODULE_NAME = ...
local LoadingPart = class("LoadingPart",cc.load('mvc').PartBase) --登录模块
LoadingPart.DEFAULT_VIEW = "LoadingLayer"
LoadingPart.ZORDER = 14

--[
-- @brief 构造函数
--]
function LoadingPart:ctor(owner)
    LoadingPart.super.ctor(self, owner)
    self:initialize()
end

--[
-- @override
--]
function LoadingPart:initialize()
	
end

--激活模块
function LoadingPart:activate(data)
	self.zorder = LoadingPart.ZORDER
	LoadingPart.super.activate(self,CURRENT_MODULE_NAME)
end

function LoadingPart:deactivate()
	if self.view then
		self.view:removeSelf()
		self.view = nil
	end
end

function LoadingPart:getPartId()
	-- body
	return "LoadingPart"
end

return LoadingPart 