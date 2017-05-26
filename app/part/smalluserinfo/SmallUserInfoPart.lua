-- local BasePart = require("packages.mvc.BasePart")
local CURRENT_MODULE_NAME = ...
local SmallUserInfoPart = class("SmallUserInfoPart",cc.load('mvc').PartBase) --登录模块
SmallUserInfoPart.DEFAULT_PART = {}
SmallUserInfoPart.DEFAULT_VIEW = "SmallUserInfoLayer"
--[
-- @brief 构造函数
--]
function SmallUserInfoPart:ctor(owner)
    SmallUserInfoPart.super.ctor(self, owner)
    self:initialize()
end

--[
-- @override
--]
function SmallUserInfoPart:initialize()

end

--激活模块
function SmallUserInfoPart:activate(player_info , posX , posY , viewId , diamond,isVip)
	SmallUserInfoPart.super.activate(self,CURRENT_MODULE_NAME)
    self.view:setPlayerInfo(player_info , posX , posY , viewId , diamond,isVip)
end

function SmallUserInfoPart:deactivate()
    if self.view == nil then
        return
    else
        self.view:removeSelf()
        self.view = nil
    end
end

function SmallUserInfoPart:getPartId()
	-- body
	return "SmallUserInfoPart"
end

function SmallUserInfoPart:loadHeadImg(url)
    -- body
    local lua_bridge = global:getModuleWithId(ModuleDef.BRIDGE_MOD)
    lua_bridge:startDownloadImg(url,self.view:getHeadNode())
end

--将逻辑座位转换为界面座位
function SmallUserInfoPart:changeSeatToView(seatId) --座位顺时针方向增加 1 - 4
    -- body
    return self.owner:changeSeatToView(seatId)
end

return SmallUserInfoPart
