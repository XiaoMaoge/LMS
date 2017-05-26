-- local BasePart = require("packages.mvc.BasePart")
local CURRENT_MODULE_NAME = ...
local VipOverPart = class("VipOverPart",cc.load('mvc').PartBase) --登录模块
VipOverPart.DEFAULT_PART = {}
VipOverPart.DEFAULT_VIEW = "VipOverLayer"
--[
-- @brief 构造函数
--]
function VipOverPart:ctor(owner)
    VipOverPart.super.ctor(self, owner)
    self:initialize()
end

--[
-- @override
--]
function VipOverPart:initialize()

end

--激活模块
function VipOverPart:activate(data,tableid)
	--激活模块
    VipOverPart.super.activate(self, CURRENT_MODULE_NAME)
    self:vipOverDataInfo(data,tableid)

end

function VipOverPart:vipOverDataInfo(data,tableid)
    local length = #(data.players)

    for k,v in ipairs(data.players) do
        if v.vipoverdata then
            self:vipOverDataDeal(v , v.vipoverdata , k , tableid , data.winPos , length)
        end
    end
end

function VipOverPart:vipOverDataDeal(data ,vipoverdata ,index , tableid , winPos , length)
    print("-----------------VipOverPart")
    local dianpao = vipoverdata.dianpaocount
    local hithorsecount = vipoverdata.hithorsecount
    local vipoverdata = {}
    vipoverdata.dianpaoCount = dianpao
    vipoverdata.ming_gang = bit._and(bit.rshift(hithorsecount,8),0xff)
    vipoverdata.an_gang = bit._and(bit.rshift(hithorsecount,16),0xff)
    vipoverdata.hit_horse = bit._and(bit.rshift(hithorsecount,0),0xff)

    print("VipOverPart : ",vipoverdata.dianpaoCount,vipoverdata.ming_gang,vipoverdata.an_gang,vipoverdata.hit_horse)

    self.view:setPlayerInfo(data , vipoverdata , index , tableid , winPos ,length)
end

function VipOverPart:returnGame()
    -- body
    local net_mode = global:getModuleWithId(ModuleDef.NET_MOD)
    local opt_msg = ycmj_message_pb.PlayerGameOpertaion()
    opt_msg.opid = GameOperation.PLAYER_LEFT_TABLE
    net_mode:sendProtoMsg(opt_msg,MsgDef.MSG_GAME_OPERATION,SocketConfig.GAME_ID)
    self:deactivate()
    self.owner:returnGame()
end

function VipOverPart:loadHeadImg(url,node)
    -- body
    local lua_bridge = global:getModuleWithId(ModuleDef.BRIDGE_MOD)
    lua_bridge:startDownloadImg(url,node)
end

function VipOverPart:deactivate()
    self.view:removeSelf()
    self.view =  nil
end

function VipOverPart:getPartId()
	-- body
	return "VipOverPart"
end

return VipOverPart
