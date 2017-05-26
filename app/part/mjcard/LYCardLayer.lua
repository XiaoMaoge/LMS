--[[
	云南的打牌界面处理
--]]

local CardLayer = import(".CardLayer")
local LYCardLayer = class("LYCardLayer",CardLayer)

--云南杠牌处理
function LYCardLayer:GangPicClick()
	-- body
    self.part:gangClick() --杠的测试
	self:setGangPicState(false)
end


--显示碰杠过操作
function LYCardLayer:showOpt(type,value)
	-- body
	self.card_touch_enable  = false
	if type == RoomConfig.MingGang then
		self.opt_show = true
		self.node.gang_btn:show()
		self.node.peng_btn:show()
		self.node.guo_btn:show()
	elseif type == RoomConfig.AnGang or type == RoomConfig.BuGang then
		self.opt_show = true
		self.node.gang_btn1:show()
		self.node.guo_btn:show()
	elseif type == RoomConfig.Peng then
		self.opt_show = true
		self.node.peng_btn:show()
		self.node.guo_btn:show()
	elseif type == RoomConfig.Hu then --胡的显示
	elseif type == RoomConfig.CHI then --吃的显示
		self.opt_show = true
		self.node.peng_btn:show()
		self.node.chi_btn:show()
	end

	for i,v in ipairs(self.card_list[RoomConfig.HandCard][RoomConfig.MySeat]) do
		for j,k in ipairs(value.mcard) do
			if v.card_value == k then
				local content_size = v.card_sprite:getContentSize()
				local pos = cc.pAdd(v.card_pos,cc.p(0,content_size.height*self.StandCardOffset))
				v.card_sprite:setPosition(pos)
			end
		end
	end

	print("this is show opt -------------------------:",self.opt_show)
end

--加入一个操作显示
function LYCardLayer:showAddOpt(optList)
	-- bod
	self.opt_list = optList
	self.node.opt_card_list:removeAllChildren()
  	self.node.opt_card_list:setItemModel(self.node.opt_card_panel)
  	self.node.opt_card_list:show()
  	self.card_touch_enable = true
  	for i,v in ipairs(optList) do
		self.node.opt_card_list:insertDefaultItem(i-1)
		local item = self.node.opt_card_list:getItem(i-1)
		local opt_btn = item:getChildByName("opt_btn")
		local pic_name = ""
		if v == RoomConfig.MAHJONG_OPERTAION_CANCEL then
			pic_name = "cancel_bt.png"
		elseif v == RoomConfig.MAHJONG_OPERTAION_CHI then
			pic_name = "chi.png"
		elseif v == RoomConfig.MAHJONG_OPERTAION_PENG then
			pic_name = "peng_bt.png"
		elseif v == RoomConfig.MAHJONG_OPERTAION_AN_GANG or v == RoomConfig.MAHJONG_OPERTAION_MING_GANG or v == RoomConfig.Gang then
			pic_name = "gang_bt.png"
		elseif v == RoomConfig.MAHJONG_OPERTAION_HU then
			pic_name = "hu.png"

		elseif v == RoomConfig.MAHJONG_QIANG_JIN then
			pic_name = "qiangjin_bt.png"
		elseif v == RoomConfig.MAHJONG_SAN_JIN_DAO then
			pic_name = "sanjindao_bt.png"
		elseif v == RoomConfig.MAHJONG_SI_JIN_DAO then
			pic_name = "sijindao_bt.png"
		elseif v == RoomConfig.MAHJONG_WU_JIN_DAO then
			pic_name = "wujindao_bt.png"
		elseif v == RoomConfig.MAHJONG_LIU_JIN_DAO then
			pic_name = "liujindao_bt.png"
		elseif v == RoomConfig.MAHJONG_DAN_YOU then
			pic_name = "youjin_bt.png"
		elseif v == RoomConfig.MAHJONG_SHUANG_YOU then
			pic_name = "shuangyou_bt.png"
		elseif v == RoomConfig.MAHJONG_SAN_YOU then
			pic_name = "sanyou_bt.png"
		elseif v == RoomConfig.MAHJONG_CHA_PAI then
			pic_name = "chapai_bt.png"
		elseif v == RoomConfig.MAHJONG_CHA_HUA then
			pic_name = "chahua_bt.png"

		end
		local texture_name = string.format("%s/room/resource/mj/%s",self.res_base,pic_name)
		opt_btn:loadTexture(texture_name,1)
	end
	self.node.opt_card_list:forceDoLayout()
	self.node.opt_card_list:jumpToPercentHorizontal(100)
end

