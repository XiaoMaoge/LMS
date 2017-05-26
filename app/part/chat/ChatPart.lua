-- local BasePart = require("packages.mvc.BasePart")
local CURRENT_MODULE_NAME = ...
local ChatPart = class("ChatPart",cc.load('mvc').PartBase) --登录模块
ChatPart.DEFAULT_PART = {}
ChatPart.DEFAULT_VIEW = "ChatLayer"
--[
-- @brief 构造函数
--]
function ChatPart:ctor(owner)
    ChatPart.super.ctor(self, owner)
    self:initialize()
end

--[
-- @override
--]
function ChatPart:initialize()
	self.cur_select =  self.FACE_TYPE --默认打开表情页面
	self.record_list = {}
end

--激活模块
--[[
	pos_table = { --激活需要传入表情坐标table(相对整个界面的坐标)
		cc.p()
		cc.p()
	}
--]]
function ChatPart:activate(posTable)
	if not posTable then
		printLog('warning',"pos table is nil activate chat part fail")
	end

	self.m_pos = seat_id

	local net_mode = global:getModuleWithId(ModuleDef.NET_MOD)
	net_mode:registerMsgListener(MsgDef.MSG_TALKING_IN_GAME,handler(self,ChatPart.recTalkingInGameMsg))

	self.pos_table = posTable
	self.voice_record_show = false --是否隐藏聊天记录界面
	ChatPart.super.activate(self,CURRENT_MODULE_NAME)
	self.view:intRecordProgress(29)
	local lua_bridge = global:getModuleWithId(ModuleDef.BRIDGE_MOD)
	lua_bridge:addEventListener("nativeOnRecordVoiceEnd",handler(self,ChatPart.onRecordVoiceEnd))
	-- self.view:showSelectedPage(self.cur_select)
    
    -- 重置默认打开表情页面
    self.cur_select =  self.FACE_TYPE
end

function ChatPart:showFaceWithIndex(faceId,index)
	-- body
	if self.pos_table[index] then
		self.view:showFaceWithPos(faceId,self.pos_table[index])
	end
end

function ChatPart:deactivate()
	local lua_bridge = global:getModuleWithId(ModuleDef.BRIDGE_MOD)
	lua_bridge:removeEventListenersByEvent("nativeOnRecordVoiceEnd")

	local net_mode = global:getModuleWithId(ModuleDef.NET_MOD)
	net_mode:unRegisterMsgListener(MsgDef.MSG_TALKING_IN_GAME)

	self.view:removeSelf()
	self.view =  nil
end

function ChatPart:getPartId()
	-- body
	return "ChatPart"
end

--开始录音
function ChatPart:recordVoiceTouchDown()
	-- body
	local lua_bridge = global:getModuleWithId(ModuleDef.BRIDGE_MOD)
	local player_info = self.owner:getPlayerInfo(1)

	local audio_mod = global:getModuleWithId(ModuleDef.AUDIO_MOD)
	audio_mod:pause()
	lua_bridge:recordVoiceTouchDown(player_info.uid)
end

--结束录音
function ChatPart:recordVoiceTouchUp()
	-- body
	local lua_bridge = global:getModuleWithId(ModuleDef.BRIDGE_MOD)
	lua_bridge:recordVoiceTouchUp()
end

function ChatPart:onRecordVoiceEnd(event)
	-- body
	local lua_bridge = global:getModuleWithId(ModuleDef.BRIDGE_MOD)
	lua_bridge:playRecordAudio(event.vpath,event.vlen,function(audioData,size)
		-- body
		self:sendTalkingInGameMsg(3,nil,"",audioData,event.vlen)
	end)
	local user = global:getGameUser()
	local data = {
		isme = true,
		img_url = "",
		voice_path = event.vpath,
		voice_lenth = math.floor(event.vlen)
	}
	local index = #self.record_list
	table.insert(self.record_list,data)
	-- self.view:voiceListAddCell(index,data)
end

function ChatPart:sendText(str, pos, iNo, iPlayerSex, msgType)
	-- body
	self.view:showTextWithPos(str, self.pos_table[pos], pos, iNo, iPlayerSex, msgType)
end


