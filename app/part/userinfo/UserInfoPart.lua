-- local BasePart = require("packages.mvc.BasePart")
local CURRENT_MODULE_NAME = ...
local UserInfoPart = class("UserInfoPart",cc.load('mvc').PartBase) --登录模块
UserInfoPart.DEFAULT_PART = { --默认存在的固有组件
	'WebViewPart',
	'AddRoomPart',
}
UserInfoPart.DEFAULT_VIEW = "UserInfoLayer"

UserInfoPart.Result1 = 0 				--绑定成功
UserInfoPart.Result2 = 1108 			--绑定上级失败
UserInfoPart.Result3 = 1109				--绑定上级失败
UserInfoPart.Result4 = 1110				--没有这个用户
--[
-- @brief 构造函数
--]

function UserInfoPart:ctor(owner)
    UserInfoPart.super.ctor(self, owner)
    self:initialize()
end

--[
-- @override
--]
function UserInfoPart:initialize()
	self.itemID = SocketConfig.SEND_PLAYER_CMD_GET_MY_SEND_DIAMOND_LOG 			--流水查询 总收入
	local user = global:getGameUser()
	local recommender_Id = user:getProp("recommender_Id"..SocketConfig.GAME_ID)
	self.recommender_Id = 0
	
	if recommender_Id and recommender_Id.recommenderId then
		self.recommenderId = recommender_Id.recommenderId
	end
end

--激活模块
function UserInfoPart:activate(data)
	local net_mode = global:getModuleWithId(ModuleDef.NET_MOD)
	net_mode:registerMsgListener(SocketConfig.MSG_GAME_GET_PLAYER_DIAMOND_LOG_ACK,handler(self,UserInfoPart.msgRequestGetAck))  -- 流水查询ack 
	net_mode:registerMsgListener(MsgDef.MSG_GAME_OPERATION_ACK,handler(self,UserInfoPart.gameOperationAck)) 
	net_mode:registerMsgListener(SocketConfig.MSG_GET_GAME_CONFIG_RSP,handler(self,UserInfoPart.msgGameConfigRsp)) 
	

	UserInfoPart.super.activate(self,CURRENT_MODULE_NAME)
   	local user = global:getGameUser()
   	self.view:updateUserInfo(user:getProps())
   	self:loadHeadImg()

   	local game_player = user:getProp("gameplayer"..SocketConfig.GAME_ID)
	self.playerIndex = game_player.playerIndex
	self.agentFlag = game_player.agentFlag

   	if data == "refferrer" then
   		self:selectuser(2)
   	elseif data == "apply_agency" then
   		self.view:setApplyAgency()
   	end
end

function UserInfoPart:deactivate()
	local net_mode = global:getModuleWithId(ModuleDef.NET_MOD)
	net_mode:unRegisterMsgListener(SocketConfig.MSG_GAME_GET_PLAYER_DIAMOND_LOG_ACK)  -- 流水查询ack 
	net_mode:unRegisterMsgListener(MsgDef.MSG_GAME_OPERATION_ACK)
	--net_mode:unRegisterMsgListener(SocketConfig.MSG_GET_GAME_CONFIG_RSP) 
	if self.view then
		self.view:removeSelf()
	  	self.view =  nil
	end
end

function UserInfoPart:getPartId()
	-- body
	return "UserInfoPart"
end

function UserInfoPart:loadHeadImg()
	-- body
	local user = global:getGameUser()
    local props = user:getProps()
	local lua_bridge = global:getModuleWithId(ModuleDef.BRIDGE_MOD)
    lua_bridge:startDownloadImg(props.photo,self.view:getHeadNode())
end

function UserInfoPart:selectChoose(type)
	-- body
	self.view:selectChoose(type)
end

