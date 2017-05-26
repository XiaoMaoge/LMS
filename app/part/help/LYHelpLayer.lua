local HelpLayer = import(".HelpLayer")
local LYHelpLayer = class("LYHelpLayer",HelpLayer)
--[[
	界面处理需要保证就算是错误数据也做到不崩溃
	在获取到数据的时候进行checkData操作
]]
function LYHelpLayer:selectChoose(rule_type)
	print("---------------test--------------LYHelpLayer:selectChoose")
	-- body
	for i=1,2 do --关闭当前选择
		if i ~= rule_type then
			self.node["choose_select" .. i]:setSelected(false)
			self.node["choose_select" .. i]:setTouchEnabled(true)
			self.isSelect = true
		else 
			self.node["choose_select" .. i]:setSelected(true)
			self.node["choose_select" .. i]:setTouchEnabled(false)
			self.isSelect = false
		end
	end

	self.rule1 = rule_type
	self.part:selectrule(1)
end

return LYHelpLayer
