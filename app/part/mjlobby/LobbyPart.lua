-- local BasePart = require("packages.mvc.BasePart")
require("bit")
local CURRENT_MODULE_NAME = ...
local LobbyPart = class("LobbyPart",cc.load('mvc').PartBase) --大厅模块
LobbyPart.DEFAULT_PART = { --默认存在的固有组件
	'AdPart',--轮播图
	'NoticePart', -- 公告组件
	'HelpPart', --帮助组件
	'RecordPart', --战绩组件
	'SettingsPart', --设置组件
	'UserInfoPart', --个人信息组件
	'AddRoomPart',--加入房间组件
	'CreateRoomPart',--创建房间组件
	'BroadcastPart',--加入小喇叭节点
	'TablePart', --桌子组件
	"PurchasePart",--支付组件
	"ReferrerPart",--推荐人界面
	'WebViewPart',
}
LobbyPart.DEFAULT_VIEW = "LobbyScene"
require("app.model.config.RoomConfig")
require("app.model.protobufmsg.ycmj_message_pb")
require("app.model.protobufmsg.wllobby_message_pb")
require("app.model.config.ClientParamConfig")

local cjson = require "cjson"

cc.exports.globlePlayersNum =  0        -- 该局的游戏人数 

--[
-- @brief 构造函数
--]
function LobbyPart:ctor(owner)
    LobbyPart.super.ctor(self, owner)
    self:initialize()

    self.iRoomID = 0        --房间ID

    self.iGetAdImgUrllistNum = 0 -- 获取轮播图的次数
end
--[
-- @override
--]
function LobbyPart:initialize()
	self.cur_game_id = -1
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
	if IOS_BACK_DELAY == false then
		IOS_BACK_DELAY = true
		local lua_bridge = global:getModuleWithId(ModuleDef.BRIDGE_MOD)
		lua_bridge:setBackDelayTime(30000)
	end
	local lua_bridge = global:getModuleWithId(ModuleDef.BRIDGE_MOD)
	lua_bridge:changeActivityOrientation(1)
	LobbyPart.super.activate(self,CURRENT_MODULE_NAME)

	local net_mode = global:getModuleWithId(ModuleDef.NET_MOD)
	net_mode:registerMsgListener(MsgDef.MSG_GAME_OTHERLOGIN_ACK,handler(self,LobbyPart.otherLogin))
	--net_mode:registerMsgListener(MsgDef.MSG_GAME_LOGIN_ACK,handler(self,LobbyPart.onLoginAck))
	net_mode:registerMsgListener(MsgDef.MSG_REQUEST_START_GAME_ACK,handler(self,LobbyPart.onEnterRoomAck))
	net_mode:registerMsgListener(SocketConfig.MSG_GAME_SEND_SCROLL_MES,handler(self,LobbyPart.scrollMsgAck))
	net_mode:registerMsgListener(SocketConfig.MSG_SYSTEM_NOTIFY_MSG,handler(self,LobbyPart.notifyMsgAck))
	net_mode:registerMsgListener(SocketConfig.MSG_GET_GAME_CONFIG_RSP,handler(self,LobbyPart.msgGameConfigRsp)) 
	net_mode:registerMsgListener(MsgDef.MSG_GET_LUNBOTU_RSP,handler(self,LobbyPart.onGetAdImgUrllist))
	self.reconnect_flag = nil 
	net_mode:enableSeq(false)        	--是否开启双序号 true 开启 false 关闭

    local user = global:getGameUser()
    local props = user:getProps()

    --local table_data = cjson.encode(props)

    self.view:updateUserInfo(props)
    self.playerID = props["gameplayer" .. SocketConfig.GAME_ID].playerIndex
    self.name = props.name

	local game_player = user:getProp("gameplayer"..SocketConfig.GAME_ID)
	local agentFlag = game_player.agentFlag

    if agentFlag == 1 then
    	self.view:changeAgent()
    end 
    --print("table_data->",table_data,self.playerID,self.name)
    local lua_bridge = global:getModuleWithId(ModuleDef.BRIDGE_MOD)
    lua_bridge:startDownloadImg(props.photo,self.view:getHeadNode())			-- wind 容易引起self.view:getHeadNode() CRASH
    local broadcast_node = self:getPart("BroadcastPart")
    if broadcast_node then
    	broadcast_node:activate(self.view.node.broadcast_node)
    end
    --self:reconnectRequest()
    self:getAdImgUrlist()
