local CardOptNode = class("CardOptNode",cc.load("mvc").ViewBase)
--[[
	界面处理需要保证就算是错误数据也做到不崩溃
	在获取到数据的时候进行checkData操作
]]

function CardOptNode:ctor(...)
    CardOptNode.super.ctor(self, ...)

    -- self.retain()
end

function CardOptNode:onCreate()
	-- body
    self:retain()
	self:init("CardOptNode")
end

function CardOptNode:playAnimate(type)
	-- body
	if type == RoomConfig.Peng then
		self.node.peng_sprite:show()
	elseif type == RoomConfig.AnGang or type == RoomConfig.MingGang or type == RoomConfig.BuGang then
		self.node.gang_sprite:show()
	elseif type == RoomConfig.Chi then
		self.node.chi_sprite:show()
	--elseif type == RoomConfig.Hu then
	--	self.node.hu_sprite:show()
	end

	local animate = self.node.animation
	self.node.root:runAction(animate)
	animate:gotoFrameAndPlay(0,false)
	animate:setLastFrameCallFunc(function()
		-- body
		self.part:animateOver()
		self:removeSelf()
	end)
end

function CardOptNode:onExit()
    local tableActions = { }
    tableActions[1] = cc.DelayTime:create(1.0)
    tableActions[2] = cc.CallFunc:create(handler(self, function()
        self:release()
    end ))
    self:runAction(cc.Sequence:create(tableActions))
end


return CardOptNode