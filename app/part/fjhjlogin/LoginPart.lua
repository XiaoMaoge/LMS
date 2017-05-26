-- local BasePart = require("packages.mvc.BasePart")
local CURRENT_MODULE_NAME = ...
local LoginPart = class("LoginPart",cc.load('mvc').PartBase) --登录模块
local cjson = require("cjson")
LoginPart.DEFAULT_VIEW = "LoginScene"
require("app.model.config.SocketConfig")
require("app.model.protobufmsg.comm_struct_pb")
require("app.model.protobufmsg.wllobby_message_pb")
require("app.model.protobufmsg.hjlobby_message_pb")
local IS_MUS = 2									--是否强更 2:是
--[
-- @brief 构造函数
--]
function LoginPart:ctor(owner)
    LoginPart.super.ctor(self, owner)
    local bridge = global:getModuleWithId(ModuleDef.BRIDGE_MOD)
    bridge:getDeviceInfo()
    self:initialize()
end

--[
-- @override
--]
function LoginPart:initialize()
	self.flag = false
end

function LoginPart:activate()
	self.login_flag = true --判断是不是重连
	LoginPart.super.activate(self,CURRENT_MODULE_NAME)
	local netManager = global:getNetManager()
    netManager:registerMsgListener(MsgDef.MSG_GAME_LOGIN_ACK,handler(self,LoginPart.onHZLoginAck))
   	netManager:registerMsgListener(CommonSocketConfig.ACK_LOGIN,handler(self,LoginPart.onLoginAck))
   	netManager:registerMsgListener(MsgDef.MSG_GET_GAME_LIST_CONFIG_RSP,handler(self,LoginPart.GetGameListAck))
   	netManager:registerMsgListener(MsgDef.MSG_GET_PATCH_VESION_ACK,handler(self,LoginPart.getPatchVersionAck))
end

function LoginPart:deactivate()
	local netManager = global:getNetManager()
	-- netManager:unRegisterMsgListener(MsgDef.MSG_GET_PATCH_VESION_ACK)
	if self.view then
		self.view:removeSelf()
		self.view = nil
	end
end

function LoginPart:startLoading()
	-- body
	local loading_part = global:createPart("LoadingPart",self)
	self:addPart(loading_part)
	loading_part:activate()
end

function LoginPart:endLoading(eventCode)
	-- body
	local loading_part = self:getPart("LoadingPart")
	if loading_part then
		loading_part:deactivate()
	end

	if eventCode == NET_STATE.CONNECT_CHECK_OK then
		if device.platform == "android" or device.platform == "ios" then
			if self.view then
				self.view:setLoginBtnState(false)
			end
			self:getPatchVersion()
		else
			if self.login_flag == false then
				self.view:updateAudioFile()
			else
				self:checkAccount()
			end
		end

		self.flag = true
	elseif eventCode == NET_STATE.CONNECT_FAIL then
		if self.flag == true then
			local cur_scene = display.getRunningScene()
	        local temp_part = {view=cur_scene}
	        local loading_part = global:createPart("LoadingPart",temp_part)
	        if loading_part then
	            loading_part:activate()
	        end
	        self.flag = false
	    end
	end
end

--检测帐号是否存在如果存在就自动登录
function LoginPart:checkAccount()
	-- body
	local user_default = cc.UserDefault:getInstance()
	local assest_token = user_default:getStringForKey(enUserData.ASSETS_TOKEN,"")

	if assest_token ~= "" then
		self:requestLogin(2,assest_token)
	else
		self:showLogin()
		local tips_part = global:createPart("TipsPart",self)
		if tips_part then
			tips_part:activate({info_txt=string_table.disclaimer_info})
		end
	end
end