end

function LobbyPart:deactivate()
	local net_mode = global:getNetManager()
	net_mode:unRegisterMsgListener(MsgDef.MSG_GAME_OTHERLOGIN_ACK)
	net_mode:unRegisterMsgListener(SocketConfig.MSG_GAME_SEND_SCROLL_MES)
	--net_mode:unRegisterMsgListener(MsgDef.MSG_REQUEST_START_GAME_ACK)
	if self.view == nil then
		return
	else
		self.view:removeSelf()
		self.view =  nil
	end
end

function LobbyPart:getPartId()
	-- body
	return "LobbyPart"
end

function LobbyPart:noticeClick() --激活通知部件
	-- -- body
	-- local notice_part = self:getPart("NoticePart")
	-- if notice_part then
	-- 	notice_part:activate()
	-- end

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

function LobbyPart:shopClick() --激活通知部件
	-- body
	local user = global:getGameUser()
	local recommender_Id = user:getProp("recommender_Id"..SocketConfig.GAME_ID)
	local recommenderId = recommender_Id.recommenderId
	print("-----------------recommenderId : ",recommenderId)
	if recommenderId == 0 then
		local tips_part = global:createPart("TipsPart",self)
		if tips_part then
--			tips_part:activate({info_txt=string_table.refferrer_tip2,mid_click=function()
--				-- body
--				local user_info_part = self:getPart("UserInfoPart")
--					if user_info_part then
--						user_info_part:activate("refferrer")
--					end
--			end})
            -- 
 		    tips_part:activate({info_txt="绑定推荐人ID后才可以买钻，绑定即送大量钻石！\n代理（推荐人）咨询请添加客服微信号：LLFJMJ", mid_click=function()
 			    -- body
 			    local user_info_part = self:getPart("UserInfoPart")
 				    if user_info_part then
 					    user_info_part:activate("refferrer")
 				    end
 		    end})
		end
	else
		local purchase_part = self:getPart("PurchasePart")
		if purchase_part then
			purchase_part:activate()
		end
	end
end

function LobbyPart:helpClick()
	-- body
	local help_part = self:getPart("HelpPart")
	if help_part then
		help_part:activate()
	end
end

function LobbyPart:recordClick()
	-- body
	 local record_part = self:getPart("RecordPart")
	 if record_part then
	 	record_part:activate(self.playerID,self.name)
	 end
end

--zhongqy

function LobbyPart:settingsClick()
	-- body
	local settings_part = self:getPart("SettingsPart")
	if settings_part then
		settings_part:activate()
	end
end

