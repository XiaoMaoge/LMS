-- local BasePart = require("packages.mvc.BasePart")
local CURRENT_MODULE_NAME = ...
local LobbyPart = import(".LobbyPart")
local LYLobbyPart = class("LYLobbyPart",LobbyPart) --大厅模块

require("app.model.protobufmsg.ycmj_message_add_pb")

function LYLobbyPart:createRoomClick()
	-- body
	self.cur_select_btn = 1
	local net_mode = global:getModuleWithId(ModuleDef.NET_MOD)
	local req_enter_room = wllobby_message_pb.ReqStartGame()
	req_enter_room.roomid = 2012
	req_enter_room.gametype = 1
	self:startLoading()
	net_mode:sendProtoMsg(req_enter_room,MsgDef.MSG_REQUEST_START_GAME,SocketConfig.GAME_ID)
	-- self:createRoom()
end

function LYLobbyPart:addRoomClick()
	-- body
	self.cur_select_btn = 2
	local net_mode = global:getModuleWithId(ModuleDef.NET_MOD)
	local req_enter_room = wllobby_message_pb.ReqStartGame()
	req_enter_room.roomid = 2012
	req_enter_room.gametype = 1
	self:startLoading()
	net_mode:sendProtoMsg(req_enter_room,MsgDef.MSG_REQUEST_START_GAME,SocketConfig.GAME_ID)
	-- self:createRoom()
end

return LYLobbyPart