function LYCardLayer:showHuAnimate(viewId,maList)
	-- body
	local card_node = self.node["hcard_node" .. viewId]
	local pos = cc.p(card_node:getPosition())
	self.node.hu_sprite:setPosition(pos)
	self.node.hu_sprite:show()

	self.node.animation:play("hu_animate",false)
	--播放胡的音效
	local sex = self.part:getPlayerInfo(viewId).sex
	local seat_id = self.part:getPlayerInfo(viewId).seat_id
	self:playOperateEffect(MahjongOperation.PLAYER_HU_CONFIRMED,sex,seat_id)
end

function LYCardLayer:setGangPicState(enable)
	-- 不显示右边的杠
	self.node.gang_pic_btn:hide()
end

function LYCardLayer:showChaPai(card)
	local frame_name = self.card_factory:getFrameName(RoomConfig.MySeat,card)
	self.node.cha_pai:loadTexture(frame_name,1)
	self.node.cha_pai:show()
end

function LYCardLayer:hideChaPai()
	print("LYCardLayer:hideChaPai")
	self.node.cha_pai:hide()
end

--显示/刷新 左上角的2张牌
function LYCardLayer:refreshBaoCardOnLayer(baoCard)
	-- body
	print("refreshBaoCard2",baoCard,self.node.bao1)
	if baoCard and self.node.bao1 then
		print("refreshBaoCard3")
		local bao1 = bit._and(baoCard,0xff);
		local bao2 = bit._and(bit.rshift(baoCard,8),0xff)
		print("refreshBaoCard4",bao1,bao2)

		local type,value = self.card_factory:decodeValue(bao1)

		local texture_name = string.format("%s/room/resource/mj/mine/M_%s_%d.png",self.res_base, RoomConfig.CardType[type],value)
		print("bao1Name->",texture_name)

		if value > 0 then
			self.node.bao1:loadTexture(texture_name,1)
			self.node.bao1:setColor({r=255,g=255,b=0})
			self.node.bao1:show()
			self.card_factory:setBaoPai1(bao1)
		else
			self.card_factory:setBaoPai1(nil)
		end		

		type,value = self.card_factory:decodeValue(bao2)
		texture_name = string.format("%s/room/resource/mj/mine/M_%s_%d.png",self.res_base, RoomConfig.CardType[type],value)
		print("bao2Name->",texture_name)

		if value > 0 then
			self.node.bao2:loadTexture(texture_name,1)
			self.node.bao2:setColor({r=255,g=255,b=0})
			self.node.bao2:show()
			self.card_factory:setBaoPai2(bao2)
		else
			self.card_factory:setBaoPai2(nil)
		end

		for i,v in ipairs(self.card_list[RoomConfig.HandCard][RoomConfig.MySeat]) do
			local bao1, bao2 = self.card_factory:getBaoPai()
			print("card_factory bao1 bao2 :", bao1, bao2)
			if v.card_value == bao1 or v.card_value == bao2 then
				v.card_sprite:setColor({r=255,g=255,b=0})
			end
		end
	end
end

function LYCardLayer:optListEvent(ref,event)
	-- body
	if event == 1 and self.opt_list then		
		local cur_select = self.node.opt_card_list:getCurSelectedIndex()
		print("CardLayer:optListEvent:", self.opt_list[cur_select + 1])
		self.card_touch_enable = false

		if self.opt_list[cur_select + 1] == RoomConfig.MAHJONG_DAN_YOU then
			self.card_touch_enable = true
		end

		self:hideOpt()		
		self.part:optClick(self.opt_list[cur_select + 1])
		self.opt_list = nil		
	end
end

function LYCardLayer:set_card_touch_enable(enable)
	-- body
	self.card_touch_enable = enable
end

--zhongqy 出牌音效
function LYCardLayer:playCardEffect(card_type , card_value , sex) --牌类型 ， 牌数值 ， 出牌人性别
	global:getAudioModule():playSound("res/sound/dapai.wav",false)

	if card_type ~= RoomConfig.Hua then
		local sound_type = tostring(card_type)
		local sound_value = tostring(card_value)

		local sex = tostring(sex)  --模拟性别 2：男 其他：女
		local mp3_name
		if sex == "2" then
			if sound_type == "0" then
				mp3_name = string.format("res/sound/man/%dwan.mp3", sound_value)
			elseif sound_type == "1" then
				mp3_name = string.format("res/sound/man/%dtiao.mp3", sound_value)
			elseif sound_type == "2" then
				mp3_name = string.format("res/sound/man/%dtong.mp3", sound_value)
			elseif sound_type == "3" then
				mp3_name = string.format("res/sound/man/zi%d.mp3", sound_value)
			end
		else
			if sound_type == "0" then
				mp3_name = string.format("res/sound/female/g_%dwan.mp3", sound_value)
			elseif sound_type == "1" then
				mp3_name = string.format("res/sound/female/g_%dtiao.mp3", sound_value)
			elseif sound_type == "2" then
				mp3_name = string.format("res/sound/female/g_%dtong.mp3", sound_value)
			elseif sound_type == "3" then
				mp3_name = string.format("res/sound/female/zi%d.mp3", sound_value)
			end
		end
		global:getAudioModule():playSound(mp3_name,false)
	end	