--播放从服务端接收的语音数据
function ChatPart:playAudioMsg(data)
	-- body
	if data == nil then
		return
	end
	print("this is playAudioMsg:",string.len(data.audio))
	if string.len(data.audio) < 40 then --判断数据长度
		return
	end


	local user = global:getGameUser()
	local uid = user:getProp("uid")
	local cur_time = os.time()
	local random_num = math.random()
	local save_path = string.format("%saudio_%d_%d_%d.spx", cc.FileUtils:getInstance():getWritablePath(),cur_time,random_num,uid)
	local lua_bridge = global:getModuleWithId(ModuleDef.BRIDGE_MOD)

	if lua_bridge:saveFile(save_path,data.audio,string.len(data.audio)) == false then
		printInfo("Warring","play audio msg save file fail")
		return
	end

	-- body
	lua_bridge:playRecordAudio(save_path,data.audioLenth)

	local user = global:getGameUser()
	local audio_data = {
		isme = false,
		img_url = "",
		voice_path = save_path,
		voice_lenth = math.floor(data.audioLenth)
	}
	local index = #self.record_list
	table.insert(self.record_list,audio_data)
	-- self.view:voiceListAddCell(index,audio_data)
	local view_id = self:changeSeatToView(data.playerPos)
	self.view:showYuYinWithPos(self.pos_table[view_id],view_id)
end

function ChatPart:faceEvent()
	-- body
	if self.cur_select ~= self.view.FACE_TYPE then
		self.cur_select = self.view.FACE_TYPE
		self.view:showSelectedPage(self.cur_select)
	end
end

function ChatPart:textEvent()
	-- body
	if self.cur_select ~= self.view.TEXT_TYPE then
		self.cur_select = self.view.TEXT_TYPE
		self.view:showSelectedPage(self.cur_select)
	end
end

function ChatPart:voiceRecordEvent()
	-- body
	self.voice_record_show = not self.voice_record_show
	self.view:setVoiceRecordState(self.voice_record_show)
end

function ChatPart:loadImgToSprite(sprite,url)
	-- body
	local lua_bridge = global:getModuleWithId(ModuleDef.BRIDGE_MOD)
    lua_bridge:startDownloadImg(url,sprite)
end

function ChatPart:playRecord(index)
	-- body
	local data = self.record_list[index]
	local lua_bridge = global:getModuleWithId(ModuleDef.BRIDGE_MOD)
	lua_bridge:playRecordAudio(data.voice_path,data.voice_lenth)
end

function ChatPart:hideSz()
	-- body
	self.view:hideSz()
end

function ChatPart:showSz()
	-- body
	self.view:ChatClick()
end

function ChatPart:hideSzBtn()
	-- body
	self.view:hideSzBtn()
end

function ChatPart:getPlayerInfo()
	-- body
	return self.owner:getPlayerInfo(1)
end

function ChatPart:getPlayerInfo()
 	-- body
	return self.owner:getPlayerInfo(1)
end

function ChatPart:sendTalkingInGameMsg(msgType , msgNo , msgText ,audio ,audioLenth)				--请求版本是否更新
	print("----send sendTalkingInGameMsg success")
	local net_manager = global:getNetManager()
	local send_talking_msg = ycmj_message_pb.TalkingInGameMsg()

	--send_talking_msg.playerPos = 1  		貌似服务端会帮我们填好位置和性别
	--send_talking_msg.playerSex = 2
	send_talking_msg.msgType = msgType 		--消息类型  0：系统自带快捷语音 1：系统表情 2:自定义文字,3语音
	if msgNo then
		send_talking_msg.msgNo = msgNo 
	end

	if msgText then
		send_talking_msg.msgText = msgText
	end

	if audio then
		send_talking_msg.audio = audio
	end

	if audioLenth then
		send_talking_msg.audioLenth = audioLenth
	end	
	
	local buff_str = send_talking_msg:SerializeToString()
	local buff_lenth = send_talking_msg:ByteSize()

	net_manager:sendProtoMsg(send_talking_msg,MsgDef.MSG_TALKING_IN_GAME,SocketConfig.GAME_ID)
end

function ChatPart:recTalkingInGameMsg(data,appId)

	local rec_talking_msg = ycmj_message_pb.TalkingInGameMsg()
	rec_talking_msg:ParseFromString(data)

	local msgType = rec_talking_msg.msgType
	local msgText = rec_talking_msg.msgText
	local playerPos = self:changeSeatToView(rec_talking_msg.playerPos)
    
	if msgType == 0 or msgType == 2 then
        -- rec_talking_msg.msgNo    表情，快捷语音编号   rec_talking_msg.playerSex 
		self:sendText(msgText, playerPos, rec_talking_msg.msgNo, rec_talking_msg.playerSex, msgType)
	elseif msgType == 1 then
		self.view:showFaceWithPos(rec_talking_msg.msgNo,self.pos_table[playerPos])
	elseif msgType == 3 then
		self:playAudioMsg(rec_talking_msg)
	end
end

--将逻辑座位转换为界面座位
function ChatPart:changeSeatToView(seatId) --座位顺时针方向增加 1 - 4
	-- body
	return self.owner:changeSeatToView(seatId)
end


return ChatPart
