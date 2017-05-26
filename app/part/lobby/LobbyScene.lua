local LobbyScene = class("LobbyScene",cc.load("mvc").ViewBase)
LobbyScene.GAME_ROW =2 --多少行
LobbyScene.GAME_COL = 4 --多少行
--[[
	界面处理需要保证就算是错误数据也做到不崩溃
	在获取到数据的时候进行checkData操作
]]
function LobbyScene:onCreate(data) --传入数据
	-- body
	self:init("LobbyScene",true)
	self.node.manager_list1:setScrollBarEnabled(false)
	self.node.manager_list2:setScrollBarEnabled(false)
end


function LobbyScene:updateUserInfo(info)
	-- body
	self.node.name_txt:setString(info.name)
	-- self.node.id_txt:setString(info.uid)
end

function LobbyScene:createGameList(config)
	-- body
	local size = self.node.game_page:getContentSize()
	for i,v in ipairs(config) do
		local pos = cc.p((i-0.5)*size.width/LobbyScene.GAME_COL,(i-0.5)*size.height/LobbyScene.GAME_ROW)
		local game_panel = self.node.game_panel:clone()
		game_panel:setPosition(pos)
		self.node.game_page:addChild(game_panel)
		local game_name = game_panel:getChildByName("game_txt")
		local icon_btn = game_panel:getChildByName("game_btn")
		icon_btn:addClickEventListener(function()
			-- body
			self.part:gameClick(v.game_id,v.game_part)
		end)
		game_name:setString(v.game_name)
	end
end


function LobbyScene:getHeadNode()
	-- body
	return self.node.head_icon
end

function LobbyScene:ArrowClick()
	-- body
	self.part:arrowClick()
end

function LobbyScene:setArrowState(show)
	-- body
	print("this is setArrowState---------------,",show)
	local size = self.node.manager_bg:getContentSize()
	self.node.manager_bg:stopAllActions()
	if show then
		self.node.manager_bg:moveTo({time=1,y=size.height})
	else
		self.node.manager_bg:moveTo({time=1,y=0})
	end
end

function LobbyScene:ChangeAccountClick()
	-- body
	self.part:changeAccount()
end

function LobbyScene:backEvent()
	-- body
	self.part:backEvent()
end

return LobbyScene

