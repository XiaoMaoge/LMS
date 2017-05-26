local UpdateScene = class("UpdateScene",cc.load("mvc").ViewBase)
--[[
	界面处理需要保证就算是错误数据也做到不崩溃
	在获取到数据的时候进行checkData操作
]]
function UpdateScene:onCreate()
	-- body
	self:init("UpdateScene")
	if self.schedule_start_update then -- 添加一个延迟，等页面渲染完毕再开始执行检查更新，避免出现收不到版本检测消息的情况
		self:unScheduler(self.schedule_start_update)
		self.schedule_start_update = nil
	end

	self.schedule_start_update = self:schedulerFunc(function()
		self:unScheduler(self.schedule_start_update)
		self.schedule_start_update = nil
		print("this is update scene ------------------------------start update file")
		self.part:startUpdateFile()
	end,1,false)
end

function UpdateScene:updateProgress(percent)
	-- body
	self.node.update_progress:show()
	self.node.update_progress:setPercent(percent)
	self.node.update_info:setString("正在更新文件，稍等片刻，精彩游戏马上开始！")--string.format("%d%%",percent))
end



return UpdateScene