--请求登录
function LoginPart:requestLogin(type,principal)
	-- body
	local login_msg = login_pb.LoginReq()
	login_msg.machineCode = DEVICE_INFO.imei or ""
	if principal then
		login_msg.principal = principal
	end
	login_msg.type = type
	login_msg.osType = device.platform
	--login_msg.osType = "windows" --为了打debug包，看log lxb
	local net_manager = global:getNetManager()
	local buff_str = login_msg:SerializeToString()
	local buff_lenth = login_msg:ByteSize()
    net_manager:sendMsg(buff_str,buff_lenth,CommonSocketConfig.REQ_LOGIN,CommonSocketConfig.GAME_ID)
    self:startLoading()
    print("this is request login ----------------------------------------------------:",login_msg,SocketConfig.GAME_ID)
end

function LoginPart:WXLogin()
	-- body
	--QUICK_LOGIN = true --为了打debug包，看log lxb
	if QUICK_LOGIN then
		self:requestLogin(1,"windows")
	else
		local bridge =  global:getModuleWithId(ModuleDef.BRIDGE_MOD)
		bridge:LoginWX(function(code)
			-- body
			self:requestLogin(1,code)
		end)
	end
end


--进入大厅
function LoginPart:enterLobby()
	-- body
	local game_user = global:getGameUser()
	local lobby_part = global:createPart("FjhjLobbyPart",game_user)
	lobby_part:activate()
end


function LoginPart:onLoginAck(data)
	-- body
	self:endLoading()
	self.login_flag = true
	local login_ack = login_pb.LoginResp()
	login_ack:ParseFromString(data)
	print("parse data from protobuf success",login_ack)
	if login_ack.result == CommonSocketConfig.SUCESS then
		if login_ack.userToken then
			local user_default = cc.UserDefault:getInstance()
			user_default:setStringForKey(enUserData.ASSETS_TOKEN,login_ack.userToken)
			user_default:flush()
		end 
		local user = global:getGameUser()
		user:setProp("name",login_ack.nickname)
		user:setProp("photo",login_ack.headImg)
		user:setProp("uid",login_ack.userId)
		user:setProp("sex",login_ack.sex)

		if login_ack.playerInfo and login_ack.playerInfo.gameId then
			self.reconnect_flag = login_ack.playerInfo.gameId
		end
		self:GetGameList()
	else
		self:showLogin()
	end
end

function LoginPart:getPatchVersionAck(data,appID)	--版本回调
	local get_patch_version_Ack = wllobby_message_pb.GetPatchVersionMsgRsp()
	local urlname = nil
	get_patch_version_Ack:ParseFromString(data)
	print("this is patch vesion msg from server : ", get_patch_version_Ack)

	local patchVersion = get_patch_version_Ack.patchVersion
	if device.platform == "android" then
		urlname = get_patch_version_Ack.androidUrl
		-- patchVersion = get_patch_version_Ack.patchVersion
		-- if get_patch_version_Ack.loginMode ~= 0 then
		-- 	QUICK_LOGIN = true
		-- else
		-- 	QUICK_LOGIN = false
		-- end
	elseif device.platform == "ios" then
		urlname = get_patch_version_Ack.iosUrl
		-- patchVersion = get_patch_version_Ack.iosLoginModeVersion
		-- if get_patch_version_Ack.iosLoginMode ~= 0 then
		-- 	QUICK_LOGIN = true
		-- else
		-- 	QUICK_LOGIN = false
		-- end
	else
		patchVersion = cc.Application:getInstance():getVersion()
	end

	local curVersion = PATCH_VERSION or 0--cc.Application:getInstance():getVersion()
	print("this is curVersion:", curVersion)
	if get_patch_version_Ack.patchVersion and curVersion ~= patchVersion then   --首先检查版本是否一致，若一致，直接登录，否则检测强更字段
		local tips_part = global:createPart("TipsPart",self)
		if get_patch_version_Ack.isStrongUpdate == IS_MUS then  --版本不一致，强更
			tips_part:activate({info_txt=string_table.must_new_version,mid_click=function()
				-- body
				cc.Application:getInstance():openURL(urlname)
			end})
		else  --版本不一致，非强更
			if tips_part then
				tips_part:activate({info_txt = string_table.update_new_version,
					left_click = function()
						cc.Application:getInstance():openURL(urlname)
					end,
					right_click = function()
						tips_part = nil
						if self.view then
							self.view:setLoginBtnState(true)
						end
						self:checkAccount()
					end})
			end
		end
	else
		-- if self.view then
		-- 	self.view:setLoginBtnState(true)
		-- end
		if self.login_flag == true then
			self:checkAccount()
		else
			self.view:updateAudioFile()
			self.login_flag = true
        end
        -- self:checkAccount()		
	end
