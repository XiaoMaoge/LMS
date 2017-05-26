-- local BasePart = require("packages.mvc.BasePart")
local CURRENT_MODULE_NAME = ...
local FjhjLobbyPart = class("FjhjLobbyPart",cc.load('mvc').PartBase) --登录模块
require("app.part.FJHJPartConfig")

require("app.part.notice.NoticeContent")

FjhjLobbyPart.DEFAULT_PART = {
	'UpdateGamePart', -- 游戏更新组件
	'GameManagePart', -- 游戏管理组件
	'BroadcastPart', -- 跑马灯组件
	'SettingsPart', -- 设置组件
	'AdPart', -- 轮播图组件
	'NoticePart', -- 公告组件
}

-- webview test
require("app.model.protobufmsg.webview_struct_pb")
-- end of webview test

FjhjLobbyPart.DEFAULT_VIEW = "FjhjLobbyScene"
--[
-- @brief 构造函数
--]
function FjhjLobbyPart:ctor(owner)
    FjhjLobbyPart.super.ctor(self, owner)

    self.bIsAutoShowGongGao = false         -- 是否已经自动显示过弹窗

    self:initialize()
end

--[
-- @override
--]
function FjhjLobbyPart:initialize()
	--[[
	-- webview test
	-- 先发request start game
	print( "send message = 0x%x", MsgDef.MSG_REQUEST_START_GAME )
	local net_mode = global:getModuleWithId(ModuleDef.NET_MOD)
	local req_enter_room = wllobby_message_pb.ReqStartGame()
	req_enter_room.roomid = 0
	req_enter_room.gametype = 1
	net_mode:sendProtoMsg(req_enter_room,MsgDef.MSG_REQUEST_START_GAME, 0x01 ) -- SocketConfig.GAME_ID)
	--
	--]]
end


--激活模块
function FjhjLobbyPart:activate(data)
	--回到大厅需要重新设定断线延时
	if IOS_BACK_DELAY == false then
		IOS_BACK_DELAY = true
		local lua_bridge = global:getModuleWithId(ModuleDef.BRIDGE_MOD)
		lua_bridge:setBackDelayTime(30000)
	end
	--------------------------------------------------------------
	require("app.part.FJHJPartConfig")
	
	SocketConfig.GAME_ID = 0x70000
	
	local netManager = global:getNetManager()
    netManager:registerMsgListener(MsgDef.MSG_GAME_LOGIN_ACK,handler(self,FjhjLobbyPart.onGameLoginAck))
    netManager:registerMsgListener(SocketConfig.MSG_GAME_SEND_SCROLL_MES,handler(self,FjhjLobbyPart.scrollMsgAck))
    netManager:registerMsgListener(SocketConfig.MSG_GET_GAME_CONFIG_RSP,handler(self,FjhjLobbyPart.onGetConfigRsp))
    
	--print("sdfdffffffffffffffff测金丝猴覅时代发生的发生的开房间啦时间浪费的时间啊老地方撒");
	-- webview
   	netManager:registerMsgListener(MsgDef.MSG_POST_USER_INFO_ACK, handler(self,FjhjLobbyPart.onPostUserInfoAck))
	-- 
    netManager:registerMsgListener(MsgDef.MSG_GET_LUNBOTU_RSP,handler(self,FjhjLobbyPart.onGetAdImgUrllist))

    if data then
		self.game_list = data.game_list
	end
	
	if not self.game_list then
		local user = global:getGameUser()
		self.game_list = user:getGameList()
	end

	--test ai start
		-- self.game_list = {}
		-- table.insert(self.game_list,{subGameId = 262401, gatePart = "GJMJPartConfig", assetsPath = "ynmj"})
		-- table.insert(self.game_list,{subGameId = 262144, gatePart = "GJMJPartConfig", assetsPath = "ynmj"})
	--test ai end

	self.local_game_list = self:getLocalGameList() --从本地存储中读取已经下载到本地的game id

	local user = global:getGameUser()
    local props = user:getProps()
   
    self.playerID = props.sid
    self.name = props.name

	FjhjLobbyPart.super.activate(self,CURRENT_MODULE_NAME)
    self.view:updateUserInfo(props)
    local lua_bridge = global:getModuleWithId(ModuleDef.BRIDGE_MOD)
    lua_bridge:startDownloadImg(props.photo,self.view:getHeadNode())			-- wind 容易引起self.view:getHeadNode() CRASH
    self.view:updateGameList(self.game_list)
    self.view:updateNodeVisible()

    local broadcast_node = self:getPart("BroadcastPart")
    if broadcast_node then
    	broadcast_node:activate(self.view.node.broadcast_node)
    end
    self:getAdImgUrlist()

	if data and data.reconnect_flag ~= -1 then
    	self.reconnect_flag =data.reconnect_flag
    end
    
