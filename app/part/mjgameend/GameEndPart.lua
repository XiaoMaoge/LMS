-- local BasePart = require("packages.mvc.BasePart")
local CURRENT_MODULE_NAME = ...
local GameEndPart = class("GameEndPart",cc.load('mvc').PartBase) --登录模块
GameEndPart.DEFAULT_PART = {}
GameEndPart.DEFAULT_VIEW = "YNGameEndLayer"
--[
-- @brief 构造函数
--]
function GameEndPart:ctor(owner)
    GameEndPart.super.ctor(self, owner)
    self:initialize()
end

--[
-- @override
--]
function GameEndPart:initialize()
	
end

--激活模块
function GameEndPart:activate(data , tablepos)
	print("GameEndPart", data, data.data);
	GameEndPart.super.activate(self, CURRENT_MODULE_NAME)
	self.view:setData(data , tablepos)
end

function GameEndPart:deactivate()
	self.view:removeSelf()
	self.view = nil
end

function GameEndPart:getPartId()
	-- body
	return "GameEndPart"
end

function GameEndPart:hideBackBtn()
	-- body
	self.view:hideBackBtn()
end

--下一局开始
function GameEndPart:nextGame()
	-- body
	local net_mode = global:getModuleWithId(ModuleDef.NET_MOD)
	local player_table_operation = ycmj_message_pb.PlayerTableOperationMsg()
	player_table_operation.operation = MahjongOperation.GAME_OVER_CONTINUE
	net_mode:sendProtoMsg(player_table_operation,MsgDef.MSG_GAME_OPERATION,SocketConfig.GAME_ID)
	self:deactivate()
	self.owner:nextGame()
end


--返回大厅
function GameEndPart:returnGame()
	-- body
	self:deactivate()
	--self.owner:returnGame()
	self.owner:returnLobby()
end


return GameEndPart 