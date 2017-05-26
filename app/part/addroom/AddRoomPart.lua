-- local BasePart = require("packages.mvc.BasePart")
local CURRENT_MODULE_NAME = ...
local AddRoomPart = class("AddRoomPart",cc.load('mvc').PartBase) --登录模块
AddRoomPart.DEFAULT_PART = {}
AddRoomPart.DEFAULT_VIEW = "AddRoomLayer"
AddRoomPart.TPYE1 = 1 --创建房间
AddRoomPart.TPYE2 = 2 --推荐人输入
--[
-- @brief 构造函数
--]
function AddRoomPart:ctor(owner)
    AddRoomPart.super.ctor(self, owner)
    self:initialize()
end

--[
-- @override
--]
function AddRoomPart:initialize()
	self.num_list = {}
end

--激活模块
function AddRoomPart:activate(data)
	AddRoomPart.super.activate(self,CURRENT_MODULE_NAME)
	self.num_list = {}
	self.type = data
	self.view:initUI(self.type)
end

function AddRoomPart:deactivate()
	if self.view then
		self.view:removeSelf()
		self.view = nil
		self.num_list = {}
	end
end

function AddRoomPart:getPartId()
	-- body
	return "AddRoomPart"
end

function AddRoomPart:addNum(num)
	-- body
	if #self.num_list < 6 then
		table.insert(self.num_list,num)
		self.view:showNum(table.concat(self.num_list))
		if #self.num_list >= 6 then
			self:addGame()
		end
	end
end

function AddRoomPart:addGame()
	-- body
	if #self.num_list > 0 then
		if self.type == AddRoomPart.TPYE1 then
			local net_mode = global:getModuleWithId(ModuleDef.NET_MOD)
			local enter_vip_room = wllobby_message_pb.ReqStartGame()
				enter_vip_room.roomid = tonumber(table.concat(self.num_list))
				enter_vip_room.gametype = 1
				enter_vip_room.tableid = "enter_room"
				self.owner:startLoading()
				net_mode:sendProtoMsg(enter_vip_room,MsgDef.MSG_ENTER_VIP_ROOM,SocketConfig.GAME_ID)
		elseif self.type == AddRoomPart.TPYE2 then
			local str = tonumber(table.concat(self.num_list))
			self.owner:addReferrerId(str)
			self:deactivate()
		end
	end
end

function AddRoomPart:delNum()
	-- body
	if #self.num_list > 0 then
		table.remove(self.num_list)
		self.view:showNum(table.concat(self.num_list))
	end
end

function AddRoomPart:createGameClick()
	-- body
	self.owner:createRoom()
end

function AddRoomPart:resetNum()
	-- body
	for loop = 1, #self.num_list do
		self:delNum()
	end
end

return AddRoomPart 