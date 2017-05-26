-- local BasePart = require("packages.mvc.BasePart")
local CURRENT_MODULE_NAME = ...
local RecordPart = class("RecordPart",cc.load('mvc').PartBase) --登录模块
RecordPart.DEFAULT_VIEW = "RecordLayer"

--[
-- @brief 构造函数
--]
function RecordPart:ctor(owner)
    RecordPart.super.ctor(self, owner)
    self:initialize()
end

--[
-- @override
--]
function RecordPart:initialize()
	
end

--激活模块
function RecordPart:activate(playerID,name)
	local net_mode = global:getModuleWithId(ModuleDef.NET_MOD)
	net_mode:registerMsgListener(SocketConfig.MSG_GET_VIP_ROOM_RECORD_ACK,handler(self,RecordPart.getVipRoomListMsgAck))

	RecordPart.super.activate(self,CURRENT_MODULE_NAME)
	self.name = name
	self:getVipRoomListMsg(playerID)
end

function RecordPart:deactivate()
	local net_mode = global:getNetManager()
	net_mode:unRegisterMsgListener(SocketConfig.MSG_GET_VIP_ROOM_RECORD_ACK)
	self.view:removeSelf()
 	self.view =  nil
end

function RecordPart:getPartId()
	-- body
	return "RecordPart"
end

function RecordPart:getVipRoomListMsg(playerid)
	print("----send msg MSG_GET_VIP_ROOM_RECORD success : ",playerid)
	local net_manager = global:getNetManager()
	local get_vip_room_list_msg = wllobby_message_pb.GetVipRoomListMsg()

	get_vip_room_list_msg.playerid = playerid
	net_manager:sendProtoMsg(get_vip_room_list_msg,SocketConfig.MSG_GET_VIP_ROOM_RECORD,SocketConfig.GAME_ID)

	self.owner:startLoading()
end

function RecordPart:getVipRoomListMsgAck(data,appId)
	self.owner:endLoading()
	local net_manager = global:getNetManager()
	local get_vip_room_list_msg_ack = wllobby_message_pb.GetVipRoomListMsgAck()
	get_vip_room_list_msg_ack:ParseFromString(data)

	print("----GetVipRoomListMsgAck:",get_vip_room_list_msg_ack)
	self.view:setData(get_vip_room_list_msg_ack,self.name)
end

return RecordPart 