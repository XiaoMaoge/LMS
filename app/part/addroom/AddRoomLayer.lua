local AddRoomLayer = class("AddRoomLayer",cc.load("mvc").ViewBase)
--[[
	界面处理需要保证就算是错误数据也做到不崩溃
	在获取到数据的时候进行checkData操作
]]
function AddRoomLayer:onCreate()
	-- body
	self:addMask()
	self:init("AddRoomLayer")
	self.node.im_board:setScrollBarEnabled(false)
end

for i=0,9 do
	AddRoomLayer["NumClick" .. i] = function(self)
		-- body
		self.part:addNum(i)
	end
end

function AddRoomLayer:AddGameClick()    
	self.part:addGame()
end

function AddRoomLayer:ResetClick()    
	self.part:resetNum()
end

function AddRoomLayer:DelClick()    
	self.part:delNum()
end

function AddRoomLayer:CloseClick()
	-- body
	self.part:deactivate()
end

function AddRoomLayer:showNum(str)
	-- body
	self.node.input_txt:setString(str)
end

function AddRoomLayer:CreateGameClick()
	-- body
	self.part:createGameClick()
end

function AddRoomLayer:initUI(type)
	-- body
	if type == 1 then
		local FileName1 = self.res_base .. '/lobby/resource/imboard/addgame_bg.png'
		self.node.tip_bg:loadTexture(FileName1)
		self.node.add_info_txt:setString(string_table.input_six_room_num)
	elseif type == 2 then
		local FileName1 = self.res_base .. '/lobby/resource/imboard/recommender-bg.png'
		self.node.tip_bg:loadTexture(FileName1)
		self.node.add_info_txt:setString(string_table.input_six_referrer_num)
	else
		print("addroom init data is error")
	end
end

return AddRoomLayer