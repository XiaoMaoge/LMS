local LobbyScene = class("LobbyScene",cc.load("mvc").ViewBase)
local truncateString = import("app.part.commonTools.truncateString")
--[[
	界面处理需要保证就算是错误数据也做到不崩溃
	在获取到数据的时候进行checkData操作
]]

function LobbyScene:onCreate(data) --传入数据
	-- body
	self:init("LobbyScene",true)
	local scale = display.width/1280
	self.node.lobby_title:setScale(scale)
	self.node.bottom_bg:setScale(scale)
end


function LobbyScene:updateUserInfo(info)
	-- body
	local game_player = info["gameplayer" .. SocketConfig.GAME_ID]
    -- 如果名字超过10个字符，截取前10个并在后面加上“...”
    local strName = truncateString:getMaxLenString(info.name, 10)
	self.node.name:setString(strName)
	self.node.id:setString(game_player.playerIndex)
	self.node.zuan_txt:setString(game_player.diamond)
	self.node.coin_txt:setString(game_player.gold)

	if SingleGame then
		self.node.return_lobby_btn:hide()
	end
end

function LobbyScene:getHeadNode()
	-- body
	return self.node.head_sprite
end

function LobbyScene:NoticeClick()
	-- body
	global:getAudioModule():playSound("res/sound/Button32.mp3",false)
	self.part:noticeClick()
end

function LobbyScene:HelpClick()
	-- body
	global:getAudioModule():playSound("res/sound/Button32.mp3",false)
	self.part:helpClick()
end

function LobbyScene:RecordClick()
	-- body
	global:getAudioModule():playSound("res/sound/Button32.mp3",false)
	self.part:recordClick()
end

function LobbyScene:SettingsClick()
	-- body
	global:getAudioModule():playSound("res/sound/Button32.mp3",false)
	self.part:settingsClick()
end

function LobbyScene:ShareClick()
	-- body
	global:getAudioModule():playSound("res/sound/Button32.mp3",false)
	self.part:shareClick()
end

function LobbyScene:HeadClick()
	-- body
	global:getAudioModule():playSound("res/sound/Button32.mp3",false)
	self.part:headClick()
end

function LobbyScene:AddZuanClick()
	-- body
	global:getAudioModule():playSound("res/sound/Button32.mp3",false)
	self.part:addZuan()
end

function LobbyScene:AddCoinClick()
	--body
	global:getAudioModule():playSound("res/sound/Button32.mp3", false)
	self.part:addZuan()
	print("player messages : ",info.name,info.uid,info.diamond,info.coin)
end


--创建房间事件
function LobbyScene:CreateGameClick()
	-- body
	global:getAudioModule():playSound("res/sound/Button32.mp3",false)
	self.part:createRoomClick()
end

--加入房间事件
function LobbyScene:AddGameClick()
	-- body
	global:getAudioModule():playSound("res/sound/Button32.mp3",false)
	self.part:addRoomClick()
end

function LobbyScene:FriendGameClick()
	-- body
    global:getAudioModule():playSound("res/sound/Button32.mp3",false)
	self.part:friendGameClick()
end

function LobbyScene:GJGameClick()
	-- body
	global:getAudioModule():playSound("res/sound/Button32.mp3",false)
	self.part:creatNewPlayerGame()
end

function LobbyScene:HNGameClick()
	-- body
	global:getAudioModule():playSound("res/sound/Button32.mp3",false)
	self.part:addRoomClick()
end

function LobbyScene:ShopClick()
	-- body
	global:getAudioModule():playSound("res/sound/Button32.mp3",false)
	self.part:shopClick()
end

--返回合集大厅
function LobbyScene:ReturnLobby()
	-- body
	self.part:returnLobby()
end

function LobbyScene:backEvent()
	-- body
	self.part:backEvent()
end

function LobbyScene:AgentClick()
	-- body
	self.part:agentClick()
end

function LobbyScene:changeAgent()
	-- body
	local FileName1 = self.res_base .. '/lobby/resource/agent3.png'
	local FileName2 = self.res_base .. '/lobby/resource/agent4.png'
	self.node.agent_btn:loadTextureNormal(FileName1,1)
	self.node.agent_btn:loadTexturePressed(FileName2,1)
end

return LobbyScene

