local GameManageLayer = class("GameManageLayer",cc.load("mvc").ViewBase)
--[[
	界面处理需要保证就算是错误数据也做到不崩溃
	在获取到数据的时候进行checkData操作
]]
function GameManageLayer:onCreate(data) --传入数据
	-- body
	self:addMask()
	self:init("GameManageLayer")
	self.node.game_list:setItemModel(self.node.game_item_panel)
end


function GameManageLayer:CloseClick()
    global:getAudioModule():playSound("res/sound/Button32.mp3",false)
	self.part:deactivate()
end

function GameManageLayer:setData(data)
	if not data then
		return
	end
	self.game_list = data;

	self.node.game_list:removeAllItems()
	for k,gameInfo in ipairs(data) do
		self.node.game_list:insertDefaultItem(k - 1)
		local item = self.node.game_list:getItem(k - 1)
		
		local gameIcon = item:getChildByName("game_icon")
		local version_txt = item:getChildByName("version_text")
		self:showGameIcon(gameInfo, gameIcon)
		
		if gameInfo.version then
			version_txt:setString(gameInfo.version)
		end
		
		local delBtn = item:getChildByName("del_btn")
		delBtn:setTag(k)
		delBtn:addClickEventListener(function (sender)
			self:onDelButtonClick(sender:getTag())
		end)
	end
end

function GameManageLayer:onDelButtonClick(index)
	global:getAudioModule():playSound("res/sound/Button32.mp3",false)
	
	if index < 1 or index > #self.game_list then
		print("GameManageLayer : invalid index : ", index)
		return
	end

	local gameInfo = self.game_list[index]
	if gameInfo then
		print("GameManageLayer : to del index : ", index, "game id ", gameInfo.subGameId)
		self.part:onDelGame(gameInfo.subGameId, function(succeed)
			if succeed then
				table.remove(self.game_list, index)
				self:setData(self.game_list)
			end
		end)
	end
end

function GameManageLayer:showGameIcon(gameInfo, iconNode)
	if iconNode and gameInfo.iconurl and gameInfo.iconurl ~= "" then
		local iconSize = iconNode:getContentSize()
		local iconSprite = cc.Sprite:create(self.res_base .. "/fjhjlobby/resource/normal_bg.png")
		iconSprite:setPosition(cc.p(iconSize.width * 0.5, iconSize.height * 0.5))
		iconNode:addChild(iconSprite)
		self.part:loadIconImg(gameInfo.iconurl,iconSprite)
	end
end

return GameManageLayer
