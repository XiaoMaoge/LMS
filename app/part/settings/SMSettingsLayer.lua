local SMSettingsLayer = class("SMSettingsLayer",cc.load("mvc").ViewBase)
--[[
	界面处理需要保证就算是错误数据也做到不崩溃
	在获取到数据的时候进行checkData操作
]]
function SMSettingsLayer:onCreate(data) --传入数据
	-- body
	self:addMask()
	self:init("SMSettingsLayer")
	local user_info = global:getGameUser():getProps()
	-- user_info.photo = "http://wx.qlogo.cn/mmopen/JBQEPjTjtXTO1vUiaIyxmSuZOS3p0PgQ7dX6YSKdKw0Cd5vcUZazUbBkZw2XbG3BoQVfKdgjicxrUPwZQMq3bgZZ4GtFM1kJg6/0"
	self.node.head_sprite:show()
	Util.loadHeadImg(user_info.photo,self.node.head_sprite)
end

function SMSettingsLayer:AddSpriteFrame()
	cc.SpriteFrameCache:getInstance():addSpriteFrames(self.res_base .. "/lobby/resource/settings/settings_picture.plist")
end

function SMSettingsLayer:ChangeAccountClick()
	global:getAudioModule():playSound("res/sound/confirm.mp3",false)
	self.part:changAccount()
end

function SMSettingsLayer:FuWuClick()
	self.part:linkFuWu()
end

function SMSettingsLayer:YinSiClick()
	self.part:linkYinSi()
end

function SMSettingsLayer:MusicEvent()
	print("this is MusicEvent------------------------:")
	self.part:changeMusicState()
end

function SMSettingsLayer:SoundEvent()
	print("this is SoundEvent------------------------:")
	self.part:changeSoundState()
end

function SMSettingsLayer:setSoundState(on)
	-- body
	self:AddSpriteFrame();
	if on then
		self.node.sound_check:loadTexture(self.res_base .. "/fjhjlobby/resource/settings/sz_ON.png",1)
	else
		self.node.sound_check:loadTexture(self.res_base .. "/fjhjlobby/resource/settings/sz_OFF.png",1)
	end
end

function SMSettingsLayer:setMusicState(on)
	-- body
	print("kljljljljljljljljljljljljljljljljljlj", on);
	self:AddSpriteFrame();
	if on then
		self.node.music_check:loadTexture(self.res_base .. "/fjhjlobby/resource/settings/sz_ON.png",1)
	else
		self.node.music_check:loadTexture(self.res_base .. "/fjhjlobby/resource/settings/sz_OFF.png",1)
	end

end

function SMSettingsLayer:CloseClick()
	-- body
	global:getAudioModule():playSound("res/sound/Button32.mp3",false)
	self.part:deactivate()
end

return SMSettingsLayer