end

function FjhjLobbyPart:deactivate()
	print("FjhjLobbyPart:deactivate()")
	if self.view then
		local net_mode = global:getNetManager()
		-- webview
		net_mode:unRegisterMsgListener(MsgDef.MSG_POST_USER_INFO_ACK)
		--
		net_mode:unRegisterMsgListener(MsgDef.MSG_GAME_LOGIN_ACK)
		net_mode:unRegisterMsgListener(SocketConfig.MSG_GAME_SEND_SCROLL_MES)
		net_mode:unRegisterMsgListener(MsgDef.MSG_GET_LUNBOTU_RSP)
		
		self.view:removeSelf()
		self.view = nil
	end
end

function FjhjLobbyPart:getPartId()
	-- body
	return "FjhjLobbyPart"
end



function FjhjLobbyPart:deactivate()
	local netManager = global:getNetManager()
	-- netManager:unRegisterMsgListener(MsgDef.MSG_GET_PATCH_VESION_ACK)
	if self.view then
		self.view:removeSelf()
		self.view = nil
	end
end

function FjhjLobbyPart:startLoading()
	-- body
	local loading_part = global:createPart("LoadingPart",self)
	self:addPart(loading_part)
	loading_part:activate()
end

function FjhjLobbyPart:endLoading(eventCode)
	-- body
	if loading_part then
		loading_part:deactivate()
	end

end


function FjhjLobbyPart:startGame(gameId)
	-- body
	for i,v in ipairs(self.game_list) do
		if v.subGameId == gameId then
			local partConfig = "app.part."..v.gatePart
			package.loaded[partConfig] = nil
			require(partConfig)
			self:startLoading()
			self:requestGameLogin(gameId)
			break
		end
	end
	
end

function FjhjLobbyPart:reconnectGame(gameId)
	-- body
	if self:isGameExits(gameId) then
		self:startGame(gameId)
	end
end

function FjhjLobbyPart:getGameInfo(gameId)
	for _,gameInfo in pairs(self.game_list) do
		if gameInfo.subGameId == gameId then
			return gameInfo
		end
	end
end

function FjhjLobbyPart:setGameVersion(gameId,version)
	-- body
	for _,gameInfo in pairs(self.game_list) do
		if tonumber(gameInfo.subGameId) == tonumber(gameId) then
			gameInfo.version = version
			break
		end
	end
end

function FjhjLobbyPart:onGameIconClick(index)
	local gameInfo = self.game_list[index]
	if not gameInfo then
		return
	end
	-- if self:isGameExits(gameInfo.gameId) then
	-- 	self:startGame(gameInfo.gameId)
	-- else
		self:startUpdateGame(gameInfo.subGameId)
	-- end
end

function FjhjLobbyPart:requestGameLogin(gameID)
	-- body
	local login_msg = wllobby_message_pb.LoginMsg()
	login_msg.machineCode = DEVICE_INFO.imei or ""
	local net_manager = global:getNetManager()
	local buff_str = login_msg:SerializeToString()
	local buff_lenth = login_msg:ByteSize()
    net_manager:sendMsg(buff_str,buff_lenth,MsgDef.MSG_GAME_LOGIN,gameID)
end

