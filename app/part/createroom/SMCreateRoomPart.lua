-- local BasePart = require("packages.mvc.BasePart")
require("bit")

local CURRENT_MODULE_NAME = ...
local CreateRoomPart = import(".CreateRoomPart")
local SMCreateRoomPart = class("SMCreateRoomPart",CreateRoomPart)
SMCreateRoomPart.DEFAULT_VIEW = "SMCreateRoomLayer"

SMCreateRoomPart.selectStateTab = {}--记录选中状态
SMCreateRoomPart.PAYWAY = 0   --payAA

SMCreateRoomPart.PLAYER_COUNT1 = 4
SMCreateRoomPart.PLAYER_COUNT2 = 3
SMCreateRoomPart.PLAYER_COUNT3 = 2

SMCreateRoomPart.TIMAES1 = 4         --4局
SMCreateRoomPart.TIMAES2 = 8         --8局
SMCreateRoomPart.TIMAES3 = 16        --16局
SMCreateRoomPart.TIMAES4 = 32        --32局


--[[特殊规则说明：用32位的2进制的每一位作为标识,[bit.lshift(1,5)含义：将1向左移5位]
  例子：标签页1 并且 带白板
		self.Cur_Select_Type_Number = 标签页1的定义左移24位 + 1左移1位（也就是：TABLE_FJHJ_RULE_002）
		self.Cur_Select_Type_Number = bit.lshift(self.TABLE_FJHJ_LABEL_1,22+self.TABLE_FJHJ_LABEL_1)+self.TABLE_FJHJ_RULE_002
  ]]

--移位定义
SMCreateRoomPart.BIT_LSHIFT_23 = 23

--标签页定义(此定义要和服务器相匹配)
SMCreateRoomPart.TABLE_FJHJ_LABEL_1  = 1  --标签页1--三明108张不带金
SMCreateRoomPart.TABLE_FJHJ_LABEL_2  = 2  --标签页2--三明和大田112张带金
SMCreateRoomPart.TABLE_FJHJ_LABEL_3  = 3  --标签页3--福州144张


--特殊选择类型定义(此定义要和服务器相匹配)
SMCreateRoomPart.TABLE_FJHJ_RULE_001 = bit.lshift(1,0)  --三明108张不带金（无平胡,不许点炮）
SMCreateRoomPart.TABLE_FJHJ_RULE_002 = bit.lshift(1,1)  --三明108张不带金（点杠包家）
SMCreateRoomPart.TABLE_FJHJ_RULE_003 = bit.lshift(1,2)  --三明108张不带金（带白板）
SMCreateRoomPart.TABLE_FJHJ_RULE_004 = bit.lshift(1,3)  --三明大田112张带金（庄家翻倍）
SMCreateRoomPart.TABLE_FJHJ_RULE_005 = bit.lshift(1,4)  --三明大田112张带金（点炮和牌）
SMCreateRoomPart.TABLE_FJHJ_RULE_006 = bit.lshift(1,5)  --三明大田112张带金（红中补花）
SMCreateRoomPart.TABLE_FJHJ_RULE_007 = bit.lshift(1,6)  --三明16张带金（无平胡）

SMCreateRoomPart.TABLE_FJHJ_RULE_019 = bit.lshift(1,19) --AA支付
SMCreateRoomPart.TABLE_FJHJ_RULE_020 = bit.lshift(1,20) --8局场
SMCreateRoomPart.TABLE_FJHJ_RULE_021 = bit.lshift(1,21) --16局场
SMCreateRoomPart.TABLE_FJHJ_RULE_022 = bit.lshift(1,22) --二人游戏
SMCreateRoomPart.TABLE_FJHJ_RULE_023 = bit.lshift(1,23) -- 三人游戏



--定义全局的 当前的标签页 和 当前的特殊规则类型标识的值(主要为了记录所选值 方便其他地方使用或设置)
SMCreateRoomPart.Cur_Select_Page        = 0             --当前的标签页
SMCreateRoomPart.Cur_Select_Type_Number = 0	            --当前的特殊规则类型标识的值