function LobbyPart:shareClick()
	-- body
	local title = string_table.game_title_yi_chang
	local bridge = global:getModuleWithId(ModuleDef.BRIDGE_MOD)
	local shareContent = string_table.wx_one_friend
	local shareUrl = string_table.share_weixin_android_url
	--分享内容和分享链接都是从服务器上拉取的

	local user = global:getGameUser()
    local props = user:getProps()
    local gameConfigList = props["gameplayer" .. SocketConfig.GAME_ID].gameConfigList

    for i,v in ipairs(gameConfigList) do
		local gameParam = gameConfigList[i]
		print("paraid,valueInt->",gameParam.paraId,gameParam.valueInt)
		if gameParam.paraId == ClientParamConfig.WEIXIN_SHARE_CONTENT then
			if gameParam.valueStr then
				shareContent = gameParam.valueStr --分享内容
			end
		end

		if device.platform == "android" then
			if gameParam.paraId == ClientParamConfig.WEIXIN_SHARE_URL_ANDROID then
				if gameParam.valueStr then
					shareUrl = gameParam.valueStr --分享链接
				end
			end
		elseif device.platform == "ios" then
			if gameParam.paraId == ClientParamConfig.WEIXIN_SHARE_URL_IOS then
				if gameParam.valueStr then
					shareUrl = gameParam.valueStr --分享链接
				end
			end
		else --windows
			if gameParam.paraId == ClientParamConfig.WEIXIN_SHARE_URL_ANDROID then
				if gameParam.valueStr then
					shareUrl = gameParam.valueStr --分享链接
				end
			end
		end
	end

	print("shareContent,shareUrl->",shareContent,shareUrl)

	bridge:ShareToWX(1,shareContent,shareUrl)
end

function LobbyPart:headClick()
	-- body
	local user = global:getGameUser()
	local recommender_Id = user:getProp("recommender_Id"..SocketConfig.GAME_ID)
	local recommenderId = recommender_Id.recommenderId
	local type = ""
	if recommenderId == 0 then
		type = nil
	else
		type = "apply_agency"
	end
	local user_info_part = self:getPart("UserInfoPart")
	if user_info_part then
		user_info_part:activate(type)
	end
end

function LobbyPart:addZuan()
	-- body
	self:shopClick()
end

function LobbyPart:createRoomClick()
	-- body
	self:creatNewPlayerGame()
end

function LobbyPart:addRoomClick()

	local tips_part = global:createPart("TipsPart",self)
		if tips_part then
			tips_part:activate({info_txt=string_table.openning_soon,mid_click=function()
				-- body
				tips_part:deactivate()
			end})
		end

end

--首先进行重连判断如果没有重连就进入子游戏大厅
function LobbyPart:reconnectRequest(reconnectFlag)
	-- body
	print("this is ziyouxi reconnect -----------------------------------------------")
	if IOS_BACK_DELAY == false then
		IOS_BACK_DELAY = true
		local lua_bridge = global:getModuleWithId(ModuleDef.BRIDGE_MOD)
		lua_bridge:setBackDelayTime(30000)
	end
	local lua_bridge = global:getModuleWithId(ModuleDef.BRIDGE_MOD)
	lua_bridge:changeActivityOrientation(1)

	local net_mode = global:getModuleWithId(ModuleDef.NET_MOD)
	net_mode:registerMsgListener(MsgDef.MSG_GAME_OTHERLOGIN_ACK,handler(self,LobbyPart.otherLogin))
	--net_mode:registerMsgListener(MsgDef.MSG_GAME_LOGIN_ACK,handler(self,LobbyPart.onLoginAck))
	net_mode:registerMsgListener(MsgDef.MSG_REQUEST_START_GAME_ACK,handler(self,LobbyPart.onEnterRoomAck))
	net_mode:registerMsgListener(SocketConfig.MSG_GAME_SEND_SCROLL_MES,handler(self,LobbyPart.scrollMsgAck))
	net_mode:registerMsgListener(SocketConfig.MSG_SYSTEM_NOTIFY_MSG,handler(self,LobbyPart.notifyMsgAck))
	net_mode:registerMsgListener(SocketConfig.MSG_GET_GAME_CONFIG_RSP,handler(self,LobbyPart.msgGameConfigRsp)) 
	net_mode:registerMsgListener(MsgDef.MSG_GET_LUNBOTU_RSP,handler(self,LobbyPart.onGetAdImgUrllist))
	-- self:startLoading()
    self.reconnect_flag = reconnectFlag
	local req_enter_room = wllobby_message_pb.ReqStartGame()
	req_enter_room.roomid = 2002
	req_enter_room.gametype = 1
	net_mode:sendProtoMsg(req_enter_room,MsgDef.MSG_REQUEST_START_GAME,SocketConfig.GAME_ID)
