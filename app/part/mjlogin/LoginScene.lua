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
end


return LoginScene
