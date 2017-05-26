-- local BasePart = require("packages.mvc.BasePart")
local CURRENT_MODULE_NAME = ...
local SettingsPart = class("SettingsPart",cc.load('mvc').PartBase) --登录模块
SettingsPart.DEFAULT_VIEW = "SettingsLayer"

--[
-- @brief 构造函数
--]
function SettingsPart:ctor(owner)
    SettingsPart.super.ctor(self, owner)
    self:initialize()
end

--[
-- @override
--]
function SettingsPart:initialize()
	


end

--激活模块
function SettingsPart:activate(data)
    SettingsPart.super.activate(self, CURRENT_MODULE_NAME)
    local audio_manager = global:getModuleWithId(ModuleDef.AUDIO_MOD)

    self.sound_value = false
    self.music_value = false

    self.sound_value = cc.UserDefault:getInstance():getBoolForKey("EffectON", true)
    self.music_value = cc.UserDefault:getInstance():getBoolForKey("MusicON", true)

--    if audio_manager:getVolume() > 0 then
--        self.sound_value = true
--    end 

--    if audio_manager:getMusic() > 0 then
--        self.music_value = true
--    end

    self.view:setSoundState(self.sound_value)
    self.view:setMusicState(self.music_value)
 
end

function SettingsPart:deactivate()
    self.view:removeSelf()
    self.view =  nil
end

function SettingsPart:getPartId()
	-- body
	return "SettingsPart"
end

function SettingsPart:changAccount()
  -- body
  local tips_part = global:createPart("TipsPart",self)--require('app.part.tips.TipsPart').new(self)
  if tips_part then
    tips_part:activate({info_txt=string_table.change_account,left_click=function()
      -- body
        local login_part = global:activatePart("LoginPart")
        login_part:showLogin()
    end})
  end
end

function SettingsPart:linkYinSi()
  -- body
  cc.Application:getInstance():openURL("http://www.highlightsky.com/mj/service_terms_and_privacy_policy.html")
end

function SettingsPart:linkFuWu()
  -- body
  cc.Application:getInstance():openURL("http://www.highlightsky.com/mj/service_terms_and_privacy_policy.html")
end

function SettingsPart:changeMusicState()
    self.music_value = not self.music_value
    local audio_manager = global:getModuleWithId(ModuleDef.AUDIO_MOD)
    if self.music_value then
        audio_manager:setMusic(1)
    else
        audio_manager:setMusic(0)
    end
    audio_manager:saveVolume()

    cc.UserDefault:getInstance():setBoolForKey("MusicON", self.music_value)
    cc.UserDefault:getInstance():flush()

    self.view:setMusicState(self.music_value)
end

function SettingsPart:changeSoundState()
  -- body
    self.sound_value = not self.sound_value
    local audio_manager = global:getModuleWithId(ModuleDef.AUDIO_MOD)
    if self.sound_value then
        audio_manager:setVolume(1)
    else
        audio_manager:setVolume(0)
    end
    audio_manager:saveVolume()

    cc.UserDefault:getInstance():setBoolForKey("EffectON", self.sound_value)
    cc.UserDefault:getInstance():flush()

    self.view:setSoundState(self.sound_value)
end

return SettingsPart 