end

function LobbyPart:creatNewPlayerGame()
	self:startLoading()
	if RoomConfig.Ai_Debug then
		local data = {result= 0,
					tableinfo ={
					    tablepos= 0,
					    currenthand= 0,
					    viptableid= 0,
					    creatorname="" ,
					    totalhand= 0,
					    playwaytype= 5,
					    players={
					        canfrind= 0,
					        intable= 1,
					        vipoverdata= {
					            gangcount= 0,
					            zhuangcount= 0,
					            wincount= 0,
					            dianpaocount= 0,
					            hithorsecount= 0,
					        	},
					        uid= "390A4AE35DF844279047691FC48896C8",
					        name= "鹅鹅鹅鹅",
					        gamestate= 1,
					        headImg= 4,
					        headImgUrl= "",
					        sex= 0,
					        coin= 99620,
					        tablepos= 0,
					        desc= "",
					        fan= 0,
					        gameresult= 0,
					        ip= "192.168.1.178",
					    	},
					    roomid= 2004
						}
					}

		--设置手牌的张数--如果是13张牌的时候需要向右偏移--策划需求
		if data.playwaytype ~= nil then
			if data.playwaytype >= bit.lshift(1,24) and data.playwaytype < bit.lshift(1,25) then--手牌13张
				handCardNumFlag = 13
			elseif data.playwaytype >= bit.lshift(1,25) and data.playwaytype < bit.lshift(1,26) then--手牌16张
				handCardNumFlag = 16
			elseif data.playwaytype >= bit.lshift(1,26) then
				--暂无
			end
		end

		self:enterRoom(data)
	else
		local net_mode = global:getModuleWithId(ModuleDef.NET_MOD)
		local req_enter_room = wllobby_message_pb.ReqStartGame()
		if SocketConfig.GAME_ID == 0x10101 then
			req_enter_room.roomid = 2004
		else
			req_enter_room.roomid = 2005
		end
		req_enter_room.gametype = 1
		net_mode:sendProtoMsg(req_enter_room,MsgDef.MSG_REQUEST_START_GAME,SocketConfig.GAME_ID)
	end
end

function LobbyPart:friendGameClick()
	-- body
	self.cur_select_btn = 2
	local net_mode = global:getModuleWithId(ModuleDef.NET_MOD)
	local req_enter_room = wllobby_message_pb.ReqStartGame()
	req_enter_room.roomid = 2002
	req_enter_room.gametype = 1
	net_mode:sendProtoMsg(req_enter_room,MsgDef.MSG_REQUEST_START_GAME,SocketConfig.GAME_ID)
end