function UserInfoPart:selectLiushui(type , pageIndex)
	-- body
	self.view:selectLiushui(type)
	if type == 1 then
		print("总流水")
		self.itemID = SocketConfig.SEND_PLAYER_CMD_GET_MY_SEND_DIAMOND_LOG 			--流水查询 总收入
	elseif type == 2 then
		print("支出")
		self.itemID = SocketConfig.SEND_PLAYER_CMD_GET_MY_SUB_DIAMOND_LOG	 		--流水查询 支出
	elseif type == 3 then
		print("收入")
		self.itemID = SocketConfig.SEND_PLAYER_CMD_GET_MY_ADD_DIAMOND_LOG		 		--流水查询 收入
	end

	print("-------------------------:",self.itemID)
	local net_mode = global:getModuleWithId(ModuleDef.NET_MOD)
	local game_buy_msg = comm_struct_pb.GameBuyItemMsg()
	game_buy_msg.itemID = self.itemID

	if pageIndex == nil then
		pageIndex = 0
	end
	print("--------------pageIndex : ",pageIndex)
	game_buy_msg.count = pageIndex

	net_mode:sendProtoMsg(game_buy_msg,SocketConfig.MSG_REQUEST_BUY_DAOJU,SocketConfig.GAME_ID)
	self.owner:startLoading()
end

function UserInfoPart:selectuser(type)
	-- body
	self.view:selectuser(type)

	if type == 1 then
		print("--个人信息")
		self.view:showUserInfoLayer()
	elseif type == 2 then
		if self.recommenderId == 0 then
			print("--推荐人")
			self.view:showReferrerPanel()
		else
			print("--推荐人内容")
			if self.agentFlag == 1 then
				self:msgGameConfigReq(2)
			else
				self:msgGameConfigReq(1)
			end
		end
		--self:msgWeixinShareReq()
	elseif type == 3 then
		print("--投诉上级")
	end
end

function UserInfoPart:msgRequestGetAck(data,appId)
	-- body

	self.owner:endLoading()

	local msg_request_get_ack = comm_struct_pb.GetPlayerDiamondLogAck()
	msg_request_get_ack:ParseFromString(data)
	print("UserInfoPart:msgRequestGetAck:",msg_request_get_ack)

	if #msg_request_get_ack.logs > 0 then
		self.view:setNomessage(false)
		-- self.view:setLiftRight(true)     -- 策划需求不显示流水中的左右箭头
		self.view:setData(msg_request_get_ack)
	else
		self.view:setLiftRight(false)
		self.view:setNomessage(true)
	end
end


function UserInfoPart:okClick(ReferrerId)
	-- body
	local ReferrerId_num = ReferrerId
	if ReferrerId == nil then
		ReferrerId_num = ""
		ReferrerId = 0
	end

	print(ReferrerId,self.playerIndex)
	if tonumber(ReferrerId) == tonumber(self.playerIndex) then
		local tips_part = global:createPart("TipsPart",self)
		if tips_part then
			tips_part:activate({info_txt=string_table.nobind_tip})
		end
	else
		self.recommenderId = ReferrerId
		require("app.model.protobufmsg.ycmj_message_pb")
		global:getAudioModule():playSound("res/sound/Button32.mp3",false)
		local net_mode = global:getModuleWithId(ModuleDef.NET_MOD)
		local opt_msg = ycmj_message_pb.PlayerGameOpertaion()
		opt_msg.opid = 1061
		opt_msg.opvalue = ReferrerId
		net_mode:sendProtoMsg(opt_msg,MsgDef.MSG_GAME_OPERATION,SocketConfig.GAME_ID)
		self.owner:startLoading()
	end
end

function UserInfoPart:isOkClick(ReferrerId)
	self.recommenderId = ReferrerId
	require("app.model.protobufmsg.ycmj_message_pb")
	global:getAudioModule():playSound("res/sound/Button32.mp3",false)
	local net_mode = global:getModuleWithId(ModuleDef.NET_MOD)
	local opt_msg = ycmj_message_pb.PlayerGameOpertaion()
	opt_msg.opid = 1060
	opt_msg.opvalue = ReferrerId
	net_mode:sendProtoMsg(opt_msg,MsgDef.MSG_GAME_OPERATION,SocketConfig.GAME_ID)
end

