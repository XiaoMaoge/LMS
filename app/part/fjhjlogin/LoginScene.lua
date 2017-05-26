local LoginScene = class("LoginScene",cc.load("mvc").ViewBase)
--[[
    界面处理需要保证就算是错误数据也做到不崩溃
    在获取到数据的时候进行checkData操作
]]
function LoginScene:onCreate(data) --传入数据
    -- body
    self:init("LoginScene",true)
end


function LoginScene:WXLogin()
    local isagree = self.node.agree_check:isSelected()
    self.node.tip_text:setVisible(false)
    if isagree == true then
        if self.part ~= nil then
            global:getAudioModule():playSound("res/sound/Button32.mp3",false)
            self.part:WXLogin()
        end
    else
        self.node.tip_text:setVisible(true)
    end
end

function LoginScene:AgreeClick()
    self.part:agreeClick()
end

function LoginScene:AgreeCheck()
    self.node.tip_text:setVisible(false)
end

function LoginScene:backEvent()
    -- body
    self.part:backEvent()
end


function LoginScene:showLogin()
    -- body
    self.node.wx_btn:show()
    self.node.agree_panel:show()
    self.node.update_progress:hide()
end

function LoginScene:setLoginBtnState(enable)
    if self.node.wx_btn then
        self.node.wx_btn:setVisible(enable)
    end
end


function LoginScene:updateAudio(  )
    -- body
    local audio_manager = global:getModuleWithId(ModuleDef.AUDIO_MOD)
    local index = audio_manager:initProgress()
    if index < audio_manager.max_index then
        local percent = index * 100/audio_manager.max_index
        self.node.update_progress:setPercent(percent)
        -- local move_pos = cc.p(6.76*percent,13.5)
        -- self.node.progress_light:setPosition(move_pos)
        self.node.update_info:setString("正在加载资源，稍等片刻" .. math.ceil(percent) .. "%")
    elseif self.load_lobby == false then
        self.load_lobby = true
        self.part:checkAccount()
    end
end

--预加载音效
function LoginScene:updateAudioFile()
    -- body
    self.load_lobby = false
    self.node.update_progress:setPercent(0)
    self.node.update_progress:show()
    self.node.root:onUpdate(handler(self,LoginScene.updateAudio))
end


return LoginScene