function LobbyPart:onEnterRoomAck(data,appID)
	-- 这里要根据游戏类型跳转到不同的游戏进行处理
	self:endLoading()
	local enter_room_ack = ycmj_message_pb.StartGameMsgAck()
	enter_room_ack:ParseFromString(data)

    -------------------------------------------------
    local iValue = enter_room_ack.tableinfo.tablepos
    enter_room_ack.tableinfo.tablepos = bit._and(iValue, 0x03)      -- 获取在桌面上的位置
    globlePlayersNum = bit.rshift(iValue, 2)                        -- 获取该局中可容纳的人数
    globlerule = enter_room_ack.tableinfo.playwaytype               -- 获取游戏规则
    -------------------------------------------------

	print("this is enter room ack:",enter_room_ack)
	if enter_room_ack.result == MsgResult.GOLD_LOW_THAN_MIN_LIMIT then -- 金币低于下限
		local tips_part = global:createPart("TipsPart",self)
		if tips_part then
			tips_part:activate({info_txt=string_table.gold_low})
		end
	elseif enter_room_ack.result == MsgResult.GOLD_HIGH_THAN_MAX_LIMIT then -- 金币超过上限
	elseif enter_room_ack.result == MsgResult.CAN_ENTER_VIP_ROOM then -- 可以进入VIP房间
		if self.reconnect_flag then --异常容错，正常情况，有重连标记就应该重连进入房间，如果服务端数据错误，保证还很显示大厅
			global:exitLobby()
			self:activate()
		elseif self.cur_select_btn == 1 then
			self:createRoom()
		elseif self.cur_select_btn == 2 then
			self:addRoom()
		end
	elseif enter_room_ack.result == MsgResult.VIP_TABLE_IS_FULL then -- vip桌 子已经满座了
		local tips_part = global:createPart("TipsPart",self)
		if tips_part then
			tips_part:activate({info_txt=string_table.vip_table_is_full})
		end
	elseif enter_room_ack.result == MsgResult.VIP_TABLE_IS_GAME_OVER then -- 正在游戏中不能进入其他房间
		local tips_part = global:createPart("TipsPart",self)
		if tips_part then
			tips_part:activate({info_txt=string_table.vip_table_is_over})
		end
	elseif enter_room_ack.result == MsgResult.IS_PLAYING_CAN_NOT_ENTER_ROOM then -- 正在游戏中不能进入其他房间
		local tips_part = global:createPart("TipsPart",self)
		if tips_part then
			tips_part:activate({info_txt=string_table.is_playing_cannot_enter})
		end
	elseif enter_room_ack.result == MsgResult.TODAY_GAME_RECORD_OUT_LIMIT_IN_ROOM then -- 今日输赢超过房间上限
		local tips_part = global:createPart("TipsPart",self)
		if tips_part then
			tips_part:activate({info_txt=string.format(string_table.room_record_out_limit,enter_room_ack.gold)})
		end
	elseif enter_room_ack.result == MsgResult.TODAY_GAME_RECORD_OUT_LIMIT_IN_GAME then -- 今日输赢超过游戏上限
		local tips_part = global:createPart("TipsPart",self)
		if tips_part then
			tips_part:activate({info_txt=string.format(string_table.game_record_out_limit,enter_room_ack.gold)})
		end
	elseif enter_room_ack.result == MsgResult.VIP_TABLE_NOT_FOUND then -- 桌子未找到
		-- local add_room_part = self:getPart("AddRoomPart")
		-- if add_room_part then
		-- 	add_room_part:deactivate()
		-- end
		local tips_part = global:createPart("TipsPart",self)
		if tips_part then
			tips_part:activate({info_txt=string_table.room_id_wrong})
		end
	elseif enter_room_ack.result == MsgResult.FANGKIA_NOT_FOUND then --钻石不足
		local tips_part = global:createPart("TipsPart",self)
		if tips_part then
			tips_part:activate({info_txt=string_table.fangka_not_found})
		end
	elseif enter_room_ack.result == MsgResult.CMD_EXE_OK then --进入房间
		self:enterRoom(enter_room_ack)
	end
end

--进入房间
function LobbyPart:enterRoom(data)
	-- body
	local table_part = self:getPart("TablePart")
	if table_part then
		self:deactivate()
		table_part:activate(data)
	end

end

--创建房间
function LobbyPart:createRoom()
	-- body
	local create_room_part = self:getPart("CreateRoomPart")
	create_room_part:activate()
end

function LobbyPart:addRoom()
	-- body
	local add_room_part = self:getPart("AddRoomPart")
	add_room_part:activate(1)
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

function LobbyPart:scrollMsgAck(data,appId)		--跑马灯消息
	-- body
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


function LobbyPart:notifyMsgAck(data,appId)		--系统消息
	-- body
	local net_manager = global:getNetManager()
	local notify_Msg = wllobby_message_pb.SystemNotifyMsg()
	notify_Msg:ParseFromString(data)
	print("----scrollMsgAck : ",notify_Msg)
end

--返回合集大厅
function LobbyPart:returnLobby()
	-- body
	self:deactivate()
	global:enterLobby()
