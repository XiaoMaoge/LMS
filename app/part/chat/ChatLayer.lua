local ChatLayer = class("ChatLayer",cc.load("mvc").ViewBase)
--[[
	界面处理需要保证就算是错误数据也做到不崩溃
	在获取到数据的时候进行checkData操作
]]
ChatLayer.FACE_NUM = 20
ChatLayer.TEXT_NUM = 12


ChatLayer.FACE_TYPE = 1 --表情
ChatLayer.TEXT_TYPE = 2 --文字

ChatLayer.RECORD_CD_TIME = 0.5--录音冷却事件，防止频繁操作
ChatLayer.MAX_RECORD = 30 --保存最大的语音记录条数

for i=1,ChatLayer.FACE_NUM do
	ChatLayer["FaceClick" .. (i-1)] = function(self)
		-- body
		-- self:showFaceWithPos(i-1,self.node.voice_btn)
		self:hideSz()
		self.part:sendTalkingInGameMsg(1,i-1,"","",0)
	end
end
function ChatLayer:onCreate()
	-- body
	self:init("ChatLayer")
	self.node.text_list:setItemModel(self.node.text_panel) --设置文字默认模版
	for i=1,self.TEXT_NUM do --设置快捷文字
		self.node.text_list:insertDefaultItem(i-1)
		local item = self.node.text_list:getItem(i-1)
		local txt = item:getChildByName('quick_txt')
		txt:setString(string_table["player_speak_" .. (i-1)])
	end

	self.node.text_list:addEventListener(function(target,event)
		-- body
		if event == 1 then
			local select_index = self.node.text_list:getCurSelectedIndex()
			local str = string_table["player_speak_" .. select_index]
			self:hideSz()
			--self.part:sendText(str)

--			local sex = tostring(self.part:getPlayerInfo().sex)
--			local mp3_name = ""
--			if sex == "2" then
--				mp3_name = string.format("res/sound/man/%d.mp3", select_index+1)
--			else
--				mp3_name = string.format("res/sound/female/%d.mp3", select_index+1)
--			end
--			global:getAudioModule():playSound(mp3_name,false)

			self.part:sendTalkingInGameMsg(0 , select_index , str ,"" ,0)
		end
	end)

    local winSize = cc.Director:getInstance():getWinSize()
    self.node.sz_bg_mask:hide()
    self.node.sz_bg_mask:setAnchorPoint(cc.p(0.5, 0.5))
    self.node.sz_bg_mask:setPosition(cc.p(winSize.width * 0.5, winSize.height * 0.5))
    self.node.sz_bg_mask:setContentSize(winSize)
    self.node.sz_bg_mask:onTouch(handler(self, function(reg)
        if "ended" == reg.event then
            self.node.sz_bg_mask:hide()
        end
    end ))

    local sizeMask = self.node.sz_bg_mask:getContentSize()
    self.node.sz_bg:setAnchorPoint(cc.p(0.5, 0.5))
    self.node.sz_bg:setPosition(cc.p(sizeMask.width * 0.5, sizeMask.height * 0.5))
    self.node.sz_bg:show()

    -- 进行初始化设置
    self.node.face_scroll:show()
    self.node.face_check:setSelected(true)
    self.node.face_check:setTouchEnabled(false)
    self.node.text_list:hide()
    self.node.text_check:setSelected(false)
    self.node.text_check:setTouchEnabled(true)
end


function ChatLayer:FaceEvent()
	self.part:faceEvent()
end

function ChatLayer:TextEvent()
	self.part:textEvent()
end

function ChatLayer:SendClick()
	--self.part:sendText()
	local txt = self.node.input_feild:getString()
	if txt ~= "" then
		self.part:sendTalkingInGameMsg(2,nil,txt)
		self.node.input_feild:setString("")
		self:hideSz()
	end
end

function ChatLayer:ChatClick()
	-- body
	self.node.sz_bg_mask:show()
end

function ChatLayer:VoiceRecordEvent()
	-- body
	self.part:voiceRecordEvent()
end

function ChatLayer:delayCallMsg(data)
	-- body
	local entry 
	entry = self:schedulerFunc(function()
		-- body
		self.part:playDelayAudioMsg(data)
		if entry then
			self:unScheduler(entry)
		end
	end,0.2,false)
