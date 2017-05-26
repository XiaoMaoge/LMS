local ReferrerLayer = class("ReferrerLayer",cc.load("mvc").ViewBase)
--[[
	界面处理需要保证就算是错误数据也做到不崩溃
	在获取到数据的时候进行checkData操作
]]
function ReferrerLayer:onCreate(data) --传入数据
	-- body
	self:addMask()
	self:init("ReferrerLayer")
	self.ReferrerId = 0
end

function ReferrerLayer:OkClick()
	-- body
	local txt = tonumber(self.node.input_feild:getString())
	print("--------------txt : ",txt)
	self.part:okClick(txt)
end

function ReferrerLayer:cancelClick()
	-- body
	global:getAudioModule():playSound("res/sound/Button32.mp3",false)
	self.part:deactivate()
end

return ReferrerLayer