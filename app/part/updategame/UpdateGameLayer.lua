local UpdateGameLayer = class("UpdateGameLayer",cc.load("mvc").ViewBase)
--[[
	界面处理需要保证就算是错误数据也做到不崩溃
	在获取到数据的时候进行checkData操作
]]
function UpdateGameLayer:onCreate()
	-- body
	self:init("UpdateGameLayer")

end


function UpdateGameLayer:onEnter()
	-- body
	self.part:initServerConfig()
end

function UpdateGameLayer:updateProgress(percent)
	-- body
	self.node.update_progress_bg:show()
	self.node.update_progress:setPercent(percent)
	self.node.update_info:setString("正在更新文件，稍等片刻，精彩游戏马上开始！")--string.format("%d%%",percent))
end


return UpdateGameLayer