end

-------------------------------------------------表情相关-------------------------------
function ChatLayer:hideSz() --隐藏聊天面板
	-- body
	self.node.sz_bg_mask:hide()
end

function ChatLayer:hideSzBtn()
	-- body
	self.node.chat_btn:hide()
end

function ChatLayer:showSelectedPage(page)
	-- body
	if page == self.FACE_TYPE then
		self.node.face_scroll:show()
		self.node.text_list:hide()
		self.node.text_check:setSelected(false)
		self.node.face_check:setTouchEnabled(false)
		self.node.text_check:setTouchEnabled(true)
	else
		self.node.face_scroll:hide()
		self.node.text_list:show()
		self.node.face_check:setSelected(false)
		self.node.text_check:setTouchEnabled(false)
		self.node.face_check:setTouchEnabled(true)
	end
end


--在某个位置播放表情
function ChatLayer:showFaceWithPos(faceid,pos)
	-- body
	if faceid >=0 and faceid < self.FACE_NUM then
		local sprite = cc.Sprite:createWithSpriteFrameName(string.format("%s/room/resource/chat/%d.png",self.res_base,faceid))
		sprite:setPosition(pos)
		self:addChild(sprite)
		local actions = {
						 cc.MoveBy:create(0.3,cc.p(0,10)),
						 cc.MoveBy:create(0.1,cc.p(0,-4)),
						 cc.MoveBy:create(0.1,cc.p(0,4)),
						 cc.MoveBy:create(0.1,cc.p(0,-4)),
						 cc.FadeOut:create(5.0)
						}
		local seq = transition.sequence(actions)
		local action = transition.execute(sprite,seq,{removeSelf= true})
	end
end

function ChatLayer:showYuYinWithPos(pos,viewId)
	-- body
	local sprite = cc.Sprite:createWithSpriteFrameName(self.res_base .. "/room/resource/chat/player_speaking.png")
	local size = cc.size(sprite:getContentSize().width ,sprite:getContentSize().height)
    if viewId == RoomConfig.DownSeat or viewId == RoomConfig.FrontSeat then
        pos = cc.pSub(pos,cc.p(size.width,0))
        sprite:setFlippedX(true)
    end
	sprite:setPosition(pos)
	self:addChild(sprite)
	local actions = {
					 cc.MoveBy:create(0.3,cc.p(0,10)),
					 cc.MoveBy:create(0.1,cc.p(0,-4)),
					 cc.MoveBy:create(0.1,cc.p(0,4)),
					 cc.MoveBy:create(0.1,cc.p(0,-4)),
					 cc.FadeOut:create(5.0)
					}
	local seq = transition.sequence(actions)
	local action = transition.execute(sprite,seq,{removeSelf= true})
end

-- iNo快捷语音编号    iPlayerSex玩家性别
function ChatLayer:showTextWithPos(str, pos, viewId, iNo, iPlayerSex, msgType)
	-- body
	if str then
        -- 如果类型为0则播放快捷语音
        if 0 == msgType then
            local sex = tostring(iPlayerSex)
            local mp3_name = ""
            if sex == "2" then
                mp3_name = string.format("res/sound/man/%d.mp3", iNo + 1)
            else
                mp3_name = string.format("res/sound/female/%d.mp3", iNo + 1)
            end
            global:getAudioModule():playSound(mp3_name, false)
        end

        -- 播放文字内容
		local str_txt = ccui.Text:create()
		str_txt:setFontSize(30)
		str_txt:setString(str)
		str_txt:setColor({r=0,g=0,b=0})
		local size = cc.size(str_txt:getContentSize().width + 40,str_txt:getContentSize().height + 25)
		local talk_sprite = ccui.Scale9Sprite:create(self.res_base .. '/room/resource/chat/MsgBox1.png')
		talk_sprite:setContentSize(size)
		talk_sprite:setAnchorPoint(cc.p(0,0.5))
		talk_sprite:setPosition(cc.pAdd(pos,cc.p(-25,0)))

		str_txt:setAnchorPoint(cc.p(0,0.5))

		if viewId == RoomConfig.DownSeat or viewId == RoomConfig.FrontSeat then
			talk_sprite:setFlippedX(true)
			pos = cc.pSub(pos,cc.p(size.width,0))
		end

		str_txt:setPosition(pos)

		self:addChild(talk_sprite)
		self:addChild(str_txt)

		transition.execute(str_txt,cc.FadeOut:create(7),{removeSelf = true})
		transition.execute(talk_sprite,cc.FadeOut:create(7),{removeSelf = true})
	end
