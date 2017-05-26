-- local BasePart = require("packages.mvc.BasePart")
local CURRENT_MODULE_NAME = ...
local AssetsDelegate = require("packages.delegate.AssetsDelegate")
local UpdatePart = class("UpdatePart",cc.load('mvc').PartBase,AssetsDelegate) --登录模块
UpdatePart.DEFAULT_VIEW = "UpdateScene"
UpdatePart.DEFAULT_PART = {}

--[
-- @brief 构造函数
--]
function UpdatePart:ctor(owner)
    UpdatePart.super.ctor(self, owner)
    self:initialize()
end

--[
-- @override
--]
function UpdatePart:initialize()
	
end

--激活模块
function UpdatePart:activate(data)  
    UpdatePart.super.activate(self,CURRENT_MODULE_NAME)
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

function UpdatePart:startUpdateFile()
  self:updateFile("version/458752")
end

function UpdatePart:deactivate()

end

function UpdatePart:getPartId()
	-- body
	return "UpdatePart"
end

return UpdatePart 