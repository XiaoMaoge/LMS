-- local BasePart = require("packages.mvc.BasePart")
local CURRENT_MODULE_NAME = ...
local AssetsDelegate = require("packages.delegate.AssetsDelegate")
local LoginPart = class("LoginPart",cc.load('mvc').PartBase,AssetsDelegate) --登录模块
LoginPart.DEFAULT_VIEW = "LoginScene"
require("app.part.TCSPartConfig")
require("app.model.config.SocketConfig")
local cjson = require("cjson")
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

end


function LoginPart:activate()
	local netManager = global:getNetManager()
    netManager:registerMsgListener(CommonSocketConfig.ACK_LOGIN,handler(self,LoginPart.onLoginAck))
    LoginPart.super.activate(self,CURRENT_MODULE_NAME)

    -- self.view = global:enterSceneWithFullPath("app.login.views.LoginScene")
    -- self.view:bindPart(self) --界面绑定到当前组件
 --    self:initServiceConfig("version/lobby",self.view,function(event)
	-- 	local event_code = event:getEventCode()
 --        local assetId = event:getAssetId() --文件名
 --        local percent = event:getPercent() --进度
 --        local message = event:getMessage() --附加信息
 --       	print("this is init initServiceConfig:",percent)
	-- end)
	-- self:updateFile("version/lobby")
end

function LoginPart:deactivate()
	local netManager = global:getNetManager()
	netManager:unRegisterMsgListener(MsgDef.MSG_GAME_LOGIN_ACK)
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

function LoginPart:endLoading()
	-- body
	local loading_part = self:getPart("LoadingPart")
	if loading_part then
		loading_part:deactivate()
	end
	self:checkAccount()
end

--检测帐号是否存在如果存在就自动登录
function LoginPart:checkAccount()
	-- body
	local user_default = cc.UserDefault:getInstance()
	local assest_token = user_default:getStringForKey(enUserData.ASSETS_TOKEN,"")
	if assest_token ~= "" then
		self:requestLogin(2,assest_token)
	else
		self.view:showLogin() --显示登录按钮
	end
end

--切换帐号
function LoginPart:changeAccount()
	-- body
	local user_default = cc.UserDefault:getInstance()
	user_default:setStringForKey(enUserData.ASSETS_TOKEN,"")
	user_default:flush()
	self.view:showLogin() --显示登录按钮
end

--请求登录
function LoginPart:requestLogin(type,principal)
	-- body
	local login_msg = login_pb.LoginReq()
	login_msg.machineCode = DEVICE_INFO.imei
	login_msg.principal = principal
	login_msg.type = type
	login_msg.osType = "windows"--device.platform
	local net_manager = global:getNetManager()
    net_manager:sendProtoMsg(login_msg,CommonSocketConfig.REQ_LOGIN,CommonSocketConfig.GAME_ID)
end

function LoginPart:WXLogin()
	-- body
	QUICK_LOGIN = true
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

function LoginPart:onLoginAck(data)
	-- body
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
		local game_player = {}
		game_player.gameId = login_ack.playerInfo.gameId
		SocketConfig.GAME_ID = login_ack.playerInfo.gameId
		game_player.playerIndex = login_ack.playerInfo.playerIndex
		game_player.gold = login_ack.playerInfo.gold
		game_player.diamond = login_ack.playerInfo.diamond
		user:setProp("gameplayer" .. login_ack.playerInfo.gameId,game_player)

		local recommender_Id = {}
		recommender_Id.recommenderId = login_ack.playerInfo.recommenderId
		user:setProp("recommender_Id" .. login_ack.playerInfo.gameId,recommender_Id)
		
		self:deactivate()
		global:enterLobby()
	
	end
end

function LoginPart:getPatchVersion()				--请求版本是否更新
	print("----send msg MSG_GET_PATCH_VESION success")
	local net_manager = global:getNetManager()
	local patch_version_msg = wllobby_message_pb.GetPatchVersionMsg()

	if device.platform == "android" then
		patch_version_msg.platform_type = VERSIOIN_ANDRIOD
	elseif device.platform == "ios" then
		patch_version_msg.platform_type = VERSIOIN_IOS --平台类型 1:ios 2:安卓 3:win32
	else
		patch_version_msg.platform_type = VERSIOIN_IOS --win32 tmp变量
	end
	net_manager:sendProtoMsg(patch_version_msg,MsgDef.MSG_GET_PATCH_VESION,SocketConfig.GAME_ID)
end


function LoginPart:getPartId()
	-- body
	return "LoginPart"
end


function LoginPart:agreeClick()
	--body
	cc.Application:getInstance():openURL("http://www.baidu.com/")
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

return LoginPart
