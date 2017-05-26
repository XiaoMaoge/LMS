local CardOptNode = import(".CardOptNode")
local SMCardOptNode = class("SMCardOptNode",CardOptNode)

function SMCardOptNode:playAnimate(type)
	-- body
   
	if type == RoomConfig.Peng then
		self.node.peng_sprite:show()
	elseif type == RoomConfig.AnGang or type == RoomConfig.MingGang or type == RoomConfig.BuGang then
		self.node.gang_sprite:show()
	elseif type == RoomConfig.BuHua then
		self.node.buhua_sprite:show()
	elseif type == RoomConfig.Chi then
		self.node.chi_sprite:show()
	elseif type == RoomConfig.MAHJONG_DAN_YOU then
		self.node.danyou_sprite:show()
	elseif type == RoomConfig.MAHJONG_SHUANG_YOU then
		self.node.shuangyou_sprite:show()
	elseif type == RoomConfig.MAHJONG_SAN_YOU then
		self.node.sanyou_sprite:show()
	elseif type == RoomConfig.MAHJONG_QIANG_JIN then
		self.node.qiangjin_sprite:show()
	elseif type == RoomConfig.MAHJONG_SAN_JIN_DAO then
		self.node.sanjindao_sprite:show()
	--elseif type == RoomConfig.MAHJONG_OPERTAION_HU then
		--self.node.hu_sprite:show()
	elseif type == RoomConfig.MAHJONG_HU_CODE_QIXIAODUI  then
		self.node.qidui_sprite:show()
	--elseif type == RoomConfig.MAHJONG_OPERTAION_JIN_KAN  then
    elseif type == 0x40  then  -- 因为部分手机无法读取到金坎配置 才把类型写死
		self.node.jinkan_sprite:show() 
    	print("金坎 动画 222222 =====  ")
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

return SMCardOptNode