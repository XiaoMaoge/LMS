-- local BasePart = require("packages.mvc.BasePart")
local CURRENT_MODULE_NAME = ...
local GameManagePart = class("GameManagePart",cc.load('mvc').PartBase) --登录模块
GameManagePart.DEFAULT_VIEW = "GameManageLayer"

--[
-- @brief 构造函数
--]
function GameManagePart:ctor(owner)
    GameManagePart.super.ctor(self, owner)
end

--激活模块
function GameManagePart:activate(data)
	GameManagePart.super.activate(self,CURRENT_MODULE_NAME)
	self.view:setData(data)
end

function GameManagePart:deactivate()
	if self.view then
		self.view:removeSelf()
		self.view = nil
	end
end

function GameManagePart:getPartId()
	return "GameManagePart"
end

function GameManagePart:onDelGame(gameId, callback)
	if self.owner and self.owner.onDelGame then
		self.owner:onDelGame(gameId, callback)
	end
end

function GameManagePart:loadIconImg(url,node)
	-- body
	local lua_bridge = global:getModuleWithId(ModuleDef.BRIDGE_MOD)
	lua_bridge:startDownloadImg(url,node)
end

return GameManagePart 