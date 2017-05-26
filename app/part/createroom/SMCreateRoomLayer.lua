local CreateRoomLayer = import(".CreateRoomLayer")
local SMCreateRoomLayer = class("SMCreateRoomLayer",CreateRoomLayer)
--[[
	界面处理需要保证就算是错误数据也做到不崩溃
	在获取到数据的时候进行checkData操作
]]

--标签页1 的局数函数响应
for i=1,4 do
	CreateRoomLayer["TimesSelectEvent" .. i] = function(self)
		-- body
		self.part:selectTimes(i)
	end
end


--标签页2的 局数函数响应
for i=5,8 do
	CreateRoomLayer["TimesSelectEvent" .. i] = function(self)
		-- body
		self.part:selectTimes(i-4)
	end
end

--标签页3的 局数函数响应
for i=9,12 do
	CreateRoomLayer["TimesSelectEvent" .. i] = function(self)
		-- body
		self.part:selectTimes(i-8)
	end
end

--标签页1 的玩家函数响应
for i=1,3 do
	CreateRoomLayer["PlayerCountEvent" .. i] = function(self)
		self.part:selectPlayerCount(i)
	end
end


--标签页2的玩家数量 从4开始是因为 编辑器里的index从4开始
for i=4,6 do
	CreateRoomLayer["PlayerCountEvent" .. i] = function(self)
		self.part:selectPlayerCount(i-3)
	end
end

--标签页3 的玩家函数响应
for i=7,9 do
	CreateRoomLayer["PlayerCountEvent" .. i] = function(self)
		self.part:selectPlayerCount(i-6)
	end
end

--[[CreateRoomLayer["PayWaySelectEvent"] = function(self)
     self.part:selectPayWay(self.part["cur_pay_way"])
end]]



function SMCreateRoomLayer:onEnter()
	print("SMCreateRoomLayer:onEnter")
	--self.node["pay_way"]:setSelected(true)
	--self::setSelectTimes(1)
end


function CreateRoomLayer:setSelectPlayWay(type)
end


--标签页1 局数选择按钮的刷新
function SMCreateRoomLayer:setSelectTimes(type)
	print("CreateRoomLayer:setSelectTimes :", (type))
	--关闭当前选择
	for i=1,3 do 
		if i ~= type then
			self.node["times_select" .. i]:setSelected(false)
			self.node["times_select" .. i]:setTouchEnabled(true)
		else 
			self.node["times_select" .. i]:setTouchEnabled(false)
		end
	end

	--刷新钻石 
	for i=1,3 do
		self.part:updateDiamondOnPart(i)
	end
end


--标签页2的 局数选择按钮的刷新
function SMCreateRoomLayer:setSelectTimesExt(type)
	print("CreateRoomLayer:setSelectTimes :", (type))
	---关闭当前选择
	for i=5,7 do 
		if i ~= type then
			self.node["times_select" .. i]:setSelected(false)
			self.node["times_select" .. i]:setTouchEnabled(true)
		else 
			self.node["times_select" .. i]:setTouchEnabled(false)
		end
	end
	--刷新 花费钻石
	for i=5,7 do
		self.part:updateDiamondOnPart(i-4)
	end
end

--标签页3的 局数选择按钮的刷新
function SMCreateRoomLayer:setSelectTimesExt2(type)
	print("CreateRoomLayer:setSelectTimes :", (type))
	---关闭当前选择
	print("setSelectTimesExt2  setSelectTimesExt2 type === "..type)
	for i=9,11 do 
		if i ~= type then
			self.node["times_select" .. i]:setSelected(false)
			self.node["times_select" .. i]:setTouchEnabled(true)
		else 
			self.node["times_select" .. i]:setTouchEnabled(false)
		end
	end
	--刷新 花费钻石
	for i=9,11 do
		self.part:updateDiamondOnPart(i-8)
	end
end

--支付方式选择按钮的响应
function SMCreateRoomLayer:PayWaySelectEvent( ... )
	--print("SMCreateRoomLayer:PayWaySelectEvent")
	self.part:selectPayWay()
end


--设置选择支付方式
function SMCreateRoomLayer:setSelectPayWay(type)
	print("支付方式 ："..type)
	for i=1,3 do
		self.node["pay_way_"..i]:setSelected(type == 0)
		self.node["pay_way_aa_"..i]:setSelected(type == 1)
	end
	
	--刷新 花费钻石
	for i=1,3 do
		self.part:updateDiamondOnPart(i)
	end
end


--标签页1 玩家按钮刷新
function SMCreateRoomLayer:setPlayerCount(type)
	print("游戏人数： "..type)
	--关闭当前选择
	for i=1,3 do 
		if i ~= type then
			self.node["player_count" .. i]:setSelected(false)
			self.node["player_count" .. i]:setTouchEnabled(true)
		else 
			self.node["player_count" .. i]:setTouchEnabled(false)
		end
	end

	--刷新 花费钻石
	for i=1,3 do
		self.part:updateDiamondOnPart(i)
	end
