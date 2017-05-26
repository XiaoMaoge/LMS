-- local BasePart = require("packages.mvc.BasePart")
local CURRENT_MODULE_NAME = ...
local UpdatePart = import(".UpdatePart")
local FJUpdatePart = class("FJUpdatePart",UpdatePart) --登录模块
FJUpdatePart.DEFAULT_VIEW = "FJUpdateScene"

--激活模块
function FJUpdatePart:activate(data)  
    FJUpdatePart.super.activate(self,CURRENT_MODULE_NAME)
    self:initServiceConfig("version/458752",self.view,function(event)
		local event_code = event:getEventCode()
        local assetId = event:getAssetId() --文件名
        local percent = event:getPercent() --进度
        local message = event:getMessage() --附加信息
       	print("this is init initServiceConfig:",percent,event_code,message,assetId)
       	if event_code == 5 then
       		self.view:updateProgress(percent)
       	elseif event_code == 8 or event_code == 4 then
       		global:run()
       	end
	end)
end

function FJUpdatePart:startUpdateFile()
  self:updateFile("version/458752")
end

return FJUpdatePart 