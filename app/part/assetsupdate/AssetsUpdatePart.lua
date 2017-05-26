-- local BasePart = require("packages.mvc.BasePart")
local CURRENT_MODULE_NAME = ...
local AssetsDelegate = require("packages.delegate.AssetsDelegate")
local AssetsUpdatePart = class("AssetsUpdatePart",cc.load('mvc').PartBase,AssetsDelegate) --登录模块
AssetsUpdatePart.DEFAULT_PART = {}
AssetsUpdatePart.DEFAULT_VIEW = "AssetsUpdateNode"
--[
-- @brief 构造函数
--]
function AssetsUpdatePart:ctor(owner)
    AssetsUpdatePart.super.ctor(self, owner)
    self:initialize()
end

--[
-- @override
--]
function AssetsUpdatePart:initialize()
	
end

--激活模块
function AssetsUpdatePart:activate(gameId,node)
	self.init_flag = false
	self.gameId = gameId
	self.manifestName = "version/"..gameId
	self.checking = false --正在检测版本
	print("AssetsUpdatePart:activate self.gameId,self.manifestName ", self.gameId,self.manifestName,node)
	AssetsUpdatePart.super.activate(self,CURRENT_MODULE_NAME,node)
	local remote_version = '0'
	self:initServiceConfig(self.manifestName,self.view,function(event)
		local event_code = event:getEventCode()
	    local assetId = event:getAssetId() --文件名
	    local percent = event:getPercent() --进度
	    local message = event:getMessage() --附加信息
	   	print("this is init initServiceConfig:",percent,event_code,message,assetId)
	   	if event_code == 5 then
	   		--去掉下载标记，开始显示下载蒙板
	   		if not self.checking then
	   			self.view:updateProgress(percent)
	   		end
	   	elseif event_code == 3 then --有版本更新
	   		remote_version = self.am[self.manifestName]:getRemoteManifest():getVersion()
	   		self:checkVersionEnd(true)


            local strVersion = cc.UserDefault:getInstance():getStringForKey(tostring(self.gameId) .. "currentVersion")
            -- 如果已经有了该版本则不进行公告弹窗，否则进行公告弹窗
            if strVersion == remote_version then
                
            else
                -- 进行公告弹窗，并更新版本信息
                self:showGongGao()

                cc.UserDefault:getInstance():setStringForKey(tostring(self.gameId) .. "currentVersion", remote_version)
                cc.UserDefault:getInstance():flush()
            end

	   	elseif event_code == 8  or event_code == 4 then
	   		if event_code == 4 then -- ALREADY_UP_TO_DATE 已经是最新版本
	   			self:checkVersionEnd(false)
	   		end

	   		if self.checking then
		   		self.view:setDownloadState(false)
				self.view:setProgressBarState(false)
				self.view:setUpdateState(false)
				self.owner:setIsInDownloading(false)
		   	else
		   		if event_code == 4 then
		   			if self.am and self.am[self.manifestName] then
						local local_manifest = self.am[self.manifestName]:getLocalManifest()
						self.owner:setGameVersion(self.gameId,local_manifest:getVersion())
					end
				else
					self.owner:setGameVersion(self.gameId,remote_version)		
				end
		   		self.view:onUpdateEnd()
		   		self:onUpdateSucceed()	 --去掉下载标记
	   		end
	   	elseif event_code == 6 then 
	 	else
	   		self:onUpdateFailed()
		end
	end)
	self:trycheckVersion()
end

function AssetsUpdatePart:trycheckVersion()
	-- body
	print("trycheckVersion : ",self:isGameOpen(),self.init_flag)
	if self:isGameOpen() and self.init_flag then
		self:checkVersion()
	end
end

function AssetsUpdatePart:checkVersion()
	-- body
	self.checking = true
	self:checkUpdate(self.manifestName)
	print("-------------checkVersion : ",self.am)
	if self.am and self.am[self.manifestName] then
		local local_manifest = self.am[self.manifestName]:getLocalManifest()
		self.owner:setGameVersion(self.gameId,local_manifest:getVersion())
	end
end

function AssetsUpdatePart:startUpdateFile()
	if QUICK_START_SUB_GAME then
		self.owner:startGame(self.gameId)
		return
	end

	self.checking = false

	if self.owner:getIsInDownloading() then
		self.owner:showInDownloading()
		return
	end

	if self:isGameOpen() then
		self.owner:setIsInDownloading(true)
		self:updateFile(self.manifestName)
	else
		self.owner:showUnopenTips()
	end
end

function AssetsUpdatePart:deactivate()
	if self.view then
		self.view:removeSelf()
		self.view = nil
	end
end

function AssetsUpdatePart:getPartId()
	-- body
	return "AssetsUpdatePart"
end

function AssetsUpdatePart:onUpdateSucceed()
	-- self:deactivate()
	self.am = {}
	self.owner:onUpdateGameSucceed(self.gameId)
end

function AssetsUpdatePart:onUpdateFailed()
	-- self:deactivate()
	self.am = {}
	self.owner:onUpdateGameFailed(self.gameId)
end

function AssetsUpdatePart:isGameExits()
	return self.owner:isGameExits(self.gameId)
end

function AssetsUpdatePart:downGameBtnImage(url)
	local lua_bridge = global:getModuleWithId(ModuleDef.BRIDGE_MOD)
    lua_bridge:startDownloadImg(url,self.view:getGameBtnSprite())			-- wind 容易引起self.view:getHeadNode() CRASH
end

function AssetsUpdatePart:isGameOpen()
	return self.owner:isGameOpen(self.gameId)
end

function AssetsUpdatePart:getGameId()
	return self.gameId
end

function AssetsUpdatePart:checkVersionEnd(isNewVer)
	-- body
	if isNewVer == true then
		self.view:showNewVersion()
	end
	self.owner:checkVersionEnd(isNewVer)
end

-- 显示公告弹窗
function AssetsUpdatePart:showGongGao()
    self.owner:autoShowGongGao()
end

return AssetsUpdatePart 