end


--标签页2 玩家按钮刷新
function SMCreateRoomLayer:setPlayerCountExt(type)
	print("游戏人数： "..type)
	--关闭当前选择
	for i=4,6 do 
		if i ~= type then
			self.node["player_count" .. i]:setSelected(false)
			self.node["player_count" .. i]:setTouchEnabled(true)
		else 
			self.node["player_count" .. i]:setTouchEnabled(false)
		end
	end

	--刷新 花费钻石
	for i=4,6 do
		self.part:updateDiamondOnPart(i-3)
	end
end

--标签页3 玩家按钮刷新
function SMCreateRoomLayer:setPlayerCountExt2(type)
	print("游戏人数： "..type)
	--关闭当前选择
	for i=7,9 do 
		if i ~= type then
			self.node["player_count" .. i]:setSelected(false)
			self.node["player_count" .. i]:setTouchEnabled(true)
		else 
			self.node["player_count" .. i]:setTouchEnabled(false)
		end
	end

	--刷新 花费钻石
	for i=7,9 do
		self.part:updateDiamondOnPart(i-6)
	end
end

--刷新 花费钻石的页面显示
function SMCreateRoomLayer:updateCostDiamondOnView(costDiamond, type)
	if self.part.Cur_Select_Page == self.part.TABLE_FJHJ_LABEL_2 then---标签页2的
		self.node["times_txt"..type+4]:setString(costDiamond)
	elseif self.part.Cur_Select_Page == self.part.TABLE_FJHJ_LABEL_3 then---标签页2的
		self.node["times_txt"..type+8]:setString(costDiamond)
	else
		self.node["times_txt"..type]:setString(costDiamond)---标签页1的
	end
end


--[[
--特殊规则部分处理--guoshengwei 2017.2.15
--]]
--标签页1 的按钮响应函数(当有三个选项时 需要多加一次循环将：for i=1,1 do  改为 for i=1,3 do)
--(标签页1 i从1开始的，可从cocostudio中查询相关按钮)
for i=1,3 do
	CreateRoomLayer["selectedTypeEventFunc" ..i] = function(self)
		self.part:selectedTypeFunc(i)
	end
end


--标签页2 的按钮响应
--(标签页2 i从4开始的，可从cocostudio中查询相关按钮)
for i=4,6 do
	CreateRoomLayer["selectedTypeEventFunc" ..i] = function(self)
		self.part:selectedTypeFunc(i-3)
	end
end

--标签页3 的按钮响应（ 现在全部采用1~3  这是以防万一的写法 ）
--(标签页3 i从7开始的，可从cocostudio中查询相关按钮)
for i=7,9 do
	CreateRoomLayer["selectedTypeEventFunc" ..i] = function(self)
		self.part:selectedTypeFunc(i-6)
	end
end



--标签页1 设置按钮的状态(标签页1 ID是从1开始的，可从cocostudio中查询相关按钮)
--[[参数：type1:类型选择
		  isDuoXuan:是多选还是单选
 ]]
function SMCreateRoomLayer:setSelectedTypeFunc(type1,isDuoXuan)
	print(" 特殊规则 类型： "..type1)
	for i=1,3 do --关闭当前选择(当有三个选项时 需要多加一次循环将：for i=1,1 do  改为 for i=1,3 do)
		if isDuoXuan == false then--单选选择
			if i ~= type then
				self.node["seleceTypeNum" .. i]:setSelected(false)
				self.node["seleceTypeNum" .. i]:setTouchEnabled(true)
			else 
				self.node["seleceTypeNum" .. i]:setTouchEnabled(false)
			end
		else
			if i == type1 then--多项选择
				if self.node["seleceTypeNum" .. i]:isSelected() == false then
					self.part.selectStateTab[i] =  0
				end
			end
		end
	end
	--dump(self.part.selectStateTab)
	--每次 选中和取消选择 都需要设置当前选择的值
	self.part.Cur_Select_Type_Number = bit.lshift(1,self.part.BIT_LSHIFT_23+self.part.Cur_Select_Page)
	for k,v in pairs(self.part.selectStateTab) do
		print(k,v)
		self.part.Cur_Select_Type_Number = self.part.Cur_Select_Type_Number + v
	end
	print("选中的规则值4："..self.part.Cur_Select_Type_Number)
end


--标签页2 设置按钮的状态(标签页3 ID是从4开始的，可从cocostudio中查询相关按钮)
--[[参数：type1:类型选择
		  isDuoXuan:是多选还是单选
 ]]
