local RoomSettingLayer = class("RoomSettingLayer",cc.load("mvc").ViewBase)
--[[
	界面处理需要保证就算是错误数据也做到不崩溃
	在获取到数据的时候进行checkData操作
]]
function RoomSettingLayer:onCreate(data) --传入数据
	-- body
	self:addMask()
	self:init("RoomSettingLayer")

    local bSoundOn = cc.UserDefault:getInstance():getBoolForKey("EffectON", true)
    if bSoundOn then
        self.node.Button_sound_on:show()
        self.node.Button_sound_off:hide()
    else
        self.node.Button_sound_on:hide()
        self.node.Button_sound_off:show()
    end

    local bMusicOn = cc.UserDefault:getInstance():getBoolForKey("MusicON", true)
    if bMusicOn then
        self.node.Button_music_on:show()
        self.node.Button_music_off:hide()
    else
        self.node.Button_music_on:hide()
        self.node.Button_music_off:show()
    end

	self.node.music_slider:addEventListener(handler(self,RoomSettingLayer.musicEvent))
	self.node.sound_slider:addEventListener(handler(self,RoomSettingLayer.soundEvent))
end

function RoomSettingLayer:musicEvent(ref,event)
	-- body
	local percent = self.node.music_slider:getPercent()
	local cur_music = percent/100
	self.part:musicEvent(cur_music)
end

function RoomSettingLayer:soundEvent(ref,event)
	-- body
	local percent = self.node.sound_slider:getPercent()
	local cur_sound = percent/100
	self.part:soundEvent(cur_sound)
end

function RoomSettingLayer:setSlider(cur_sound,cur_music)
	if cur_sound == nil then
		cur_sound = 1 
	end

	if cur_music == nil then
		cur_music = 1 
	end
    self.node.music_slider:setPercent(cur_music * 100)
    self.node.sound_slider:setPercent(cur_sound * 100)
end

function RoomSettingLayer:MusicEvent()
	self.part:changeMusicState()
end

function RoomSettingLayer:SoundEvent()
	self.part:changeSoundState()
end

function RoomSettingLayer:setSoundState(on)
	-- body
	-- self.node.sound_check:setSelected(on)

	if on then
		self.node.sound_slider:setPercent(100)

        self.node.Button_sound_on:show()
        self.node.Button_sound_off:hide()

        cc.UserDefault:getInstance():setBoolForKey("EffectON", true)
        cc.UserDefault:getInstance():flush()
	else
		self.node.sound_slider:setPercent(0)

        self.node.Button_sound_on:hide()
        self.node.Button_sound_off:show()

        cc.UserDefault:getInstance():setBoolForKey("EffectON", false)
        cc.UserDefault:getInstance():flush()
	end
end

function RoomSettingLayer:setMusicState(on)
	-- body
	-- self.node.music_check:setSelected(on)

	if on then
		self.node.music_slider:setPercent(100)

        self.node.Button_music_on:show()
        self.node.Button_music_off:hide()

        cc.UserDefault:getInstance():setBoolForKey("MusicON", true)
        cc.UserDefault:getInstance():flush()
	else
		self.node.music_slider:setPercent(0)

        self.node.Button_music_on:hide()
        self.node.Button_music_off:show()

        cc.UserDefault:getInstance():setBoolForKey("MusicON", false)
        cc.UserDefault:getInstance():flush()
	end
end

function RoomSettingLayer:CloseClick()
	-- body
	global:getAudioModule():playSound("res/sound/Button32.mp3",false)
	self.part:deactivate()
end

function RoomSettingLayer:CloseVipRoomClick()
	-- body
	global:getAudioModule():playSound("res/sound/Button32.mp3",false)
	self.part:closeVipRoomClick()
end

function RoomSettingLayer:isShowCloseBtn(data)
	-- body
	if data > 1 then	
		self.node.close_vip_btn:show()
	else
		self.node.close_vip_btn:hide()
	end
end

return RoomSettingLayer
