local LoginScene = class("LoginScene",cc.load("mvc").ViewBase)
--[[
	界面处理需要保证就算是错误数据也做到不崩溃
	在获取到数据的时候进行checkData操作
]]
function LoginScene:onCreate(data) --传入数据
	-- body

	self:init("LoginScene",true)
	self.node.login_btn:hide()
end


function LoginScene:LoginClick()
    global:getAudioModule():playSound("res/sound/Button32.mp3",false)
    self.part:WXLogin()
end

function LoginScene:backEvent()
	-- body
	self.part:backEvent()
end

function LoginScene:showLogin()
	-- body
	self.node.login_btn:show()
end


return LoginScene
