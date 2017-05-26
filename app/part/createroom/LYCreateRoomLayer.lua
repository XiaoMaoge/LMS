local CreateRoomLayer = import(".CreateRoomLayer")
local LYCreateRoomLayer = class("LYCreateRoomLayer",CreateRoomLayer)
--[[
	界面处理需要保证就算是错误数据也做到不崩溃
	在获取到数据的时候进行checkData操作
]]

--[[for i=1,3 do
	CreateRoomLayer["TimesSelectEvent" .. i] = function(self)
		-- body
		self.part:selectTimes(i)
	end
end]]

for i=1,2 do
	CreateRoomLayer["PlayWaySelectEvent" .. i] = function(self)
		self.part:selectPlayWay(i)
	end
end

for i=1,2 do
	CreateRoomLayer["YouJinEvent" .. i] = function(self)
		self.part:selectYouJin(i)
	end
end

--[[function CreateRoomLayer:onEnter()
	self.part.selectTimes(1)	
	self.part.selectPlayWay(1)
	self.part.selectPayWay(false)
	self.part.selectYouJin(1)
end]]

--[[function LYCreateRoomLayer:setSelectTimes(type)
	--print("LYCreateRoomLayer:setSelectTimes :".. type)
	-- body
	for i=1,3 do --关闭当前选择
		if i ~= type then
			self.node["times_select" .. i]:setSelected(false)
			self.node["times_select" .. i]:setTouchEnabled(true)
		else 
			self.node["times_select" .. i]:setTouchEnabled(false)
		end
	end
end]]

function LYCreateRoomLayer:onEnter()
	print("LYCreateRoomLayer:onEnter")
	self.node["pay_way"]:setSelected(false)
	--self::setSelectTimes(1)
end


function LYCreateRoomLayer:setSelectPlayWay(type)
	print("LYCreateRoomLayer:setSelectPlayWay:".. type)
	-- body
		for i=1,2 do
			if i ~= type then
				self.node["play_way_select" .. i]:setSelected(false)
				self.node["play_way_select" .. i]:setTouchEnabled(true)
			else 
				self.node["play_way_select" .. i]:setTouchEnabled(false)
			end
		end

		if type == 2 then
			for i=1,2 do
				self.node["YouJin" .. i]:setVisible(false)
			end
		else
			for i=1,2 do
				self.node["YouJin" .. i]:setVisible(true)
			end
		end

end

function LYCreateRoomLayer:setPayWay(type)
	print("LYCreateRoomLayer:setPayWay"..type)
	self.node["pay_way"]:setSelected(type == 0)
	self.node["pay_way_aa"]:setSelected(type == 1)
	for i=1,3 do
		self.part:updateDiamondOnPart(i)
	end
end

function LYCreateRoomLayer:setSelectYouJin(type)
	print(" LYCreateRoomLayer:setSelectYouJin", type)
	for i=1,2 do
		if i ~= type then
			self.node["YouJin" .. i]:setSelected(false)
			self.node["YouJin" .. i]:setTouchEnabled(true)
		else 
			self.node["YouJin" .. i]:setTouchEnabled(false)
		end	
	end
end

function LYCreateRoomLayer:updateCostDiamondOnView(costDiamond, type)
	local timaes  = self.part["TIMAES"..type]
	self.node["times_txt"..type]:setString(costDiamond)
end

function LYCreateRoomLayer:PayWayEvent( ... )
	print("LYCreateRoomLayer:PayWayEvent")
	self.part:selectPayWay()
end

return LYCreateRoomLayer
