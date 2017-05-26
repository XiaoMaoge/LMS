local TipsLayer = class("TipsLayer",cc.load("mvc").ViewBase)
--[[
	界面处理需要保证就算是错误数据也做到不崩溃
	在获取到数据的时候进行checkData操作
]]
function TipsLayer:onCreate(data) --传入数据
	-- body
	self:addMask()
	self:init("TipsLayer")
end


--[[
   info ={
		info_txt = "",
		right_click = func
		left_click = func
		mid_click= func
   }

   默认定义了左边点击事件就是两个按钮
--]]
function TipsLayer:setInfo(info)
	-- body
	if info.left_click == nil then
		self.node.type_1:show()
		self.node.type_2:hide()
	else
		self.node.type_2:show()
		self.node.type_1:hide()
	end

	self.info = info
	
	if info and info.info_txt then
		self.node.info:setString(info.info_txt)
	end
end

function TipsLayer:OkClick()
	if self.info and self.info.mid_click then
		self.info.mid_click()
	end

	if self.info and self.info.left_click then
		self.info.left_click()
	end
	
	if self.info and self.part then
		self.part:deactivate()
	end  
end

function TipsLayer:CancelClick()
	-- body
	if self.info and self.info.right_click then
		self.info.right_click()
	end

	if self.part then
		self.part:deactivate()
	end
end

return TipsLayer