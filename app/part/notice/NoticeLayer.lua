local NoticeLayer = class("NoticeLayer",cc.load("mvc").ViewBase)
--[[
	界面处理需要保证就算是错误数据也做到不崩溃
	在获取到数据的时候进行checkData操作
]]
function NoticeLayer:onCreate(data) --传入数据
	-- body
	self:addMask()
	self:init("NoticeLayer")
end


function NoticeLayer:CloseClick()
    global:getAudioModule():playSound("res/sound/Button32.mp3",false)
	self.part:deactivate()
end

function NoticeLayer:setNoticeInfo(str)
	-- body

	self.node.notice_txt:setString(str)
end

-- 设置标题
function NoticeLayer:setTitleText(strText)
    self.node.notice_txt_title:setString(strText)
end

return NoticeLayer
