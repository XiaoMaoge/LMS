local FjhjLobbyScene = class("FjhjLobbyScene",cc.load("mvc").ViewBase)
local truncateString = import("app.part.commonTools.truncateString")

FjhjLobbyScene.PAGE_GAME_NUM = 6 --一页多少个子游戏
function FjhjLobbyScene:onCreate()
	-- body
	self:init("FjhjLobbyScene",true)
	self.node.title_bg:setLocalZOrder(10)
	self.node.setting_list_bg:hide()
	local scale = display.width/1280
	self.node.title_bg:setScale(scale)

	self.node.proj_version:setString(PROJ_VERSION)
	if TEST_MODE == true then
		self.node.proj_version:setString(PROJ_VERSION .. string_table.test_mode)
	end
	self.node.game_list:addClickEventListener(handler(self,FjhjLobbyScene.CloseClick))
end

function FjhjLobbyScene:HeadClick()
	print("FjhjLobbyScene:HeadClick")    
end

function FjhjLobbyScene:AddCoinClick()
	print("FjhjLobbyScene:AddCoinClick")    
end

function FjhjLobbyScene:ShareClick()
	print("FjhjLobbyScene:ShareClick") 
	self.part:shareClick()
end

function FjhjLobbyScene:NoticeClick()
	print("FjhjLobbyScene:NoticeClick")
	global:getAudioModule():playSound("res/sound/Button32.mp3",false)
	self.part:onGonggaoClick()    
end

function FjhjLobbyScene:SettingsClick()
	print("FjhjLobbyScene:SettingsClick")
	global:getAudioModule():playSound("res/sound/Button32.mp3",false)
	if self.node.setting_list_bg:isVisible() then
		self.node.setting_list_bg:hide()
	else
		self.node.setting_list_bg:show()
	end    
end

function FjhjLobbyScene:ExitClick()
	print("FjhjLobbyScene:ExitClick")    
end


function FjhjLobbyScene:updateUserInfo(info)
	-- body
    local strName = truncateString:getMaxLenString(info.name, 10)
	self.node.name:setString(strName)
	self.node.id:setString("ID:" .. info.uid)
end

function FjhjLobbyScene:getHeadNode()
	-- body
	return self.node.head_sprite
end

function FjhjLobbyScene:updateNodeVisible()
	self.node.zuan_bg:setVisible(false)
end

--根据数据刷新列表页面
function FjhjLobbyScene:updateGameList(data)
	-- body
	self.node.game_list:removeAllPages()

	local size = #data
	local PAGE_GAME_NUM = math.ceil(size/FjhjLobbyScene.PAGE_GAME_NUM)
	
	for i=1,PAGE_GAME_NUM do --添加子游戏列表页面
		self.node.game_list:addPage(self.node.game_node:clone())
	end
	
	for i,v in ipairs(data) do
		local cur_page = math.ceil(i/FjhjLobbyScene.PAGE_GAME_NUM) - 1
		local page_panel = self.node.game_list:getItem(cur_page)
		local index = (i-1)%FjhjLobbyScene.PAGE_GAME_NUM + 1
		local game_btn = page_panel:getChildByName("game_btn" .. index)
		-- game_btn:show()
		self.part:addAssetsNode(game_btn,i)
	end
end

function FjhjLobbyScene:backEvent()
	-- body
	self.part:backEvent()
end

function FjhjLobbyScene:onGameSettingClick()
	global:getAudioModule():playSound("res/sound/Button32.mp3",false)
	self.node.setting_list_bg:hide()
	self.part:settingsClick()
end

function FjhjLobbyScene:onGameManageClick()
	global:getAudioModule():playSound("res/sound/Button32.mp3",false)
	self.node.setting_list_bg:hide()
	self.part:onGameManageClick()	
end

function FjhjLobbyScene:onAccountManageClick()
	global:getAudioModule():playSound("res/sound/Button32.mp3",false)
	self.node.setting_list_bg:hide()
	self.part:onAccountManageClick()	
end

function FjhjLobbyScene:CloseClick()
	-- body
	self.node.setting_list_bg:hide()
end

return FjhjLobbyScene