function FjhjLobbyPart:onGameLoginAck(data,gameId)
	-- body
	local login_ack = login_pb.LoginResp()
	login_ack:ParseFromString(data)
	print("login success %s",login_ack,self.reconnect_flag)
	-- if login_ack.result == CommonSocketConfig.SUCESS then
	local user = global:getGameUser()
	local game_player = {}
	game_player.gameId = login_ack.playerInfo.gameId
	SocketConfig.GAME_ID = login_ack.playerInfo.gameId
	game_player.playerIndex = login_ack.playerInfo.playerIndex
	game_player.gold = login_ack.playerInfo.gold
	game_player.diamond = login_ack.playerInfo.diamond
	game_player.gameConfigList = login_ack.playerInfo.gameConfig
	game_player.agentFlag = login_ack.playerInfo.agentFlag
	user:setProp("gameplayer" .. login_ack.playerInfo.gameId,game_player)

	local recommender_Id = {}
	recommender_Id.recommenderId = login_ack.playerInfo.recommenderId
	user:setProp("recommender_Id" .. login_ack.playerInfo.gameId,recommender_Id)

	--[[
	for i,v in ipairs(game_player.gameConfigList) do
		local gameParam = game_player.gameConfigList[i]
		print("paraid,valueInt->",gameParam.paraId,gameParam.valueInt)
	end
	]]
	self:endLoading()
	local gameInfo = self:getGameInfo(gameId)
	if not gameInfo then
		print("error, invalid gameId ", gameId)
		return
	end
	local game_user = global:getGameUser()
	local gatePart = global:createPart("LobbyPart",game_user)
	if self.reconnect_flag then
		gatePart:reconnectRequest(self.reconnect_flag) --重连后制空重连标记
		self.reconnect_flag = nil
	else
		self:deactivate()
		gatePart:activate()
		gatePart:reconnectRequest()
	end
end

function FjhjLobbyPart:addAssetsNode(node,index)
	-- body
	local assets_update_part = global:createPart("AssetsUpdatePart",self)
	assets_update_part:activate(self.game_list[index].subGameId,node)
	assets_update_part:downGameBtnImage(self.game_list[index].iconurl or "")
end

function FjhjLobbyPart:isGameExits(gameId)
	return self:isGameExitsInLocalList(gameId)
end

function FjhjLobbyPart:isGameOpen(gameId)
	local gameInfo = self:getGameInfo(gameId)
	if not gameInfo then
		print("error, invalid gameId ", gameId)
		return
	end
	return gameInfo.isOpen
end

function FjhjLobbyPart:startUpdateGame(gameId)
	local updateGamePart = self:getPart("UpdateGamePart")
	if updateGamePart then
		updateGamePart:activate(gameId)
	end
end

function FjhjLobbyPart:onUpdateGameSucceed(gameId)
	print("fjhj lobby part, on update sub_game success, game_id ", gameId)
	
	self:setIsInDownloading(false)
	self:startGame(gameId)

	if not self:isGameExitsInLocalList(gameId) then
		self:addToLocalGameList(gameId)
	end
end

function FjhjLobbyPart:onUpdateGameFailed(gameId)
	print("fjhj lobby part, on update sub_game failed, game_id ", gameId)
	--todo showToast()
end

function FjhjLobbyPart:delLocalGame(gameId)
	local gameInfo = self:getGameInfo(gameId)
	if not gameInfo then
		return
	end

	local writablePath = cc.FileUtils:getInstance():getWritablePath() .. "/UpdateAssets/"
	
	--移除资源
	local assetsPath = writablePath .. "res/" .. gameInfo.assetsPath
	cc.FileUtils:getInstance():removeDirectory(assetsPath)

	--移除对应的ParConfig
	local partConfigPath = writablePath  ..  "src/app/part/" .. gameInfo.gatePart .. ".lua"
	cc.FileUtils:getInstance():removeFile(partConfigPath)

	--移除对应的ParConfig luac文件
	local partConfigCPath = writablePath  ..  "src/app/part/" .. gameInfo.gatePart .. ".luac"
	cc.FileUtils:getInstance():removeFile(partConfigCPath)

	local manifestFileName = writablePath .. gameId .. ".manifest"
	cc.FileUtils:getInstance():removeFile(manifestFileName)

	local versionFileName = writablePath .. "version.manifest"
	cc.FileUtils:getInstance():removeFile(manifestFileName)

	self.view:updateGameList(self.game_list)
	self:removeFromLocalGameList(gameId)
end

function FjhjLobbyPart:onDelGame(gameId, callback)
	local tips_part = global:createPart("TipsPart",self)
	if tips_part then
		tips_part:activate({
			info_txt=string_table.confirm_del_game,
			left_click = function()
					self:delLocalGame(gameId)
					if callback then
						callback(true)
					end
				end,
			right_click = function()
					if callback then
						callback(false)
					end
				end})
	end	
end

function FjhjLobbyPart:backEvent()
	local tips_part = global:createPart("TipsPart",self)
	if tips_part then
		tips_part:activate({info_txt=string_table.isExitGame,left_click = function()
			cc.Director:getInstance():endToLua()
		end})
	end
end

