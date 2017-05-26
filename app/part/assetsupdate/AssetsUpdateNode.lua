local AssetsUpdateNode = class("AssetsUpdateNode",cc.load("mvc").ViewBase)
--[[
	界面处理需要保证就算是错误数据也做到不崩溃
	在获取到数据的时候进行checkData操作
]]
function AssetsUpdateNode:onCreate()
	-- body
	self:init("AssetsUpdateNode")

	local size = self.node.game_btn:getContentSize()
	-- self.node.game_btn:loadTextureNormal(self.res_base .. "/ynhjlobby/resource/progress.png")
    if not self.normalSprite then
    	self.isGameOpen = self.part:isGameOpen()
    	local normalFilePath = self.res_base .. "/ynhjlobby/resource/normal_bg.png"
    	self.normalSprite = cc.Sprite:create(normalFilePath)
    	self.normalSprite:setPosition(cc.p(size.width * 0.5, size.height * 0.5))
    	self.node.game_btn:addChild(self.normalSprite)
    end

    local black_icon_file_name = string.format("black_icon_%d.png", self.part:getGameId())
    if self.node.download_btn then
    	self.node.download_btn:loadTextureNormal(self.res_base .. "/ynhjlobby/resource/" .. black_icon_file_name)
    end

    if self.isGameOpen then
	    if self.update_progress_bg == nil then
	    	local progress_bg_file_name = string.format("progress_bg_%d.png", self.part:getGameId())
	    	self.update_progress_bg = cc.Sprite:create(self.res_base .. "/ynhjlobby/resource/" .. progress_bg_file_name)
	    	--self.update_progress_bg:setPosition(cc.p(size.width * 0.5, size.height * 0.5))

	    	local cil_sprite = cc.Sprite:create(self.res_base .. "/ynhjlobby/resource/" .. black_icon_file_name)
	        local cliper = cc.ClippingNode:create()
	        local pos = cc.p(size.width * 0.5, size.height * 0.5)
	        cliper:setStencil(cil_sprite)
	        cliper:setAlphaThreshold(0.5)
	        cliper:addChild(self.update_progress_bg)
	        cliper:setPosition(pos)
	        self.node.game_btn:addChild(cliper)
	    end

		local progressSprite = cc.Sprite:create(self.res_base .. "/ynhjlobby/resource/progress.png")
		self.progressTimer = cc.ProgressTimer:create(progressSprite)
		local size = self.update_progress_bg:getContentSize()
		self.progressTimer:setPosition(cc.p(size.width * 0.5, size.height * 0.33))
		self.progressTimer:setType(0)
		self.progressTimer:setReverseDirection(true)
		self.update_progress_bg:addChild(self.progressTimer)
		self.progressTimer:setPercentage(100)

		self:setDownloadState(false)
		self:setProgressBarState(false)
		self:setUpdateState(false)
	else
		self.node.download_btn:setVisible(true)
		self.node.download_icon:setVisible(false)
		self.node.update_bg:setVisible(false)	
    end
end	

function AssetsUpdateNode:onEnter()
	-- body
	if self.isGameOpen then
		--self.part:checkVersion()
		self.part:trycheckVersion()
	end
end

function AssetsUpdateNode:updateProgress(percent)
	self.update_progress_bg:show()
	self:setDownloadState(false)
	self.node.update_text:setVisible(false)
	self.node.progress_text:setVisible(true)
	self.node.update_bg:setVisible(true)

	self.progressTimer:setPercentage(100 - percent)
	self.node.progress_text:setString(string.format("%d%%",percent))
end

function AssetsUpdateNode:setUpdateState(flag)
	self.node.update_bg:setVisible(flag)
end

function AssetsUpdateNode:setDownloadState(flag)
	self.node.download_btn:setVisible(flag)
	self.node.download_icon:setVisible(flag)
end

function AssetsUpdateNode:GameClick()
	print("this is  AssetsUpdateNode GameClick---------------------")
	global:getAudioModule():playSound("res/sound/Button32.mp3",false)

	if self.node.game_btn then
		local toBig = cc.ScaleTo:create(0.1, 1.05)
		local toSmall = cc.ScaleTo:create(0.1, 1.0)
		local action = cc.Sequence:create(toBig, toSmall)
		self.node.game_btn:runAction(action)
	end

	self.part:startUpdateFile()
end

function AssetsUpdateNode:setProgressBarState(flag)
	self.update_progress_bg:setVisible(flag)
end

function AssetsUpdateNode:onDownloadClick()
	global:getAudioModule():playSound("res/sound/Button32.mp3",false)
	if self.part:isGameOpen() then
		self:setDownloadState(false)
		self:setProgressBarState(true)
		self.node.update_bg:setVisible(true)
		self.node.update_text:setVisible(false)
		self.node.progress_text:setVisible(true)
	end
	self.part:startUpdateFile()
end

function AssetsUpdateNode:onUpdateEnd()
	self.node.update_bg:setVisible(false)

	if self.update_progress_bg:isVisible() then
		-- local toBig = cc.ScaleTo:create(0.5, 10)
		-- local action = cc.Sequence:create(toBig, 
			-- cc.CallFunc:create(function ()
				-- self.part:onUpdateSucceed()
			-- end))
		-- self.update_progress_bg:runAction(action)
	else
		self.part:onUpdateSucceed()
	end
end

function AssetsUpdateNode:showNewVersion()
	local isGameExits = self.part:isGameExits()

	self.node.download_icon:setVisible(not isGameExits)
	self:setProgressBarState(false)
	self.node.update_bg:setVisible(isGameExits)
	self.node.update_text:setVisible(isGameExits)
	self.node.progress_text:setVisible(false)
	if isGameExits then --更新不显示蒙板
		self.node.download_btn:setVisible(false)
	end
end

function AssetsUpdateNode:getGameBtnSprite()
	return self.normalSprite
end

return AssetsUpdateNode