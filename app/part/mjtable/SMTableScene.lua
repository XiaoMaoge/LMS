local TableScene = import(".TableScene")
local SMTableScene = class("SMTableScene",TableScene)


function SMTableScene:ctor(...)
    SMTableScene.super.ctor(self, ...)

    -- "庄"图片的隐藏
    for i = 1, 4 do
        self.node["bank_icon" .. i]:hide()
    end
    
end

-- 初始化
function SMTableScene:initTableWithData(playerList,data)
	-- body
    self.part.nameList = {}
	for i,v in ipairs(playerList) do
		if i > 4 then
			return
		else
			self:showPlayer(v)
            table.insert(self.part.nameList, i, v.name)
			print("this is show banker:",v.tablepos,data.dealerpos)
			if v.tablepos == data.dealerpos then
				self.node["bank_icon" .. v.view_id]:show()
            else
                self.node["bank_icon" .. v.view_id]:hide()
			end
		end
	end

	self:setDiPanRotation(data.mtablePos);
	-- self:updateLastCardNum(data.last_card_num)
    self:showRoomRule()
   
end


-- 设置地盘旋转
function SMTableScene:setDiPanRotation(seat)
	local angle = ((seat + 3) % 4 ) * 90;

	self.node.dipan:setRotation(angle);
end

--轮到某个位置
--seat 逻辑座位 1 -4
function SMTableScene:turnSeat(seat,time)
	-- body
	for i=1,RoomConfig.TableSeatNum do
		self.node["bearing"..i-1]:stopAllActions()
		self.node["bearing" .. i-1]:hide()
	end
	local viewSeat = self.part:changeViewToSeat(seat);
	print("bearing" .. seat-1, viewSeat);
	local cur_bearing = self.node["bearing" .. viewSeat-1]
	cur_bearing:show()
	local seq = cc.Sequence:create(cc.FadeOut:create(1),cc.FadeIn:create(1))
	local action = cc.Repeat:create(seq,RoomConfig.WaitTime/2)
	cur_bearing:runAction(action)
	self:startCountTime(time)
end

-- function SMTableScene:showHelpInfoBtn()
-- 	print("showHelpInfoBtn..........................");
-- 	self.node.gang_pic_btn:show();
-- end

-- 房间规则信息
function SMTableScene:HelpPicClick()
	print("HelpPicClick..........................");
	self.part:showHelpInfo();
end

-- 显示该房间的规则（点杠包三家、无平胡、带白板）
function SMTableScene:showRoomRule()
    local strRule = ""

    if bit._and(globlerule, bit.lshift(1, 24)) ~= 0 then
        if string.len(strRule) > 0 then
            strRule = strRule .. "  三明13张"
        else
            strRule = strRule .. "三明13张"
        end
    end

    if bit._and(globlerule, bit.lshift(1, 25)) ~= 0 then
        if string.len(strRule) > 0 then
            strRule = strRule .. "  大田麻将"
        else
            strRule = strRule .. "大田麻将"
        end
    end

    if bit._and(globlerule, bit.lshift(1, 26)) ~= 0 then
        if string.len(strRule) > 0 then
            strRule = strRule .. "  三明16张"
        else
            strRule = strRule .. "三明16张"
        end
    end

    if bit._and(globlerule, bit.lshift(1, 0)) ~= 0 then
        if string.len(strRule) > 0 then
            strRule = strRule .. "  无平胡"
        else
            strRule = strRule .. "无平胡"
        end
    end

    if bit._and(globlerule, bit.lshift(1, 1)) ~= 0 then
        if string.len(strRule) > 0 then
            strRule = strRule .. "  抢杠胡"
        else
            strRule = strRule .. "抢杠胡"
        end
    end

    if bit._and(globlerule, bit.lshift(1, 2)) ~= 0 then
        if string.len(strRule) > 0 then
            strRule = strRule .. "  带白板"
        else
            strRule = strRule .. "带白板"
        end
    end 

    if bit._and(globlerule, bit.lshift(1, 3)) ~= 0 then
        if string.len(strRule) > 0 then
            strRule = strRule .. "  庄家翻倍"
        else
            strRule = strRule .. "庄家翻倍"
        end
    end 

    if bit._and(globlerule, bit.lshift(1, 4)) ~= 0 then
        if string.len(strRule) > 0 then
            strRule = strRule .. "  点炮胡牌"
        else
            strRule = strRule .. "点炮胡牌"
        end
    end

    if bit._and(globlerule, bit.lshift(1, 5)) ~= 0 then
        if string.len(strRule) > 0 then
            strRule = strRule .. "  红中补花"
        else
            strRule = strRule .. "红中补花"
        end
    end

    if bit._and(globlerule, bit.lshift(1, 6)) ~= 0 then
        if string.len(strRule) > 0 then
            strRule = strRule .. "  无平胡"
        else
            strRule = strRule .. "无平胡"
        end
    end


    self.node.text_message:setString(strRule)

    -- 显示房间ID
    local iRoomID = self.part:getRoomID()
    if iRoomID > 0 then
        self.node.text_message_roomid:show()
        self.node.text_message_roomid_text:show()
        self.node.text_message_roomid:setString(iRoomID)
    else
        self.node.text_message_roomid_text:hide()
        self.node.text_message_roomid:hide()
    end
end

return SMTableScene