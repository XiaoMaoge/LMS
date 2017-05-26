local AssetsUpdateNode = import(".AssetsUpdateNode")
local FJAssetsUpdateNode = class("FJAssetsUpdateNode",AssetsUpdateNode)
--[[
	界面处理需要保证就算是错误数据也做到不崩溃
	在获取到数据的时候进行checkData操作
]]
function FJAssetsUpdateNode:onCreate()
	-- body
	self:init("FJAssetsUpdateNode")

	local size = self.node.game_btn:getContentSize()
	-- self.node.game_btn:loadTextureNormal(self.res_base .. "/fjhjlobby/resource/progress.png")
	self.node.game_btn:addTouchEventListener(function(sender, eventType) self:ClickEvent(sender, eventType) end);
	-- self.node.game_btn:onButtonRelease(function(event) print("eeeeeeeeeeeeee") end);
    if not self.normalSprite then
    	self.isGameOpen = self.part:isGameOpen()
    	local normalFilePath = self.res_base .. "/fjhjlobby/resource/normal_bg.png"
    	self.normalSprite = cc.Sprite:create(normalFilePath)
    	self.normalSprite:setPosition(cc.p(size.width * 0.5, size.height * 0.5))
    	self.node.game_btn:addChild(self.normalSprite)
    end

    local black_icon_file_name = string.format("black_icon_%d.png", self.part:getGameId())
    if self.node.download_btn then
    	self.node.download_btn:loadTextureNormal(self.res_base .. "/fjhjlobby/resource/" .. black_icon_file_name)
    end

    if self.isGameOpen then
	    if self.update_progress_bg == nil then
	    	local progress_bg_file_name = string.format("progress_bg_%d.png", self.part:getGameId())
	    	self.update_progress_bg = cc.Sprite:create(self.res_base .. "/fjhjlobby/resource/" .. progress_bg_file_name)
	    	--self.update_progress_bg:setPosition(cc.p(size.width * 0.5, size.height * 0.5))

	    	local cil_sprite = cc.Sprite:create(self.res_base .. "/fjhjlobby/resource/" .. black_icon_file_name)
	        local cliper = cc.ClippingNode:create()
	        local pos = cc.p(size.width * 0.5, size.height * 0.5)
	        cliper:setStencil(cil_sprite)
	        cliper:setAlphaThreshold(0.5)
	        cliper:addChild(self.update_progress_bg)
	        cliper:setPosition(pos)
	        self.node.game_btn:addChild(cliper)
	    end

		local progressSprite = cc.Sprite:create(self.res_base .. "/fjhjlobby/resource/progress.png")
		self.progressTimer = cc.ProgressTimer:create(progressSprite)
		local size = self.update_progress_bg:getContentSize()
		self.progressTimer:setPosition(cc.p(size.width * 0.5, size.height * 0.5))
		self.progressTimer:setType(cc.PROGRESS_TIMER_TYPE_BAR)
		self.progressTimer:setMidpoint(cc.p(1,0))
		self.progressTimer:setBarChangeRate(cc.p(1,0))
		self.update_progress_bg:addChild(self.progressTimer)
		self.progressTimer:setPercentage(100)

		self:setDownloadState(self.part:isGameExits() == false)
		self:setProgressBarState(false)
		self:setUpdateState(false)
	else
		self.node.download_btn:setVisible(true)
		self.node.download_icon:setVisible(false)
		self.node.update_bg:setVisible(false)	
    end
end	

function FJAssetsUpdateNode:ClickEvent(sender, eventType)
	print(sender:getTag())
	if eventType == ccui.TouchEventType.began then
		self.node.game_btn:setScale(1.09);
	elseif eventType == ccui.TouchEventType.moved then
	elseif eventType == ccui.TouchEventType.ended then
		self.node.game_btn:setScale(1.0);
	elseif eventType == ccui.TouchEventType.canceled then
		self.node.game_btn:setScale(1.0);
	end
end

return FJAssetsUpdateNode