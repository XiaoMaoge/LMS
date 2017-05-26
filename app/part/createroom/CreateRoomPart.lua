-- local BasePart = require("packages.mvc.BasePart")
local CURRENT_MODULE_NAME = ...
local CreateRoomPart = class("CreateRoomPart",cc.load('mvc').PartBase) --登录模块
CreateRoomPart.DEFAULT_PART = {}
CreateRoomPart.DEFAULT_VIEW = "CreateRoomLayer"
CreateRoomPart.TIMAES1 = 4 --4局
CreateRoomPart.TIMAES2 = 8 --8局
CreateRoomPart.TIMAES3 = 16 --16局
CreateRoomPart.TIMAES4 = 32 --32局

CreateRoomPart.PLAYWAY1 = 1 --玩法1 红中随配
CreateRoomPart.PLAYWAY2 = 2 --玩法2 点炮胡牌
CreateRoomPart.PLAYWAY3 = 3 --玩法3 合肥自摸


CreateRoomPart.MA1 = 1 --2个码
CreateRoomPart.MA2 = 2 --4个码
CreateRoomPart.MA3 = 3 --6个码
--[
-- @brief 构造函数
--]
function CreateRoomPart:ctor(owner)
    CreateRoomPart.super.ctor(self, owner)
    self:initialize()
end

--[
-- @override
--]
function CreateRoomPart:initialize()
	self.default_times = 1
	self.default_play_way = CreateRoomPart.PLAYWAY1
	self.default_ma = CreateRoomPart.MA1

	self.cur_times = self.default_times
	self.cur_play_way = self.default_play_way
	self.cur_ma = self.default_ma
end

--激活模块
function CreateRoomPart:activate(data)
	CreateRoomPart.super.activate(self,CURRENT_MODULE_NAME)

   	self.view:setSelectTimes(self.default_times)
   	self.view:setSelectPlayWay(self.default_play_way)
   	self.view:setSelectMa(self.default_ma)
end

function CreateRoomPart:deactivate()
	self.view:removeSelf()
	self.view = nil
end

function CreateRoomPart:selectTimes(type)
	-- body
	self.cur_times = type
	self.view:setSelectTimes(self.cur_times)
	self:updateDiamondOnPart(self.cur_times)
end

function CreateRoomPart:selectPlayWay(type)
	-- body
	self.cur_play_way = type
	self.view:setSelectPlayWay(self.cur_play_way)
end

function CreateRoomPart:selectMa(type)
	-- body
	self.cur_ma = type
	self.view:setSelectMa(self.cur_ma)
end

function CreateRoomPart:getPartId()
	-- body
	return "CreateRoomPart"
end

function CreateRoomPart:updateDiamondOnPart(type)
	-- body
	local quanCount = CreateRoomPart["TIMAES"..type]
	print("updateDiamondOnPart_quanCount",quanCount)
	--通过圈数 循环遍历服务器的数据，如果相等，则得到对应的消费 钻石个数
	local costDiamond = 1

	local user = global:getGameUser()
    local props = user:getProps()
    local gameConfigList = props["gameplayer" .. SocketConfig.GAME_ID].gameConfigList

    for i,v in ipairs(gameConfigList) do
		local gameParam = gameConfigList[i]
		print("gameParam.paraId,gameParam.valueInt->",gameParam.paraId,gameParam.valueInt)
		if gameParam.paraId == 7001 or gameParam.paraId == 7002 or gameParam.paraId == 7003 or gameParam.paraId == 7004 then
			if quanCount == gameParam.valueInt and gameParam.pro1 then
				costDiamond = gameParam.pro1
			end
		end
	end

	if costDiamond == 1 and type == 4 then
		costDiamond = 16
	end

	--[[
	if quanCount == 4 then
		costDiamond = 2
	elseif quanCount == 8 then
		costDiamond = 4
	elseif quanCount == 16 then
		costDiamond = 8
	elseif quanCount == 32 then
		costDiamond = 16
	end
	]]
	self.view:updateCostDiamondOnView(costDiamond)
end

function CreateRoomPart:createGame()
	-- body
	local net_mode = global:getModuleWithId(ModuleDef.NET_MOD)
	local create_vip_room = wllobby_message_pb.CreateVipRoomMsg()
	create_vip_room.roomid = 2002
	create_vip_room.gametype = 1

	local quanNum = CreateRoomPart["TIMAES"..self.cur_times]
	print("------------quanNum : ",quanNum)
	create_vip_room.quanNum = quanNum

	local play_way = RoomConfig.Rule[self.cur_play_way]
	if play_way == RoomConfig.Rule[1] then --红中麻将
		play_way = bit._or(play_way,RoomConfig.RuleMa[self.cur_ma])
		print("this is cur play way:",play_way,RoomConfig.RuleMa[self.cur_ma],RoomConfig.Rule[1])
	end
	create_vip_room.selectWayNum = play_way
	net_mode:sendProtoMsg(create_vip_room,MsgDef.MSG_CREATE_VIP_ROOM,SocketConfig.GAME_ID)
end

return CreateRoomPart 