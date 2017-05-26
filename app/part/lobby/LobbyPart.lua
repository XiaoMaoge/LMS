-- local BasePart = require("packages.mvc.BasePart")
local CURRENT_MODULE_NAME = ...
local LobbyPart = class("LobbyPart",cc.load('mvc').PartBase) --大厅模块
LobbyPart.DEFAULT_PART = { --默认存在的固有组件
}
LobbyPart.DEFAULT_VIEW = "LobbyScene"


--[
-- @brief 构造函数
--]
function LobbyPart:ctor(owner)
    LobbyPart.super.ctor(self, owner)
    self:initialize()
end

--[
-- @override
--]
function LobbyPart:initialize()
	self.cur_game_id = -1
	self.arrow_show = false --是否显示管理界面
	local net_mode = global:getModuleWithId(ModuleDef.NET_MOD)
	net_mode:registerMsgListener(MsgDef.MSG_GAME_OTHERLOGIN_ACK,handler(self,LobbyPart.otherLogin))
end

function LobbyPart:otherLogin(data,appId)
	-- body
	local net_mode = global:getModuleWithId(ModuleDef.NET_MOD)
	net_mode:disconnect()
	local tips_part = global:createPart("TipsPart",self)
	if tips_part then
		tips_part:activate({info_txt=string_table.other_login,left_click = function()
			-- body
			cc.Director:getInstance():endToLua()
		end})
	end
end

--激活大厅模块
function LobbyPart:activate(data)
	local lua_bridge = global:getModuleWithId(ModuleDef.BRIDGE_MOD)
	lua_bridge:changeActivityOrientation(0)
	LobbyPart.super.activate(self,CURRENT_MODULE_NAME)

	-- self.view = global:enterSceneWithFullPath("app.tcs.lobby.views.LobbyScene")
 --    self.view:bindPart(self) --界面绑定到当前组件
    local user = global:getGameUser()
    local props = user:getProps()
    self.view:updateUserInfo(props)
    
    lua_bridge:startDownloadImg(props.photo,self.view:getHeadNode())			-- wind 容易引起self.view:getHeadNode() CRASH
    self.view:createGameList(GAME_LIST)
end

function LobbyPart:deactivate()
	local net_mode = global:getNetManager()
	net_mode:unRegisterMsgListener(MsgDef.MSG_GAME_OTHERLOGIN_ACK)
	self.view:removeSelf()
	self.view =  nil
end

function LobbyPart:getPartId()
	-- body
	return "HJLobbyPart"
end

function LobbyPart:arrowClick()
	-- body
	self.arrow_show = not self.arrow_show
	self.view:setArrowState(self.arrow_show)
end


function LobbyPart:backEvent()
	-- body
	local tips_part = global:createPart("TipsPart",self)
	if tips_part then
		tips_part:activate({info_txt=string_table.isExitGame,left_click = function()
			-- body
			cc.Director:getInstance():endToLua()
		end})
	end
end



function LobbyPart:gameClick(gameId,mainPath)
	-- body
	require("app.part.HZMJPartConfig")
	local game_part = require(mainPath).new(self)
	if game_part then
		self.game_id = gameId
		SocketConfig.GAME_ID = gameId
		-- self.view:showChildGameLobby()
		game_part:activateWithLogin()
	end
	
end

function LobbyPart:changeAccount()
	-- body
	 local tips_part = global:createPart("TipsPart",self)
	  if tips_part then
	    tips_part:activate({info_txt=string_table.change_account,left_click=function()
	      -- body
	        local login_part = global:activatePart("LoginPart")
	        login_part:changeAccount()
	    end})
	  end
end

return LobbyPart