function FjhjLobbyPart:getExitsGames()
	local exitsGames = {}
	for _, gameInfo in pairs(self.game_list) do
		if self:isGameExits(gameInfo.subGameId) then
			table.insert(exitsGames, gameInfo)
		end
	end
	return exitsGames
end

function FjhjLobbyPart:getOpenGames()
	local openGames = {}
	for _, gameInfo in pairs(self.game_list) do
		if self:isGameExits(gameInfo.subGameId) and self:isGameOpen(gameInfo.subGameId) then
			table.insert(openGames, gameInfo)
		end
	end
	return openGames
end

function FjhjLobbyPart:onGameManageClick()
	if self:getIsInDownloading() then
		self:showInDownloading()
		return
	end


	local manage_game_part = self:getPart("GameManagePart")
	if manage_game_part then
		manage_game_part:activate(self:getOpenGames())
	end
	
end

function FjhjLobbyPart:scrollMsgAck(data,appId)		--跑马灯消息
	local net_manager = global:getNetManager()
	local scroll_msg = wllobby_message_pb.ScrollMsg()
	scroll_msg:ParseFromString(data)
	print("----scrollMsgAck appId : ",appId)
	print("----scrollMsgAck : ",scroll_msg)
	
	local msg = scroll_msg.msg
	local loopNum = scroll_msg.loopNum
	local removeAll = scroll_msg.removeAll

	local broadcast_node = self:getPart("BroadcastPart")
	broadcast_node:startBroadcast(msg,loopNum,removeAll,false,appId)
end

function FjhjLobbyPart:settingsClick()
	-- body
	local settings_part = self:getPart("SettingsPart")
	if settings_part then
		settings_part:activate()
	end
end

function FjhjLobbyPart:shareClick()
	self:weixinShareConfigReq()
end

function FjhjLobbyPart:onGonggaoClick()
	self:gongGaoConfigReq()
end

-- webview test
function FjhjLobbyPart:onPostUserInfoAck( data )
	global:processMsgPostUserInfoAck( self, data )
end
-- end of webview test

function FjhjLobbyPart:getAdImgUrlist()
	local net_manager = global:getNetManager()
    net_manager:sendMsg("", 0, MsgDef.MSG_GET_LUNBOTU_REQ, SocketConfig.GAME_ID)
end

function FjhjLobbyPart:onGetAdImgUrllist(data)
	print("FjhjLobbyPart:onGetAdImgUrllist")
	local adlist_ack = hjlobby_message_pb.GetGameConfigRsp()
	adlist_ack:ParseFromString(data)

	local ad_node = self:getPart("AdPart")
    if ad_node then
    	ad_node:activate(self.view.node.rank_node, adlist_ack.msg)
    end
end


function FjhjLobbyPart:showUnopenTips()
	local tips_part = global:createPart("TipsPart",self)
	if tips_part then
		tips_part:activate({info_txt=string_table.opening_soon_txt})
	end
end

function FjhjLobbyPart:showInDownloading()
	local tips_part = global:createPart("TipsPart",self)
	if tips_part then
		tips_part:activate({info_txt=string_table.in_downloading})
	end
end

function FjhjLobbyPart:setIsInDownloading(isInDownloading)
	self.isInDownloading = isInDownloading
end

function FjhjLobbyPart:getIsInDownloading()
	return self.isInDownloading
end

function FjhjLobbyPart:onAccountManageClick()
	local tips_part = global:createPart("TipsPart",self)--require('app.part.tips.TipsPart').new(self)
	if tips_part then
		tips_part:activate({info_txt=string_table.change_account,left_click=function()
			local login_part =global:activatePart("LoginPart")
			login_part:showLogin()
		end})
	end
end

function FjhjLobbyPart:sendGetConfigReq(type)
	local net_mode = global:getModuleWithId(ModuleDef.NET_MOD)
	local req = hjlobby_message_pb.GetGameConfigReq()
	req.type = type
	net_mode:sendProtoMsg(req,SocketConfig.MSG_GET_GAME_CONFIG_REQ,SocketConfig.GAME_ID)
end

function FjhjLobbyPart:onGetConfigRsp(data)
	local msg = hjlobby_message_pb.GetGameConfigRsp()
	msg:ParseFromString(data)

	if msg.type == 5 or msg.type == 6 then
		self:weixinShareConfigRsp(msg)
	elseif msg.type == 7 then
		self:gongGaoConfigRsp(msg)
	else
		--do nothing
	end
end