end

function LobbyPart:startLoading()
	-- body
	local loading_part = global:createPart("LoadingPart",self)
	self:addPart(loading_part)
	loading_part:activate()
end

function LobbyPart:endLoading()
	-- body
	local loading_part = self:getPart("LoadingPart")
	if loading_part then
		loading_part:deactivate()
	end
end

function LobbyPart:agentClick()
	-- body
	local user = global:getGameUser()
	local game_player = user:getProp("gameplayer"..SocketConfig.GAME_ID)
	self.playerIndex = game_player.playerIndex
	local agentFlag = game_player.agentFlag
	if agentFlag == 1 then
		local net_mode = global:getModuleWithId(ModuleDef.NET_MOD)
		local apply_agency_req = hjlobby_message_pb.GetGameConfigReq()
		apply_agency_req.type = 4
		net_mode:sendProtoMsg(apply_agency_req,SocketConfig.MSG_GET_GAME_CONFIG_REQ,SocketConfig.GAME_ID)
	else 
		-- local recommender_Id = user:getProp("recommender_Id"..SocketConfig.GAME_ID)
		-- local recommenderId = 0
		
		-- if recommender_Id and recommender_Id.recommenderId then
		-- 	recommenderId = recommender_Id.recommenderId
		-- end

		-- if recommenderId == 0 then
		-- 	local tips_part = global:createPart("TipsPart",self)
		-- 	if tips_part then
		-- 		tips_part:activate({info_txt=string_table.apply_refferrer_tip})
		-- 	end
		-- else
			local net_mode = global:getModuleWithId(ModuleDef.NET_MOD)
			local apply_agency_req = hjlobby_message_pb.GetGameConfigReq()
			apply_agency_req.type = 1
			net_mode:sendProtoMsg(apply_agency_req,SocketConfig.MSG_GET_GAME_CONFIG_REQ,SocketConfig.GAME_ID)
		--end
	end
end

function LobbyPart:msgGameConfigRsp(data)
	-- body
	local get_game_config_rsp = hjlobby_message_pb.GetGameConfigRsp()
	get_game_config_rsp:ParseFromString(data)
	print("lobby_rsp :　",get_game_config_rsp)

	local url = get_game_config_rsp.msg[2]
	local width =  get_game_config_rsp.msg[3]
	local height =  get_game_config_rsp.msg[4]
	local keyword =  get_game_config_rsp.msg[5]
	local inputParam = get_game_config_rsp.msg[6]
	
	local webviewpart = self:getPart("WebViewPart")
		if webviewpart then
		    -- webviewpart:activate()
		    -- webviewpart:loadURL(url)
		    -- webviewpart:setContentSize( -2, -2 )
		    -- webviewpart:setTransprent(true)
		    -- webviewpart:setKeyWord(keyword)
		    -- webviewpart:sendParamToJS("hello world") 
		    print("inputParam : ",inputParam)
		    webviewpart:activate(0,url,keyword,inputParam)
		    webviewpart:setTransprent(true)   
		end
end

function LobbyPart:getAdImgUrlist()
	print("--- getAdImgUrlist success")
	local net_manager = global:getNetManager()
    net_manager:sendMsg("", 0, MsgDef.MSG_GET_LUNBOTU_REQ, SocketConfig.GAME_ID)
end

function LobbyPart:onGetAdImgUrllist(data)
    if self.iGetAdImgUrllistNum <= 0 then
        self.iGetAdImgUrllistNum = self.iGetAdImgUrllistNum + 1
        local adlist_ack = hjlobby_message_pb.GetGameConfigRsp()
        adlist_ack:ParseFromString(data)
        print("--- onGetAdImgUrllist success", adlist_ack)
        local ad_node = self:getPart("AdPart")
        if ad_node then
            ad_node:activate(self.view.node.rank_node, adlist_ack.msg)
        end
    end
end

return LobbyPart