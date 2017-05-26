--
-- Author: Your Name
-- Date: 2016-12-05 22:03:35
--

local CURRENT_MODULE_NAME = ...
local CreateRoomPart = import(".CreateRoomPart")
local LYCreateRoomPart = class("LYCreateRoomPart",CreateRoomPart) --创建房间
LYCreateRoomPart.DEFAULT_VIEW = "LYCreateRoomLayer"

LYCreateRoomPart.PLAYWAY1 = 0x800000 --玩法1 半自摸
LYCreateRoomPart.PLAYWAY2 = 0x1000000 --玩法2 全自摸
--CreateRoomPart.PLAYWAY3 = 3 --玩法3 游金4倍
--CreateRoomPart.PLAYWAY4 = 4 --玩法4 游金5倍

LYCreateRoomPart.YOUJIN1 = 4 --游金4倍
LYCreateRoomPart.YOUJIN2 = 5 --游金5倍

LYCreateRoomPart.PAYWAY   = 0--aa还是平摊

function LYCreateRoomPart:initialize()
	self.super:initialize()
	self.default_pay_way = LYCreateRoomPart.PAYWAY
	self.default_youjin = 1
	self.default_play_way = 1
	
	self.cur_pay_way = self.default_pay_way
	self.cur_youjin = self.default_youjin
	self.cur_play_way = self.default_play_way
end

--激活模块
function CreateRoomPart:activate(data)
	CreateRoomPart.super.activate(self,CURRENT_MODULE_NAME)

   	self.view:setSelectPlayWay(self.default_play_way)
   	self.view:setPayWay(self.default_pay_way)
   	self.view:setSelectYouJin(self.default_youjin)
end

function LYCreateRoomPart:selectPlayWay(type)
	-- body
	self.cur_play_way = type
	self.view:setSelectPlayWay(self.cur_play_way)
end

function LYCreateRoomPart:selectPayWay()
	-- body
	if self.cur_pay_way == 0 then 
		self.cur_pay_way = 1
	else
		self.cur_pay_way = 0
	end
	print("LYCreateRoomPart:selectPayWay" )
	print(self.cur_pay_way)
	self.view:setPayWay(self.cur_pay_way)
end

function LYCreateRoomPart:selectYouJin(type)
	-- body
	print("LYCreateRoomPart:selectYouJin"..type)
	self.cur_youjin = type
	self.view:setSelectYouJin(type)
end

function LYCreateRoomPart:updateDiamondOnPart(type)
	-- body
	local quanCount = CreateRoomPart["TIMAES"..type]
	print("updateDiamondOnPart_quanCount:"..quanCount)
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

	--[[if costDiamond == 1 and type == 4 then
		costDiamond = 16
	end]]

	if quanCount == 4 then
		costDiamond = 28
	elseif quanCount == 8 then
		costDiamond = 48
	elseif quanCount == 16 then
		costDiamond = 80
	end

	if self.cur_pay_way == 1 then
		print("cur_pay_way:", cur_pay_way)
		costDiamond = math.floor(costDiamond / 4)
	end
	print("updateDiamondOnPart_costDiamond:"..costDiamond)
	self.view:updateCostDiamondOnView(costDiamond, type)
end

function LYCreateRoomPart:createGame()
	-- body
	local net_mode = global:getModuleWithId(ModuleDef.NET_MOD)
	local create_vip_room = ycmj_message_pb.CreateVipRoomMsg()
	create_vip_room.roomid = 2012 --vip场，龙岩的roomid
	create_vip_room.gametype = 1

	local quanNum = CreateRoomPart["TIMAES"..self.cur_times]
	print("------------quanNum_LYMJ : ",quanNum)
	create_vip_room.quanNum = quanNum

	--[[local play_way = RoomConfig.Rule[self.cur_play_way]
	if play_way == RoomConfig.Rule[1] then --红中麻将
		--需要修改的地方
		play_way = bit._or(play_way,RoomConfig.RuleMa[self.cur_ma])
		print("this is cur play way_LYMJ:",play_way,RoomConfig.RuleMa[self.cur_ma],RoomConfig.Rule[1])
	else
		print("this is cur play way_LYMJ new")
	end]]

	create_vip_room.rate = (LYCreateRoomPart["YOUJIN"..self.cur_youjin])
	create_vip_room.selectWayNum = (LYCreateRoomPart["PLAYWAY"..self.cur_play_way])
	create_vip_room.payAA = self.cur_pay_way
	self.owner:startLoading()
	net_mode:sendProtoMsg(create_vip_room,MsgDef.MSG_CREATE_VIP_ROOM,SocketConfig.GAME_ID)
	print("createGame:")
	print(LYCreateRoomPart["YOUJIN"..self.cur_youjin])
	print(LYCreateRoomPart["PLAYWAY"..self.cur_play_way])
	print(self.cur_pay_way)
end

return LYCreateRoomPart