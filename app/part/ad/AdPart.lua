-- local BasePart = require("packages.mvc.BasePart")
local CURRENT_MODULE_NAME = ...
local AdPart = class("AdPart",cc.load('mvc').PartBase) --登录模块
AdPart.DEFAULT_PART = {}
AdPart.DEFAULT_VIEW = "AdNode"
--[
-- @brief 构造函数
--]
function AdPart:ctor(owner)
    AdPart.super.ctor(self, owner)
    self:initialize()
end

--[
-- @override
--]
function AdPart:initialize()
	
end

--激活模块
function AdPart:activate(node, data)
    
	AdPart.super.activate(self,CURRENT_MODULE_NAME,node)
	self.view:initAdPageView(data)
	-- self:updateAdImg(data)
end

function AdPart:updateAdImg(urllist)
	print("AdPart:updateAdImg")
	print("AdPart:RRRRRRRRRRRRRRRRRRRRRRRRRRRR", urllist)
	for idx,url in ipairs(urllist) do
    	local lua_bridge = global:getModuleWithId(ModuleDef.BRIDGE_MOD)
    	lua_bridge:startDownloadImg(url,self.view:getAdImgNode(idx))			-- wind 容易引起self.view:getHeadNode() CRASH
	end
end

function AdPart:deactivate()
	if self.view then
		self.view:removeSelf()
		self.view = nil
	end
end

function AdPart:getPartId()
	-- body
	return "AdPart"
end

return AdPart 