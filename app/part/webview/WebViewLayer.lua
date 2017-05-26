local WebViewLayer = class("WebViewLayer",cc.load("mvc").ViewBase)
--[[
	界面处理需要保证就算是错误数据也做到不崩溃
	在获取到数据的时候进行checkData操作
]]
function WebViewLayer:onCreate(data) --传入数据
	-- body
	self:addMask()
	self:init("WebViewLayer")
end

function WebViewLayer:setViewSize(width,height)
	-- body
	self.node.root:setContentSize(width,height)
end

function WebViewLayer:addWebView(view)
	-- body
	self.node.root:addChild(view)
end

function WebViewLayer:backEvent()
	-- body
end

return WebViewLayer