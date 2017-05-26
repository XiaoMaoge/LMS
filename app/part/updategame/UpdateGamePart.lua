-- local BasePart = require("packages.mvc.BasePart")
local CURRENT_MODULE_NAME = ...
local AssetsDelegate = require("packages.delegate.AssetsDelegate")
local UpdateGamePart = class("UpdateGamePart",cc.load('mvc').PartBase,AssetsDelegate) --登录模块
UpdateGamePart.DEFAULT_PART = {}
UpdateGamePart.DEFAULT_VIEW = "UpdateGameLayer"
--[
-- @brief 构造函数
--]
function UpdateGamePart:ctor(owner)
    UpdateGamePart.super.ctor(self, owner)
    self:initialize()
end

--[
-- @override
--]
function UpdateGamePart:initialize()
	
end

--激活模块
function UpdateGamePart:activate(gameId)
	self.gameId = gameId
	self.manifestName = "version/"..gameId
	UpdateGamePart.super.activate(self,CURRENT_MODULE_NAME)
	print("XXXXX UpdateGamePart:activate self.gameId,self.manifestName ", self.gameId,self.manifestName)
end

function UpdateGamePart:initServerConfig()
	-- body
	print("this is init initServerConfig --------------------------------,",self.view)
    self:initServiceConfig(self.manifestName,self.view,function(event)
		local event_code = event:getEventCode()
	    local assetId = event:getAssetId() --文件名
	    local percent = event:getPercent() --进度
	    local message = event:getMessage() --附加信息
	   	print("this is init initServiceConfig:",percent,event_code,message,assetId)
	   	if event_code == 5 then
	   		self.view:updateProgress(percent)
	   	elseif event_code == 8 or event_code == 4 then
	   		self:onUpdateSucceed()	
	   	else
	   		self:onUpdateFailed()
   		end
	end)
	self:startUpdateFile()
end

function UpdateGamePart:startUpdateFile()
	self:updateFile(self.manifestName)
end

function UpdateGamePart:deactivate()
	if self.view then
		self.am = {}
		self.view:removeSelf()
		-- self.view = nil
	end
end

function UpdateGamePart:getPartId()
	-- body
	return "UpdateGamePart"
end

function UpdateGamePart:onUpdateSucceed()
	self:deactivate()
	self.owner:onUpdateGameSucceed(self.gameId)

end

function UpdateGamePart:onUpdateFailed()
	self:deactivate()
	self.owner:onUpdateGameFailed(self.gameId)

end

return UpdateGamePart 