end

--------------------------------------语音相关-------------------------------------------------

--默认关闭record面板
function ChatLayer:setVoiceRecordState(state)
	-- body
	if state then
		self.node.voice_msg_log:hide()
		self.node.voice_record_bg:setPosition(0,720)
	else
		self.node.voice_record_bg:setPosition(-396,720)
	end
end


function ChatLayer:intRecordProgress(maxTime)
	-- body
	self.voice_max = maxTime
	self.voicing = false
	self.record_cd = false --是否录音cd中
	-- local voice_sprite = cc.Sprite:createWithSpriteFrameName(self.res_base .."/room/resource/voice/recordProgressDisplay.png")
	-- self.node.voice_progress = cc.ProgressTimer:create(voice_sprite)
	-- self.node.voice_progress:setType(0)
	-- self.node.voice_progress:setPercentage(100)
	-- local size = self.node.voice_bg:getContentSize()
	-- self.node.voice_bg:addChild(self.node.voice_progress)
	-- self.node.voice_progress:setPosition(cc.p(size.width/2,size.height/2))
	-- self.node.voice_time:setString(maxTime)
	-- self.node.voice_record_bg:show()
	self.node.voice_record_list:setItemModel(self.node.voice_panel)
	self.node.voice_record_list:addEventListener(handler(self,ChatLayer.onListViewClick))


	self.voice_list = {}
	self.voice_playing = false
	-- local data ={
	-- 	isme = true,
	-- 	img_url = "http://wx.qlogo.cn/mmopen/Vt3en7SeZMnc4t2XACP0I2v0SAoHDlDsqtUsrgsy5yIv6icUzwR1Xm2Tesib2U4iaVlLXaOazo8EsrF8xSJF8GEM1xmURV9AMNe/0",
	-- 	voice_path = "",
	-- 	voice_lenth = 20
	-- }

	-- self:voiceListAddCell(0,data)

	-- local data1 ={
	-- 	isme = false,
	-- 	voice_path = "",
	-- 	voice_lenth = 10
	-- }
	-- self:voiceListAddCell(1,data1)

end


--播放列表中声音事件
function ChatLayer:onListViewClick(touch,event)
	-- body
	if event == 1 then
		local select_index = self.node.voice_record_list:getCurSelectedIndex()
		local item  = self.node.voice_record_list:getItem(select_index)
		local data = self.voice_list[select_index+1]
		local data1 = self.voice_list[2]
		local voice_time = item:getChildByName("voice_time_right")
		if not data.isme then
			voice_time = item:getChildByName("voice_time_left")
		end

		local voice_log = voice_time:getChildByName("voice_log")
		print("voice_time:",voice_time:getName(),item,data.isme,data1.isme,voice_log)
		if data.isme  then
			voice_log:setSpriteFrame(self.res_base .."/room/resource/voice/myVoicePic3.png")
		else
			voice_log:setSpriteFrame(self.res_base .."/room/resource/voice/otherVoicePic3.png")
		end

		voice_log:stopAllActions()
		if self.voice_playing then
			self.voice_playing = false
			return
		end

		local animation = cc.Animation:create()
		for i=1,3 do
			if data.isme  then
				local sprite_frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format(self.res_base .."/room/resource/voice/myVoicePic%d.png",i))
				animation:addSpriteFrame(sprite_frame)
			else
				local sprite_frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format(self.res_base .."/room/resource/voice/otherVoicePic%d.png",i))
				animation:addSpriteFrame(sprite_frame)
			end
		end
		animation:setDelayPerUnit(0.3)
		animation:setRestoreOriginalFrame(true)
		local action = cc.Animate:create(animation)
		voice_log:runAction(cc.Repeat:create(action,data.voice_lenth))
		self.voice_playing = true
		self.part:playRecord(select_index+1)
	end
end