--------------------fjhj lobby gong gao--------------------
-- 向服务器发送公告请求
--function FjhjLobbyPart:gongGaoConfigReq()
--	self:sendGetConfigReq(7)
--end

-- 从客户端读取普通公告的信息（策划临时要求）
function FjhjLobbyPart:gongGaoConfigReq()
    local data = { msg = { } }
    local strContent = ""
    local iIndex = 1
    while true do
        if nil ~= NoticeContent["commonContent" .. iIndex] then
            strContent = strContent .. "\r\n" .. NoticeContent["commonContent" .. iIndex]
            iIndex = iIndex + 1
        else
            break
        end
    end
    data.msg[1] = strContent
    local notice_part = self:getPart("NoticePart")
    if notice_part then
        notice_part:activate(data)
        notice_part:setTitleText(NoticeContent.commonContentTitle)
    end
end

function FjhjLobbyPart:gongGaoConfigRsp(data)
	local notice_part = self:getPart("NoticePart")
	if notice_part then
		notice_part:activate(data)
	end
end

-- 自动显示弹窗
--function FjhjLobbyPart:autoShowGongGao()
--    if false == self.bIsAutoShowGongGao then
--        self.bIsAutoShowGongGao = true
--        self:sendGetConfigReq(7)
--    end
--end

-- 从客户端读取更新公告的信息（策划临时要求）
function FjhjLobbyPart:autoShowGongGao()
    if false == self.bIsAutoShowGongGao then
        self.bIsAutoShowGongGao = true
        local data = { msg = { } }

        local strContent = ""
        local iIndex = 1
        while true do
            if nil ~= NoticeContent["updataContent" .. iIndex] then
                strContent = strContent .. "\n      " .. NoticeContent["updataContent" .. iIndex]
                iIndex = iIndex + 1
            else
                break
            end
        end
        data.msg[1] = strContent
        local notice_part = self:getPart("NoticePart")
        if notice_part then
            notice_part:activate(data)
            notice_part:setTitleText(NoticeContent.updataContentTitle)
        end

    end
end

--------------------fjhj lobby weixin share--------------------

function FjhjLobbyPart:weixinShareConfigReq()
	local query_type = 5  --ios
	if device.platform == "android" then
		query_type = 6
	end
	self:sendGetConfigReq(query_type)
end

function FjhjLobbyPart:weixinShareConfigRsp(data)
	print("weixin share config msg : ", data)
	local bridge = global:getModuleWithId(ModuleDef.BRIDGE_MOD)
	bridge:ShareToWX(1, data.msg[1], data.msg[2])
end

--------------------local game list--------------------

function FjhjLobbyPart:getLocalGameListKey()
	return "fjhj_game_list"
end

function FjhjLobbyPart:getLocalGameList()
	local game_list_str = cc.UserDefault:getInstance():getStringForKey(self:getLocalGameListKey())
	local game_list = Util.split(game_list_str, ",")
	return game_list
end

function FjhjLobbyPart:saveLocalGameList()
	local game_list_str = table.concat(self.local_game_list, ",")
	cc.UserDefault:getInstance():setStringForKey(self:getLocalGameListKey(), game_list_str)
	cc.UserDefault:getInstance():flush()
end

function FjhjLobbyPart:addToLocalGameList(game_id)
	for _,id in pairs(self.local_game_list) do
		if tonumber(id) == game_id then
			print("warning : add exits game to local game list, game id : ", game_id)
			return			
		end
	end
	table.insert(self.local_game_list, game_id)
	self:saveLocalGameList()
end

--检测版本结束判断是否断线重连
function FjhjLobbyPart:checkVersionEnd(isNewVer)
	-- body
	if isNewVer == false then
		self:reconnectGame(self.reconnect_flag)
	end
end

function FjhjLobbyPart:removeFromLocalGameList(game_id)
	local index = 0
	for idx,id in pairs(self.local_game_list) do
		if tonumber(id) == game_id then
			index = idx
			break
		end
	end

	if index == 0 then
		print("warning : remove unexits id from local game list, game id : ", game_id)
		return			
	end

	table.remove(self.local_game_list, index)
	self:saveLocalGameList()
end

function FjhjLobbyPart:isGameExitsInLocalList(game_id)
	local is_exits = false
	for _,id in pairs(self.local_game_list) do
		if tonumber(id) == game_id then
			is_exits = true
			break
		end
	end
	return is_exits
end

return FjhjLobbyPart 