local RoomRuleLayer = class("RoomRuleLayer",cc.load("mvc").ViewBase)
--[[
	界面处理需要保证就算是错误数据也做到不崩溃
	在获取到数据的时候进行checkData操作
]]
function RoomRuleLayer:onCreate(data) --传入数据
	-- body
	self:addMask()
	self:init("RoomRuleLayer")
	-- self:showData();
end

function RoomRuleLayer:OkClick()
    global:getAudioModule():playSound("res/sound/Button32.mp3",false)
	self.part:deactivate()
end

-- 显示数据
function RoomRuleLayer:showData(quanNum, quanTotal)
	if bit._and(globlerule, bit.lshift(1,24)) ~= 0 then
		self.node.allnoticelist:addChild(self.node.text:clone():setString("三明13张"));
	elseif bit._and(globlerule, bit.lshift(1,25)) ~= 0 then
		self.node.allnoticelist:addChild(self.node.text:clone():setString("大田麻将"));
	end

	if bit._and(globlerule, bit.lshift(1,19)) ~= 0 then
		self.node.allnoticelist:addChild(self.node.text:clone():setString("AA支付"));
	else 
		self.node.allnoticelist:addChild(self.node.text:clone():setString("房主支付"));
	end

	if quanNum and quanTotal then
		self.node.allnoticelist:addChild(self.node.text:clone():setString("" .. quanNum .. "/" .. quanTotal .."局"));
	end

	if bit._and(globlerule, bit.lshift(1,5)) ~= 0 then
		self.node.allnoticelist:addChild(self.node.text:clone():setString("红中补花"));
	end

	if bit._and(globlerule, bit.lshift(1,3)) ~= 0 then
		self.node.allnoticelist:addChild(self.node.text:clone():setString("庄家翻倍"));
	end

	if bit._and(globlerule, bit.lshift(1,4)) ~= 0 then
		self.node.allnoticelist:addChild(self.node.text:clone():setString("点炮胡牌"));
	end

	if bit._and(globlerule, bit.lshift(1,0)) ~= 0 then
		self.node.allnoticelist:addChild(self.node.text:clone():setString("无平胡"));
	end

	if bit._and(globlerule, bit.lshift(1,1)) ~= 0 then
		self.node.allnoticelist:addChild(self.node.text:clone():setString("点杠包三家"));
	end

	if bit._and(globlerule, bit.lshift(1,2)) ~= 0 then
		self.node.allnoticelist:addChild(self.node.text:clone():setString("带白板"));
	end

	-- self.node.allnoticelist:addChild(self.node.text:clone():setString("測試一下"));
end

return RoomRuleLayer