--单选和多选的标识定义
SMCreateRoomPart.isDuoXuanFlag1	   		= 0				--标签页1是否是多选的标识
SMCreateRoomPart.isDuoXuanFlag2			= 0				--标签页2是否是多选的标识
SMCreateRoomPart.isDuoXuanFlag3			= 0				--标签页3是否是多选的标识
--[
-- @override
--]
function SMCreateRoomPart:activate(data)
	print("SMCreateRoomPart:activate")

	--初始化数据
	self.defualt_pay_way    = self.PAYWAY
	self.cur_player_count   = 1						     --【1是4个人，2是3个人，3是2个人 默认是4人游戏 如何要默认其他几人 需要 将编辑器里的默认值也修改  保证编辑器中 和 self.cur_player_count 要相匹配】
	self.cur_times 			= 1                          --【1是4局，2是8局，3是16局，4是32局，默认是4局】
	self.cur_pay_way 		= self.defualt_pay_way       --【默认支付方式为0】
	self.Cur_Select_Page    = self.TABLE_FJHJ_LABEL_1    --【默认标签页1】
	self.isDuoXuanFlag1     = 1						     --标签页1是否是多选 0为单选 1位多选
	self.isDuoXuanFlag2     = 1						     --标签页2是否是多选 0为单选 1位多选
	self.isDuoXuanFlag3     = 1						     --标签页3是否是多选 0为单选 1位多选

	SMCreateRoomPart.super.activate(self,CURRENT_MODULE_NAME)

	--设置按钮初始状态
   	self.view:setSelectPayWay(self.defualt_pay_way)
   	self.view:setPlayerCount(self.cur_player_count)
   	self.view:setSelectTimes(self.cur_times)
   	self.view:setChooseSelectPageFunc(self.Cur_Select_Page)

   	--默认页变更时,需要给Cur_Select_Type_Number 设不同的初始值
   	if self.Cur_Select_Page == self.TABLE_FJHJ_LABEL_1 then--如果是默认标签页1的处理
   		handCardNumFlag = 13--手牌是13张
   		self.Cur_Select_Type_Number = bit.lshift(1,self.BIT_LSHIFT_23+self.Cur_Select_Page) + self.TABLE_FJHJ_RULE_001 + self.TABLE_FJHJ_RULE_002 + self.TABLE_FJHJ_RULE_003

   		if self.isDuoXuanFlag1 == 0 then--单选
   			self:selectedTypeFunc(1)
   		else--多选
	   		self.selectStateTab[1] = self.TABLE_FJHJ_RULE_001
	   		self.selectStateTab[2] = self.TABLE_FJHJ_RULE_002
	   		self.selectStateTab[3] = self.TABLE_FJHJ_RULE_003
	   	end
   		
   	elseif  self.Cur_Select_Page == self.TABLE_FJHJ_LABEL_2 then     --如果默认标签页2的处理
   		handCardNumFlag = 16--手牌是16张
   		self.Cur_Select_Type_Number = bit.lshift(1,self.BIT_LSHIFT_23+self.Cur_Select_Page) + self.TABLE_FJHJ_RULE_004 + self.TABLE_FJHJ_RULE_006
   		if self.isDuoXuanFlag2 == 0 then
   			--根据策划需求 要单选时在此添加
   		else
   			self.selectStateTab[1] = self.TABLE_FJHJ_RULE_004
   			self.selectStateTab[3] = self.TABLE_FJHJ_RULE_006
   			
   		end

   	elseif  self.Cur_Select_Page == self.TABLE_FJHJ_LABEL_3 then     --如果默认标签页3的处理
   		handCardNumFlag = 16--手牌是16张
   		self.Cur_Select_Type_Number = bit.lshift(1,self.BIT_LSHIFT_23+self.Cur_Select_Page) + self.TABLE_FJHJ_RULE_007
   		if self.isDuoXuanFlag3 == 0 then
   			--根据策划需求 要单选时在此添加
   		else
   			self.selectStateTab[1] = self.TABLE_FJHJ_RULE_007
   			
   		end

   	end
   	--print("选中的规则值："..self.Cur_Select_Type_Number)
end


function SMCreateRoomPart:deactivate()
	self.view:removeSelf()
	self.view = nil
end


