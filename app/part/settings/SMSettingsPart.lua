-- local BasePart = require("packages.mvc.BasePart")
local CURRENT_MODULE_NAME = ...
local SMSettingsPart = class("SMSettingsPart",cc.load('mvc').PartBase) --登录模块
SMSettingsPart.DEFAULT_VIEW = "SMSettingsLayer"

--[
-- @brief 构造函数
--]
function SMSettingsPart:ctor(owner)
    SMSettingsPart.super.ctor(self, owner)
    self:initialize()
end

--[
-- @override
--]
function SMSettingsPart:initialize()
	


end

--激活模块
function SMSettingsPart:activate(data)
	SMSettingsPart.super.activate(self,CURRENT_MODULE_NAME)
  local audio_manager = global:getModuleWithId(ModuleDef.AUDIO_MOD)
  self.sound_value = false
  self.music_value = false
  if audio_manager:getVolume() > 0 then
    self.sound_value = true
  end 

  if audio_manager:getMusic() > 0 then
    self.music_value = true
  end
  self.view:setSoundState(self.sound_value)
  self.view:setMusicState(self.music_value)
 
end

function SMSettingsPart:deactivate()
	self.view:removeSelf()
  self.view =  nil
end

function SMSettingsPart:getPartId()
	-- body
	return "SMSettingsPart"
end

function SMSettingsPart:changAccount()
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

function SMSettingsPart:linkYinSi()
  -- body
  cc.Application:getInstance():openURL("http://www.highlightsky.com/mj/service_terms_and_privacy_policy.html")
end

function SMSettingsPart:linkFuWu()
  -- body
  cc.Application:getInstance():openURL("http://www.highlightsky.com/mj/service_terms_and_privacy_policy.html")
end

function SMSettingsPart:changeMusicState()
  -- body
    self.music_value = not self.music_value
    local audio_manager = global:getModuleWithId(ModuleDef.AUDIO_MOD)
    if self.music_value  then
      audio_manager:setMusic(1)
    else
      audio_manager:setMusic(0)
    end
    audio_manager:saveVolume()
    self.view:setMusicState(self.music_value)
end

function SMSettingsPart:changeSoundState()
  -- body
  self.sound_value = not self.sound_value
  local audio_manager = global:getModuleWithId(ModuleDef.AUDIO_MOD)
  if self.sound_value  then
     audio_manager:setVolume(1)
  else
     audio_manager:setVolume(0)
  end
  audio_manager:saveVolume()
   self.view:setSoundState(self.sound_value)
end

return SMSettingsPart 