local SettingsLayer = class("SettingsLayer",cc.load("mvc").ViewBase)
--[[
	界面处理需要保证就算是错误数据也做到不崩溃
	在获取到数据的时候进行checkData操作
]]
function SettingsLayer:onCreate(data) --传入数据
	-- body
	self:addMask()
	self:init("SettingsLayer")
	local user_info = global:getGameUser():getProps()
	-- user_info.photo = "http://wx.qlogo.cn/mmopen/JBQEPjTjtXTO1vUiaIyxmSuZOS3p0PgQ7dX6YSKdKw0Cd5vcUZazUbBkZw2XbG3BoQVfKdgjicxrUPwZQMq3bgZZ4GtFM1kJg6/0"
	self.node.head_sprite:show()
	Util.loadHeadImg(user_info.photo,self.node.head_sprite)
end

function SettingsLayer:AddSpriteFrame()
	cc.SpriteFrameCache:getInstance():addSpriteFrames(self.res_base .. "/fjhjlobby/resource/settings/settings_picture.plist")
end

function SettingsLayer:ChangeAccountClick()
	global:getAudioModule():playSound("res/sound/confirm.mp3",false)
	self.part:changAccount()
end

function SettingsLayer:FuWuClick()
	self.part:linkFuWu()
end

function SettingsLayer:YinSiClick()
	self.part:linkYinSi()
end

function SettingsLayer:MusicEvent()
	print("this is MusicEvent------------------------:")
	self.part:changeMusicState()
end

function SettingsLayer:SoundEvent()
	print("this is SoundEvent------------------------:")
	self.part:changeSoundState()
end

function SettingsLayer:setSoundState(on)
	-- body
	self:AddSpriteFrame()
	if on then
		self.node.sound_check:loadTexture(self.res_base .. "/fjhjlobby/resource/settings/sz_ON.png",1)
	else
		self.node.sound_check:loadTexture(self.res_base .. "/fjhjlobby/resource/settings/sz_OFF.png",1)
	end
end

function SettingsLayer:setMusicState(on)
	-- body
	self:AddSpriteFrame();
	if on then
		self.node.music_check:loadTexture(self.res_base .. "/fjhjlobby/resource/settings/sz_ON.png",1)
	else
		self.node.music_check:loadTexture(self.res_base .. "/fjhjlobby/resource/settings/sz_OFF.png",1)
	end

end

function SettingsLayer:CloseClick()
	-- body
	global:getAudioModule():playSound("res/sound/Button32.mp3",false)
	self.part:deactivate()
end

return SettingsLayer