--[[function SMCreateRoomPart:selectDefualtPayWay()
	-- body
	self.view:setSelectPayWay(self.defualt_pay_way)
end]]


--选择支付方式
function SMCreateRoomPart:selectPayWay()
	-- body
	if self.cur_pay_way == 0 then 
		self.cur_pay_way = 1
	else
		self.cur_pay_way = 0
	end

	self.view:setSelectPayWay(self.cur_pay_way)
end


--[[function SMCreateRoomPart:selectTimes(type)
	-- body
	self.cur_times = type
	self.view:setSelectTimes(self.cur_times)
end]]


--选择局数
function CreateRoomPart:selectTimes(type)
	-- body
	self.cur_times = type
	if self.Cur_Select_Page == self.TABLE_FJHJ_LABEL_2 then--标签页2的局数处理
		self.view:setSelectTimesExt(self.cur_times + 4)
	elseif self.Cur_Select_Page == self.TABLE_FJHJ_LABEL_3 then--标签页3的局数处理
		self.view:setSelectTimesExt2(self.cur_times + 8)
	else
		self.view:setSelectTimes(self.cur_times)
	end
end


--选择玩家数量
function SMCreateRoomPart:selectPlayerCount(type)
	-- body
	--print("SMCreateRoomPart:selectPlayerCount"..type)
	self.cur_player_count = type
	if self.Cur_Select_Page == self.TABLE_FJHJ_LABEL_2 then--标签页2的玩家数量处理
		self.view:setPlayerCountExt(self.cur_player_count + 3)
	elseif self.Cur_Select_Page == self.TABLE_FJHJ_LABEL_3 then--标签页3的玩家数量处理
		self.view:setPlayerCountExt2(self.cur_player_count + 6)
	else
		self.view:setPlayerCount(self.cur_player_count)
	end
end


--更新花费钻石
function SMCreateRoomPart:updateDiamondOnPart(type)
	-- body
	local quanCount = CreateRoomPart["TIMAES"..type]
	--print("updateDiamondOnPart_quanCount"..quanCount)
	--通过圈数 循环遍历服务器的数据，如果相等，则得到对应的消费 钻石个数
	local costDiamond = 1

	--[[local user = global:getGameUser()
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
	end]]

	--[[if costDiamond == 1 and type == 4 then
		costDiamond = 16
	end]]

	if quanCount == 4 then
		costDiamond = 7
	elseif quanCount == 8 then
		costDiamond = 12
	elseif quanCount == 16 then
		costDiamond = 20
	end

	if self.cur_pay_way == 0 then
		costDiamond = costDiamond * (SMCreateRoomPart["PLAYER_COUNT"..self.cur_player_count])
	end

	self.view:updateCostDiamondOnView(costDiamond, type)--更新花费钻石
end


--创建房间
function SMCreateRoomPart:createGame()
	-- body
	local net_mode = global:getModuleWithId(ModuleDef.NET_MOD)
	local create_vip_room = ycmj_message_pb.CreateVipRoomMsg()
	create_vip_room.roomid = 2002
	create_vip_room.gametype = 1

	local quanNum = SMCreateRoomPart["TIMAES"..self.cur_times]
	create_vip_room.quanNum = quanNum

	--[[local play_way = RoomConfig.Rule[self.cur_play_way]
	if play_way == RoomConfig.Rule[1] then --红中麻将
		play_way = bit._or(play_way,RoomConfig.RuleMa[self.cur_ma])
		print("this is cur play way:",play_way,RoomConfig.RuleMa[self.cur_ma],RoomConfig.Rule[1])
	end
	create_vip_room.selectWayNum = play_way]]

	create_vip_room.payAA        = self.cur_pay_way
	create_vip_room.selectWayNum = (SMCreateRoomPart["PLAYER_COUNT"..self.cur_player_count])
	create_vip_room.rate         = self.Cur_Select_Type_Number
	print("  create_vip_room  create_vip_room  create_vip_room : ")
	for k,v in pairs(create_vip_room) do
		print(k,v)
	end

	net_mode:sendProtoMsg(create_vip_room,MsgDef.MSG_CREATE_VIP_ROOM,SocketConfig.GAME_ID)
end


