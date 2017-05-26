local CreateRoomLayer = class("CreateRoomLayer",cc.load("mvc").ViewBase)
--[[
	界面处理需要保证就算是错误数据也做到不崩溃
	在获取到数据的时候进行checkData操作
]]
function CreateRoomLayer:onCreate()
	-- body
	self:addMask()
	self:init("CreateRoomLayer")
	if self.node.game_select1 then
		self.node.game_select1:setTouchEnabled(false)
		self.node.game_select2:hide()
	end
end

function CreateRoomLayer:onEnter()
	self.costTextInit = self.node.cost_imply:getString()
	self.part:updateDiamondOnPart(1)
end

function CreateRoomLayer:CreateGameClick()
	self.part:createGame()
end

for i=1,3 do


	CreateRoomLayer["MaSelectEvent" .. i] = function(self)
		-- body
		self.part:selectMa(i)
	end

	CreateRoomLayer["PlayWaySelectEvent" .. i] = function(self)
		self.part:selectPlayWay(i)
	end
end

for i=1,4 do
	CreateRoomLayer["TimesSelectEvent" .. i] = function(self)
		-- body
		self.part:selectTimes(i)
	end
end



function CreateRoomLayer:CloseClick()    
	self.part:deactivate()
end

function CreateRoomLayer:setSelectTimes(type)
	print("CreateRoomLayer:setSelectTimes :", type)
	-- body
	for i=1,4 do --关闭当前选择
		if i ~= type then
			self.node["times_select" .. i]:setSelected(false)
			self.node["times_select" .. i]:setTouchEnabled(true)
		else 
			self.node["times_select" .. i]:setTouchEnabled(false)
		end
	end
end

function CreateRoomLayer:setSelectPlayWay(type)
	print("CreateRoomLayer:setSelectPlayWay:", type)
	-- body
		for i=1,3 do
			if i ~= type then
				self.node["play_way_select" .. i]:setSelected(false)
				self.node["play_way_select" .. i]:setTouchEnabled(true)
			else 
				self.node["play_way_select" .. i]:setTouchEnabled(false)
			end
		end

		for i=1,3 do
			if type == self.part.PLAYWAY1 then
				self.node["ma_select" .. i]:show()
			else
				self.node["ma_select" .. i]:hide()
			end	
		end
end


function CreateRoomLayer:setSelectMa(type)
	print("CreateRoomLayer:setSelectMa:", type)
	-- body
	for i=1,3 do
		if i ~= type then
			if self.node["ma_select"..i] then
				self.node["ma_select" .. i]:setSelected(false)
				self.node["ma_select" .. i]:setTouchEnabled(true)
			end
		else 
			if self.node["ma_select"..i] then
				self.node["ma_select" .. i]:setTouchEnabled(false)
			end
		end
	end

end

function CreateRoomLayer:updateCostDiamondOnView(costDiamond)
	local costText = string.format(self.costTextInit,costDiamond)
	self.node.cost_imply:setString(costText)
end

return CreateRoomLayer