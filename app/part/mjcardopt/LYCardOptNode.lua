local CardOptNode = import(".CardOptNode")
local LYCardOptNode = class("LYCardOptNode",CardOptNode)

function LYCardOptNode:playAnimate(type)
-- body
	if type == RoomConfig.Peng then
		self.node.peng_sprite:show()
	elseif type == RoomConfig.AnGang or type == RoomConfig.MingGang or type == RoomConfig.BuGang then
		self.node.gang_sprite:show()
	elseif type == RoomConfig.Chi then
		self.node.chi_sprite:show()

	elseif type == RoomConfig.BuHua then
		self.node.buhua_sprite:show()
	elseif type == RoomConfig.MAHJONG_QIANG_JIN then
		self.node.qiangjin_sprite:show()
	elseif type == RoomConfig.MAHJONG_SAN_JIN_DAO then
		self.node.sanjindao_sprite:show()
	elseif type == RoomConfig.MAHJONG_SI_JIN_DAO then
		self.node.sijindao_sprite:show()
	elseif type == RoomConfig.MAHJONG_WU_JIN_DAO then
		self.node.wujindao_sprite:show()
	elseif type == RoomConfig.MAHJONG_LIU_JIN_DAO then
		self.node.liujindao_sprite:show()
	elseif type == RoomConfig.MAHJONG_DAN_YOU then
		self.node.danyou_sprite:show()
	elseif type == RoomConfig.MAHJONG_SHUANG_YOU then
		self.node.shuangyou_sprite:show()
	elseif type == RoomConfig.MAHJONG_SAN_YOU then
		self.node.sanyou_sprite:show()
	elseif type == RoomConfig.MAHJONG_CHA_PAI then
		self.node.chapai_sprite:show()
	elseif type == RoomConfig.MAHJONG_CHA_HUA then
		self.node.chahua_sprite:show()

	end

	local animate = self.node.animation
	self.node.root:runAction(animate)
	animate:gotoFrameAndPlay(0,false)
	animate:setLastFrameCallFunc(function()
		-- body
		self:removeSelf()
		self.part:animateOver()
	end)
end

return LYCardOptNode