--[[
--特殊规则处理部分--guoshengwei 2017.2.15
--]]
--特殊规则选择类型设置
function SMCreateRoomPart:selectedTypeFunc(type1)
	print("  当前页面  ： " .. self.Cur_Select_Page)
	print("  选择的类型 ： "..type1)
	--标签页1--三明108张不带金
	if self.Cur_Select_Page == self.TABLE_FJHJ_LABEL_1 then
		if type1 == 1 then
			self.Cur_Select_Type_Number = bit.lshift(1,self.BIT_LSHIFT_23+self.Cur_Select_Page) + self.TABLE_FJHJ_RULE_001
			self.selectStateTab[type1] = self.TABLE_FJHJ_RULE_001
		elseif type1 == 2 then
			self.Cur_Select_Type_Number = bit.lshift(1,self.BIT_LSHIFT_23+self.Cur_Select_Page) + self.TABLE_FJHJ_RULE_002
			self.selectStateTab[type1] = self.TABLE_FJHJ_RULE_002
		elseif type1 == 3 then
			self.Cur_Select_Type_Number = bit.lshift(1,self.BIT_LSHIFT_23+self.Cur_Select_Page) + self.TABLE_FJHJ_RULE_003
			self.selectStateTab[type1] = self.TABLE_FJHJ_RULE_003
		end


	--标签页2--三明和大田112张带金
	elseif self.Cur_Select_Page == self.TABLE_FJHJ_LABEL_2 then
		if type1 == 1 then
			self.Cur_Select_Type_Number = bit.lshift(1,self.BIT_LSHIFT_23+self.Cur_Select_Page) + self.TABLE_FJHJ_RULE_004
			self.selectStateTab[type1] = self.TABLE_FJHJ_RULE_004
		elseif type1 == 2 then
			self.Cur_Select_Type_Number = bit.lshift(1,self.BIT_LSHIFT_23+self.Cur_Select_Page) + self.TABLE_FJHJ_RULE_005
			self.selectStateTab[type1] = self.TABLE_FJHJ_RULE_005
		elseif type1 == 3 then
			self.Cur_Select_Type_Number = bit.lshift(1,self.BIT_LSHIFT_23+self.Cur_Select_Page) + self.TABLE_FJHJ_RULE_006
			self.selectStateTab[type1] = self.TABLE_FJHJ_RULE_006
		end

	--标签页3--福州144张
	elseif self.Cur_Select_Page == self.TABLE_FJHJ_LABEL_3 then
		if type1 == 1 then
			self.Cur_Select_Type_Number = bit.lshift(1,self.BIT_LSHIFT_23+self.Cur_Select_Page) + self.TABLE_FJHJ_RULE_007
			self.selectStateTab[type1] = self.TABLE_FJHJ_RULE_007
		
		end

	end
	
	--标签页1
	if self.Cur_Select_Page == self.TABLE_FJHJ_LABEL_1 then 
		if self.isDuoXuanFlag1 == 0 then--单选
			self.view:setSelectedTypeFunc(type1,false)
		else
			self.view:setSelectedTypeFunc(type1,true)
		end

	elseif self.Cur_Select_Page == self.TABLE_FJHJ_LABEL_3 then 
	-- 标签页3 需要将 type1+6 确保和cocosstudio中的顺序一样 需要配合cocosstudio配合
		if self.isDuoXuanFlag3 == 0 then--单选
			self.view:setSelectedTypeFuncExt2(type1+6,false)
		else
			self.view:setSelectedTypeFuncExt2(type1+6,true)
		end

	else
		--标签页2 需要将 type1+3 确保和cocosstudio中的顺序一样 需要配合cocosstudio配合
		if self.isDuoXuanFlag2 == 0 then--单选
			self.view:setSelectedTypeFuncExt(type1+3,false)
		else
			self.view:setSelectedTypeFuncExt(type1+3,true)
		end
	end

end


