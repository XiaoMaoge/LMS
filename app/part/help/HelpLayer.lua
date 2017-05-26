local HelpLayer = class("HelpLayer",cc.load("mvc").ViewBase)
--[[
	界面处理需要保证就算是错误数据也做到不崩溃
	在获取到数据的时候进行checkData操作
]]
function HelpLayer:onCreate(data) --传入数据
	-- body
	self:addMask()
	self:init("HelpLayer")
	self.rule1 = 2
	self.rule2 = 1
	for i=1,2 do
		HelpLayer["ChooseSelect" .. i] = function(self)
			self.part:selectChoose(i)
		end
	end
	self.node["choose_select1"]:setTouchEnabled(true)
	self.node["choose_select2"]:setTouchEnabled(false)

	for i=1,4 do
		HelpLayer["ruleSelectEvent" .. i] = function(self)
			self.part:selectrule(i)
		end
	end
	self.node["rule_select1"]:setTouchEnabled(false)
end

function HelpLayer:selectChoose(rule_type)
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

	if rule_type == 1 then
		self.node.rule_select3:show()
		self.node.rule_select4:show()
	elseif rule_type == 2 then
		self.node.rule_select3:hide()
		self.node.rule_select4:hide()
	end
	self.rule1 = rule_type
	self.part:selectrule(1)
end

function HelpLayer:selectrule(rule_type)
	-- body
	self.node.rule_list:jumpToTop()
	for i=1,4 do --关闭当前选择
		if i ~= rule_type then
			self.node["rule_select" .. i]:setSelected(false)
			self.node["rule_select" .. i]:setTouchEnabled(true)
			self.isSelect = true
		else 
			self.node["rule_select" .. i]:setSelected(true)
			self.node["rule_select" .. i]:setTouchEnabled(false)
			self.isSelect = false
		end
	end

	self.rule2 = rule_type
	
	self.node.rule_list:removeAllChildren();
	local Filename = self.res_base .. "/lobby/resource/help/rule"..self.rule1.."type"..self.rule2..".png"
	-- print("Filename : ",Filename)
	-- local innerSize = self.node.rule_list:getIns
	local sprite = cc.Sprite:create(Filename);
	sprite:setAnchorPoint(0.5, 1);
	local innerSize = self.node.rule_list:getInnerContainerSize();
	sprite:setPosition(cc.p(self.node.rule_list:getContentSize().width / 2, sprite:getContentSize().height));
	
	self.node.rule_list:addChild(sprite);
	self.node.rule_list:sortAllChildren();
	
	self.node.rule_list:setInnerContainerSize({width = self.node.rule_list:getContentSize().width, height = sprite:getContentSize().height});
end

function HelpLayer:CloseClick()
    global:getAudioModule():playSound("res/sound/Button32.mp3",false)
	self.part:deactivate()
end

return HelpLayer