---取消录音
function ChatLayer:voiceCancel()
	-- body
	if self.voicing then
		-- self.node.voice_progress:setPercentage(100)
		self.node.voice_time:setString(self.voice_max)
		self:clearScheduler()
		self.voicing = false
		self.node.voice_bg:hide()
		self.part:recordVoiceTouchUp()
	end

	self.record_cd = true  --cd中
	local time_entry = nil
	time_entry = self:schedulerFunc(function()
		-- body
		self.record_cd = false
		self:unScheduler(time_entry)
	end,ChatLayer.RECORD_CD_TIME,false)
end

function ChatLayer:VoiceTouch(node,touch,event)
	if self.record_cd == false then
		local time_entry = nil
		if not self.voicing and event == 0  then
			self.voicing = true
			self.node.voice_bg:show()
			local cur_time = self.voice_max
			time_entry = self:schedulerFunc(function()
				-- body
				cur_time =cur_time - 0.1
				if cur_time <= 0 then
					self:voiceCancel()
				else
					local percent = cur_time*100/self.voice_max
					self.node.voice_time:setString(math.floor(cur_time))
					-- self.node.voice_progress:setPercentage(percent)	
				end
			end,0.1,false)
			self.part:recordVoiceTouchDown()
		elseif event == 2 then --按钮下touchend事件
			self:voiceCancel()
		elseif event == 3 then --按钮外touchend事件
			self:voiceCancel()
		end
	end
end

--[[
创建一列语音数据
	--语音数据
	data = {
		isme = false
		img_url = ""
		voice_path = ""
		voice_lenth =  15
	}
--]]
function ChatLayer:voiceListAddCell(index,data)
	-- body
	if index > self.MAX_RECORD then
		self.removeItem(0)
		index = self.MAX_RECORD
		table.remove(self.voice_list,1)
	end

	table.insert(self.voice_list,data)

	self.node.voice_record_list:insertDefaultItem(index)
	local item = self.node.voice_record_list:getItem(index)
	local head_sprite = nil
	local voice_time = nil
	local voice_log = nil
	if data.isme then
		head_sprite =  item:getChildByName("head_sprite_right")
		voice_time = item:getChildByName("voice_time_right")
		voice_log = cc.Sprite:createWithSpriteFrameName(self.res_base .."/room/resource/voice/myVoicePic3.png")
		voice_log:setName("voice_log")
		voice_time:addChild(voice_log)
	else
		head_sprite = item:getChildByName("head_sprite_left")
		voice_time = item:getChildByName("voice_time_left")
		voice_log = cc.Sprite:createWithSpriteFrameName(self.res_base .."/room/resource/voice/otherVoicePic3.png")
		voice_log:setName("voice_log")
		voice_time:addChild(voice_log)
	end


	if voice_time then
		voice_time:show()
	else
		return
	end

	local voice_lenth_txt = voice_time:getChildByName("voice_lenth")

	if head_sprite then
		head_sprite:show()
		if data.img_url then
			local sprite =  cc.Sprite:create("common/resource/logo0.png")
			sprite:setName("head_sprite_net")
        	sprite:setAnchorPoint(cc.p(0, 0))
			self.part:loadImgToSprite(sprite,data.img_url)
			head_sprite:addChild(sprite)
		end
	else
		return
	end

	local content_size = voice_time:getContentSize()
	local voice_size = cc.size(content_size.width + data.voice_lenth*5,content_size.height)
	voice_time:setContentSize(voice_size)


	voice_lenth_txt:setString(data.voice_lenth .. "\"")
	if not data.isme then
		voice_log:setPosition(cc.p(25,content_size.height/2))
		voice_lenth_txt:setPositionX(voice_size.width + 16)
	else
		voice_log:setPosition(cc.p(voice_size.width-25,content_size.height/2))
	end

	self.node.voice_msg_log:show()

end

--返回键事件
function ChatLayer:backEvent()
	-- body
	self:hideSz()
end

function ChatLayer:MaskClick()
	-- body
	self:hideSz()
end

-- -- 房间规则信息
-- function ChatLayer:HelpPicClick()
-- 	print("HelpPicClick..........................");
-- 	-- self.part:showHelpInfo();
-- 	self.part.owner:showHelpInfo();
-- end

return ChatLayer