--标签页按钮选择类型设置【备注：标签页更换时需要对界面状态进行初始化】
function SMCreateRoomPart:ChooseSelectPageFunc(type)
	self.view:reflashLayer()

	--标签页更换时 初始化数据 恢复初始状态
	self.selectStateTab         = {}
	self.Cur_Select_Page        = type	   			    --标签页1的处理页
	self.cur_pay_way            = self.PAYWAY           --默认支付方式
	self.cur_player_count       = 1                     --默认是2人游戏 如何要默认其他几人 需要 将 编辑器里的默认值修改  两个值要相匹配
	self.cur_times              = 1						--默认局数
	self.Cur_Select_Type_Number = 0                     --重置所记录的值，以防出现数据混乱
	self.isDuoXuanFlag1         = 1						--标签页1是否是多选 0为单选 1位多选
	self.isDuoXuanFlag2         = 1						--标签页2是否是多选 0为单选 1位多选
	self.isDuoXuanFlag3         = 1						--标签页3是否是多选 0为单选 1位多选

	if self.Cur_Select_Page == self.TABLE_FJHJ_LABEL_1 then---标签页1的处理
		--设置初始值
   		self.view:setSelectPayWay(self.cur_pay_way)
   		self.view:setPlayerCount(self.cur_player_count)
   		self.view:setSelectTimes(self.cur_times)
   		self.view:setChooseSelectPageFunc(self.Cur_Select_Page)

   		handCardNumFlag = 13--手牌13张

   		--单选和多选区分
   		if self.isDuoXuanFlag1 == 0 then--单选
   			self:selectedTypeFunc(1)
   		else--多选
   			self.selectStateTab[1] = self.TABLE_FJHJ_RULE_001
   			self.selectStateTab[2] = self.TABLE_FJHJ_RULE_002
   			self.selectStateTab[3] = self.TABLE_FJHJ_RULE_003
   			self.Cur_Select_Type_Number = bit.lshift(1,self.BIT_LSHIFT_23+self.Cur_Select_Page) + self.TABLE_FJHJ_RULE_001 + self.TABLE_FJHJ_RULE_002 + self.TABLE_FJHJ_RULE_003
   		end

   		--print("选中的规则值："..self.Cur_Select_Type_Number)
   	elseif self.Cur_Select_Page == self.TABLE_FJHJ_LABEL_2 then--标签页2的处理
   		--设置初始值
   		self.view:setSelectPayWay(self.cur_pay_way)
   		self.view:setPlayerCountExt(self.cur_player_count+3)
   		self.view:setSelectTimesExt(self.cur_times+4)
   		self.view:setChooseSelectPageFunc(self.Cur_Select_Page)
   		
   		handCardNumFlag = 16--手牌16张

   		--单选和多选区分
  		if self.isDuoXuanFlag1 == 0 then--单选
  			--根据策划需求 要单选时在此添加
  		else--多选
  			self.view:refButtonState(4)
   			self.view:refButtonState(6)
   			self.selectStateTab[1] = self.TABLE_FJHJ_RULE_004
   			self.selectStateTab[3] = self.TABLE_FJHJ_RULE_006
   			self.Cur_Select_Type_Number = bit.lshift(1,self.BIT_LSHIFT_23+self.Cur_Select_Page) + self.TABLE_FJHJ_RULE_004 + self.TABLE_FJHJ_RULE_006
   		end
   		--print("选中的规则值："..self.Cur_Select_Type_Number)
   	elseif self.Cur_Select_Page == self.TABLE_FJHJ_LABEL_3 then--标签页3的处理
   		--设置初始值
   		self.view:setSelectPayWay(self.cur_pay_way)
   		self.view:setPlayerCountExt2(self.cur_player_count+6)
   		self.view:setSelectTimesExt2(self.cur_times+8)
   		self.view:setChooseSelectPageFunc(self.Cur_Select_Page)

   		handCardNumFlag = 16--手牌16张

   		--单选和多选区分
  		if self.isDuoXuanFlag1 == 0 then--单选
  			--根据策划需求 要单选时在此添加
  		else--多选
  			self.view:refButtonState2(7)
   			self.view:refButtonState2(8)
   			self.selectStateTab[1] = self.TABLE_FJHJ_RULE_007
   			self.Cur_Select_Type_Number = bit.lshift(1,self.BIT_LSHIFT_23+self.Cur_Select_Page) + self.TABLE_FJHJ_RULE_007
   		end
   		--print("选中的规则值："..self.Cur_Select_Type_Number)


   	end
end


return SMCreateRoomPart 