function UserInfoPart:gameOperationAck(data,appId)
	-- body
	self.owner:endLoading()
	require("app.model.protobufmsg.ycmj_message_pb")
	local game_op_ack = ycmj_message_pb.PlayerGameOpertaionAck()
	game_op_ack:ParseFromString(data)
	print("this is UserInfoPart op ack:",game_op_ack)
	local show_txt = ""
	local success_flag = 0
	if game_op_ack.opertaionID == 1060 then
		if game_op_ack.result ==  UserInfoPart.Result1 then
			show_txt = string_table.bind_success_tip
			local user = global:getGameUser()
			local recommender_Id = {}
			recommender_Id.recommenderId = self.recommenderId
			user:setProp("recommender_Id"..SocketConfig.GAME_ID,recommender_Id)
			success_flag = 1
		elseif game_op_ack.result ==  UserInfoPart.Result2 then
			show_txt = string_table.norefferrer_tip
			self.recommenderId = 0
		elseif game_op_ack.result ==  UserInfoPart.Result3 then
			show_txt = string_table.norefferrer_tip
			self.recommenderId = 0
		end 

	elseif game_op_ack.opertaionID == 1061 then
		if game_op_ack.result ==  UserInfoPart.Result4 then
			show_txt = string_table.norefferrer_tip
			self.recommenderId = 0
		elseif game_op_ack.result ==  UserInfoPart.Result1 then
			show_txt = (string.format(string_table.sure_bind_tip,self.recommenderId,game_op_ack.targetPlayerName))
			success_flag = 2
		end
	elseif game_op_ack.opertaionID == 1004 then
		return 
	end

		local tips_part = global:createPart("TipsPart",self)
		if tips_part then
			tips_part:activate({info_txt=show_txt,mid_click = function()
				-- body
				if success_flag == 1 then
					self:deactivate()
					self.owner:shopClick()
				elseif success_flag == 2 then
					self:isOkClick(self.recommenderId)
				end
			end})
		end
end


function UserInfoPart:msgGameConfigReq(type)		--申请代理
	-- body
	local net_mode = global:getModuleWithId(ModuleDef.NET_MOD)
	local apply_agency_req = hjlobby_message_pb.GetGameConfigReq()
	apply_agency_req.type = type
	net_mode:sendProtoMsg(apply_agency_req,SocketConfig.MSG_GET_GAME_CONFIG_REQ,SocketConfig.GAME_ID)
end

function UserInfoPart:msgGameConfigRsp(data)
	-- body
	local get_game_config_rsp = hjlobby_message_pb.GetGameConfigRsp()
		get_game_config_rsp:ParseFromString(data)
		print("get_game_config_rsp :　",get_game_config_rsp)
	
	if self.view ~= nil then
		self.type = get_game_config_rsp.type
		self.msg = get_game_config_rsp.msg[1]
		self.url = get_game_config_rsp.msg[2]
		self.width =  get_game_config_rsp.msg[3]
		self.height =  get_game_config_rsp.msg[4]
		self.keyword =  get_game_config_rsp.msg[5]
		self.inputParam = get_game_config_rsp.msg[6]
		self.view:showAppilaGency(self.msg,get_game_config_rsp.type)
	else 
		self.owner:msgGameConfigRsp(data)
	end
end

function UserInfoPart:appilAgencyClick()
	-- body
	if self.type == 1 then
		local webviewpart = self:getPart("WebViewPart")
		if webviewpart then
			-- webviewpart:activate()
		 --    webviewpart:loadURL(url)
		 --    webviewpart:setContentSize( -2, -2 )
		 --    webviewpart:setTransprent(true)
		 --    webviewpart:setKeyWord(keyword)
		 --    webviewpart:sendParamToJS("hello world") 
		    print("inputParam : ",self.inputParam)
		    webviewpart:activate(0,self.url,self.keyword,self.inputParam)
		    webviewpart:setTransprent(true)       
		end
	elseif self.type == 2 then
		local bridge = global:getModuleWithId(ModuleDef.BRIDGE_MOD)
		bridge:ShareToWX(1,self.msg,self.url)
		--cc.Application:getInstance():openURL(self.url)
	end
end

function UserInfoPart:split(szFullString, szSeparator)  
	local nFindStartIndex = 1  
	local nSplitIndex = 1  
	local nSplitArray = {}  
	while true do  
	   	local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)  
	   	if not nFindLastIndex then  
	   		nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))  
	    	break  
	   	end  
	   	nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)  
	   	nFindStartIndex = nFindLastIndex + string.len(szSeparator)  
	   	nSplitIndex = nSplitIndex + 1  
	end  
	return nSplitArray  
end 

function UserInfoPart:inputClick()
	-- body
	local add_room_part = self:getPart("AddRoomPart")
	add_room_part:activate(2)
end

function UserInfoPart:addReferrerId(str)
	-- body
	local txt = str
	print("--------------txt : ",txt)
	self:okClick(txt)
end
	
return UserInfoPart 