end

function LYCardLayer:playOperateEffect(operate_type , sex , seat) 	--操作类型（胡 碰 杠）出牌人性别 出牌人位置
   local sex = tostring(sex)
   local mp3_name = nil
   local sex_name = "man"
   
   if sex ~=  "2" then
   		sex_name = "female"
   end

	if operate_type == MahjongOperation.CHI then --吃
			mp3_name = "res/sound/".. sex_name .. "/chi.mp3"
    elseif operate_type == MahjongOperation.PENG then --碰
			mp3_name = "res/sound/".. sex_name .. "/peng0.mp3"
    elseif operate_type == MahjongOperation.MING_GANG or operate_type == MahjongOperation.AN_GANG or operate_type == MahjongOperation.BU_GANG then --杠
		    mp3_name = "res/sound/".. sex_name .. "/gang0.mp3"
    elseif operate_type == MahjongOperation.PLAYER_HU_CONFIRMED then --胡
			mp3_name = "res/sound/".. sex_name .. "/hu.mp3"
		--为什么加下面的语句， lxb 注释掉了
		--if seat == RoomConfig.MySeat and sex ~= "2" then
		--	mp3_name = "res/sound/female/hu1.mp3"
		--end
    elseif operate_type == MahjongOperation.PLAYER_HU_CONFIRMED then --自摸
			mp3_name = "res/sound/".. sex_name .. "/zimo0.mp3"
		if seat == RoomConfig.MySeat and sex ~= "2" then
			mp3_name = "res/sound/female/zimo111.mp3"
		end

	--elseif operate_type == MahjongOperation.QIANG_JIN then --抢金
	--		mp3_name = "res/sound/".. sex_name .. "/qiangjin.mp3"
	--elseif operate_type == MahjongOperation.SAN_JIN_DAO then --
	--		mp3_name = "res/sound/".. sex_name .. "/peng0.mp3"
	--elseif operate_type == MahjongOperation.SI_JIN_DAO then --
	--		mp3_name = "res/sound/".. sex_name .. "/peng0.mp3"
	--elseif operate_type == MahjongOperation.WU_JIN_DAO then --
	--		mp3_name = "res/sound/".. sex_name .. "/peng0.mp3"
	--elseif operate_type == MahjongOperation.LIU_JIN_DAO then --
	--		mp3_name = "res/sound/".. sex_name .. "/peng0.mp3"
	--elseif operate_type == MahjongOperation.DAN_YOU then --
	--		mp3_name = "res/sound/".. sex_name .. "/peng0.mp3"
	--elseif operate_type == MahjongOperation.SHUANG_YOU then --
	--		mp3_name = "res/sound/".. sex_name .. "/peng0.mp3"
	--elseif operate_type == MahjongOperation.SAN_YOU then --
	--		mp3_name = "res/sound/".. sex_name .. "/peng0.mp3"
	--elseif operate_type == MahjongOperation.CHA_PAI then --
	--		mp3_name = "res/sound/".. sex_name .. "/peng0.mp3"
	--elseif operate_type == MahjongOperation.CHA_HUA then --
	--		mp3_name = "res/sound/".. sex_name .. "/peng0.mp3"
	end

	if mp3_name == nil then
		return 
	end
   global:getAudioModule():playSound(mp3_name,false)
end

function LYCardLayer:standHandCardByValue(card_value)
	print("LYCardLayer:standHandCardByValue", card_value)
	local my_card_list = self.card_list[RoomConfig.HandCard][RoomConfig.MySeat]
	local card_num = #my_card_list
	for k, v in my_card_list do
		if v.card_value == card_value then				
			local content_size = v.card_sprite:getContentSize()
			local pos = cc.pAdd(v.card_sprite.pos,cc.p(0,content_size.height*self.StandCardOffset))
			v.card_sprite:setPosition(pos)
			v.card_sprite:setLocalZOrder(0)
		end
	end	
end

return LYCardLayer