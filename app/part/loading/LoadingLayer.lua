local LoadingLayer = class("LoadingLayer",cc.load("mvc").ViewBase)
--[[
	界面处理需要保证就算是错误数据也做到不崩溃
	在获取到数据的时候进行checkData操作
]]
function LoadingLayer:onCreate(data) --传入数据
	-- body
	self:addMask()
	self:init("LoadingLayer")
	self.node.loading:runAction(self.node.animation)
	self.node.animation:play("StartLoading",true)
end

return LoadingLayer