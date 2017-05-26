-- local BasePart = require("packages.mvc.BasePart")
local CURRENT_MODULE_NAME = ...
local CheckHuaPart = class("CheckHuaPart",cc.load('mvc').PartBase) --登录模块
CheckHuaPart.DEFAULT_PART = {}
CheckHuaPart.DEFAULT_VIEW = "CheckHuaLayer"
--[
-- @brief 构造函数
--]
function CheckHuaPart:ctor(owner)
    CheckHuaPart.super.ctor(self, owner)
    self:initialize()
end

--[
-- @override
--]
function CheckHuaPart:initialize()
	self.num_list = {}
end

--激活模块
function CheckHuaPart:activate(data,list)
	CheckHuaPart.super.activate(self,CURRENT_MODULE_NAME)
	self.num_list = {}
	--self.type = data
    if data ~= nil then
	    self.view:initUI(data,list)
    end
end

function CheckHuaPart:deactivate()
	if self.view then
		self.view:removeSelf()
		self.view = nil
		self.num_list = {}
	end
end

function CheckHuaPart:getPartId()
	-- body
	return "CheckHuaPart"
end


return CheckHuaPart 