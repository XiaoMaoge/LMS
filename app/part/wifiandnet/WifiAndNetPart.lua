-- local BasePart = require("packages.mvc.BasePart")
local CURRENT_MODULE_NAME = ...
local WifiAndNetPart = class("WifiAndNetPart",cc.load('mvc').PartBase) --登录模块

WifiAndNetPart.DEFAULT_VIEW = "WifiAndNetNode"
--[
-- @brief 构造函数
--]
function WifiAndNetPart:ctor(owner)
    WifiAndNetPart.super.ctor(self, owner)
    self:initialize()
end

--[
-- @override
--]
function WifiAndNetPart:initialize()
	self.frame_count = 30
end

--激活模块
function WifiAndNetPart:activate(node)
	WifiAndNetPart.super.activate(self, CURRENT_MODULE_NAME,node)
	self.view:startUpdate()
end

function WifiAndNetPart:deactivate()
	self.view:removeSelf()
	self.view =  nil
end

function WifiAndNetPart:getPartId()
	-- body
	return "WifiAndNetPart"
end

function WifiAndNetPart:checkUpdateInfo()
	-- body
	local n_time = os.date("%H:%M")
	self.view:updateTime(n_time)
	local lua_bridge = global:getModuleWithId(ModuleDef.BRIDGE_MOD)
	local battery_status = lua_bridge:getBatteryStatus()
	local net_status = lua_bridge:getNetStatus()
	self.view:updateBattery(battery_status)
	self.view:updateWifi(net_status,100)

end

return WifiAndNetPart 