end

function LoginPart:showLogin()
	-- body
	self.view:showLogin() --显示登录按钮
end

function LoginPart:getPatchVersion()				--请求版本是否更新
	print("----send msg MSG_GET_PATCH_VESION success")
	local net_manager = global:getNetManager()
	local patch_version_msg = wllobby_message_pb.GetPatchVersionMsgReq()

	if device.platform == "android" then
		patch_version_msg.platformType = 2
	elseif device.platform == "ios" then
		patch_version_msg.platformType = 1 --平台类型 1:ios 2:安卓 3:win32
	else
		patch_version_msg.platformType = 3 --win32 tmp变量
	end

	local buff_str = patch_version_msg:SerializeToString()
	local buff_lenth = patch_version_msg:ByteSize()

	net_manager:sendMsg(buff_str,buff_lenth,MsgDef.MSG_GET_PATCH_VESION,CommonSocketConfig.GAME_ID)
end


function LoginPart:getPartId()
	-- body
	return "LoginPart"
end


function LoginPart:agreeClick()
	--body
	cc.Application:getInstance():openURL("http://llmj.cdn.xianyugame.com/service_desc/service_desc.html")
end


function LoginPart:backEvent()
	-- body
	local tips_part = global:createPart("TipsPart",self)
	if tips_part then
		tips_part:activate({info_txt=string_table.isExitGame,left_click = function()
			-- body
			cc.Director:getInstance():endToLua()
		end})
	end
end

function LoginPart:GetGameList()
	-- body
	local query_msg = hjlobby_message_pb.QueryGameListReq()
	local net_manager = global:getNetManager()
    net_manager:sendMsg("",0,MsgDef.MSG_GET_GAME_LIST_CONFIG_REQ,CommonSocketConfig.GAME_ID)
end

function LoginPart:GetGameListAck(data)
	local get_game_list_ack = hjlobby_message_pb.QueryGameListRsp()
	get_game_list_ack:ParseFromString(data)
	print("LoginPart: get game list:", get_game_list_ack)
	printInfo("LoginPart:GetGameListAck: ",data)
	if get_game_list_ack.resultCode == 0 then
		local game_list_data = {}
		for _,game_data in ipairs(get_game_list_ack.gamelist) do
			local game_info = {}
			game_info.subGameId = game_data.subGameId
			game_info.subGameName = game_data.subGameName
			game_info.isOpen = game_data.isOpen
			game_info.url =game_data.url
			game_info.gatePart = game_data.gatePart
			game_info.assetsPath = game_data.assetsPath
			game_info.iconurl = game_data.iconurl
			table.insert(game_list_data, game_info)
		end
		local user = global:getGameUser()
		user:setGameList(game_list_data)
		local lobby_data = {}
		lobby_data.game_list = game_list
		lobby_data.reconnect_flag = -1
		
		if self.reconnect_flag ~= "" and tonumber(self.reconnect_flag) > 0 then
			lobby_data.reconnect_flag = tonumber(self.reconnect_flag)
		end	
		
		global:activatePart("FjhjLobbyPart", lobby_data)
		self:deactivate()
	else
		print("error : LoginPart:GetGameListAck getGameList failed")
	end
end

return LoginPart