function SMCreateRoomLayer:setSelectedTypeFuncExt(type1,isDuoXuan)
	print(" 特殊规则 类型： "..type1)
	for i=4,6 do --关闭当前选择(当有三个选项时 需要多加一次循环将：for i=1,1 do  改为 for i=1,3 do)
		if isDuoXuan == false then--单项选择
			if i ~= type1 then
				self.node["seleceTypeNum" .. i]:setSelected(false)
				self.node["seleceTypeNum" .. i]:setTouchEnabled(true)
			else 
				self.node["seleceTypeNum" .. i]:setTouchEnabled(false)
			end

		else
			if i == type1 then--多项选择
				if self.node["seleceTypeNum" .. i]:isSelected() == false then
					self.part.selectStateTab[i-3] =  0
				end
			end
		end
	end
	--dump(self.part.selectStateTab)
	--每次 选中和取消选择 都需要设置当前选择的值
	self.part.Cur_Select_Type_Number = bit.lshift(1,self.part.BIT_LSHIFT_23+self.part.Cur_Select_Page)
	for k,v in pairs(self.part.selectStateTab) do
		print(k,v)
		self.part.Cur_Select_Type_Number = self.part.Cur_Select_Type_Number + v
	end
	print("选中的规则值4："..self.part.Cur_Select_Type_Number)
end

--标签页3 设置按钮的状态(标签页3 ID是从7开始的，可从cocostudio中查询相关按钮)
--[[参数：type1:类型选择
		  isDuoXuan:是多选还是单选
 ]]
function SMCreateRoomLayer:setSelectedTypeFuncExt2(type1,isDuoXuan)
	print(" 特殊规则 类型： "..type1)
	for i=7,8 do --关闭当前选择(当有三个选项时 需要多加一次循环将：for i=1,1 do  改为 for i=1,3 do)
		if isDuoXuan == false then--单项选择
			if i ~= type1 then
				self.node["seleceTypeNum" .. i]:setSelected(false)
				self.node["seleceTypeNum" .. i]:setTouchEnabled(true)
			else 
				self.node["seleceTypeNum" .. i]:setTouchEnabled(false)
			end

		else
			if i == type1 then--多项选择
				if self.node["seleceTypeNum" .. i]:isSelected() == false then
					self.part.selectStateTab[i-6] =  0
				end
			end
		end
	end
	--dump(self.part.selectStateTab)
	--每次 选中和取消选择 都需要设置当前选择的值
	self.part.Cur_Select_Type_Number = bit.lshift(1,self.part.BIT_LSHIFT_23+self.part.Cur_Select_Page)
	for k,v in pairs(self.part.selectStateTab) do
		print(k,v)
		self.part.Cur_Select_Type_Number = self.part.Cur_Select_Type_Number + v
	end
	print("选中的规则值4："..self.part.Cur_Select_Type_Number)
end


--[[
--标签页处理--guoshengwei 2017.2.15
--]]
--按钮响应函数(当有三个标签页时 需要多加一次循环将：for i=1,1 do  改为 for i=1,3 do)
for i=1,3 do
	CreateRoomLayer["setChooseSelectPageBtn" ..i] = function(self)
		self.part:ChooseSelectPageFunc(i)
	end
end


--设置标签页的按钮状态
function SMCreateRoomLayer:setChooseSelectPageFunc(type)
	for i=1,3 do --关闭当前选择(当有三个标签页时 需要多加一次循环将：for i=1,1 do  改为 for i=1,3 do)
		if i ~= type then
			self.node["smmj_btn".. i]:setSelected(false)
			self.node["smmj_btn".. i]:setTouchEnabled(true)
			self.node["smmj_img".. i]:setVisible(false)
		else 
			self.node["smmj_btn".. i]:setTouchEnabled(false)
			self.node["smmj_img".. i]:setVisible(true)
		end
	end
end


--标签切换时--界面刷新用的
function SMCreateRoomLayer:reflashLayer()
	---重置玩家选择按钮的状态
	for i=1,9 do
		self.node["player_count" .. i]:setSelected(true)
	end
	
	--重置局数选择按钮的状态
	for i=1,12 do
		self.node["times_select" .. i]:setSelected(true)
	end

	---重置特殊规则选择按钮的状态
	for i=1,3 do
		self.node["seleceTypeNum" .. i]:setSelected(true)
	end

	--重置特殊规则选择按钮的状态--多项选择
	for i=4,6 do
		self.node["seleceTypeNum" .. i]:setSelected(false)
	end

	--重置特殊规则选择按钮的状态--多项选择
	for i=7,8 do
		self.node["seleceTypeNum" .. i]:setSelected(false)
	end
end


--切换标签时 刷新多项选择按钮的状态
--参数type1 标签页多项选择的按钮ID是从4开始的 需要配合cocosstudio文件查看
function SMCreateRoomLayer:refButtonState(type1)
	for i=4,6 do
		if i == type1 then
			self.node["seleceTypeNum" .. i]:setSelected(true)
		end
	end
end

function SMCreateRoomLayer:refButtonState2(type1)
	for i=7,8 do
		if i == type1 then
			self.node["seleceTypeNum" .. i]:setSelected(true)
		end
	end
end

return SMCreateRoomLayer