local DissolveLayer = class("DissolveLayer",cc.load("mvc").ViewBase)
--[[
	界面处理需要保证就算是错误数据也做到不崩溃
	在获取到数据的时候进行checkData操作
]]

function DissolveLayer:ctor(...)
    DissolveLayer.super.ctor(self, ...)

    self.bShowFirst = true

    self.node.dissolveBg:hide()
end

function DissolveLayer:setShowFirstState(bState)
    self.bShowFirst = bState
end

-- 是否根据延时动作隐藏解散房间的窗口
function DissolveLayer:hideDissolveBgNodeWithDelayTimeAction(bRunAction)
    if true == bRunAction then
        local tableActions = { }
        tableActions[1] = cc.DelayTime:create(1.0)
        tableActions[2] = cc.CallFunc:create(handler(self, function()
            self.node.dissolveBg:hide()
        end ))
        self:runAction(cc.Sequence:create(tableActions))
    else
        self.node.dissolveBg:hide()
    end
end

function DissolveLayer:onCreate(data) --传入数据
	-- body
	self:init("DissolveLayer")
	self.tips_show = false
end


function DissolveLayer:CloseClick()
	self:LayerInit()
end

function DissolveLayer:SetData(data,playerList,m_seat_id)
	-- body
	local player_request = self.part:changeSeatToView(data.mRequestCloseTablePlayerTablePos) -- 要求解散房间的位置
    local player_request_txt = self.part:getPlayerInfo(player_request)
    local m_seat_id = self.part:changeSeatToView(m_seat_id)
    -- 玩家XX申请解散房间
    if string_table and player_request_txt and string_table then
        self.node.playertxt:setString(string_table.player..player_request_txt.name..string_table.player_dissolve)
    end

    self.msg_txt = {}
    -- 玩家XX等待
    for i,v in ipairs(playerList) do
    	if v.view_id ~= player_request then
    		local player_table = {}
    		player_table.playerIndex = v.playerIndex
			player_table.id = v.view_id
			player_table.name = v.name
			player_table.click = false
			player_table.txt = string_table.player..player_table.name..string_table.player_wait -- 玩家XX等待
			table.insert(self.msg_txt, player_table)
		end
	end

    -- 玩家XX同意
	if data.mAgreeTablePos ~= nil then
		for i,v in ipairs(data.mAgreeTablePos) do
			local playerId = self.part:changeSeatToView(v)
			print("playerId Agree : ",playerId)
			for k,j in ipairs(self.msg_txt) do
				if j.id == playerId then
					j.click =true
					j.txt = string_table.player..j.name..string_table.player_agree  -- 玩家XX同意
				end
			end
		end
	end

    -- 玩家XX拒绝
	if data.mRefuseTablePos ~= nil then
		for i,v in ipairs(data.mRefuseTablePos) do
			local playerId = self.part:changeSeatToView(v)
			print("playerId Refuse : ",playerId)
			for k,j in ipairs(self.msg_txt) do
				if j.id == playerId then
					j.click =true
					j.txt = string_table.player..j.name..string_table.player_disagree   -- 玩家XX拒绝
				end
			end
		end
	end

	local arr = {}
	for i,v in ipairs(self.msg_txt) do
    	if v.view_id ~= player_request then
    		arr[i] = v.click
		end
	end

    local bIsExistClick = false
    for k, v in pairs(arr) do
        if true == v then
            bIsExistClick = true
            break
        end
    end
    
    if false == bIsExistClick then
        self.tips_show = false
    end
    
    for i, v in ipairs(self.msg_txt) do
        if i >= 1 and i <= 4 then
            local player_list = self.node["player" .. i]
            if player_list then
                player_list:setString(v.txt)
                print("-----------------", v.click, m_seat_id, v.id, self.tips_show)
                if v.click == false and m_seat_id == v.id and self.tips_show == false then
                    self.tips_show = true
                    if player_request_txt and player_request_txt then
                        -- 弹出同意解散房间与拒绝解散房间的提示窗口
                        self.part:showCloseVipRoomTips(player_request_txt.name, player_request_txt.playerIndex)
                    end

                end

                --
                if v.click == true and m_seat_id == v.id then
                    self:LayerInit(true)
                end

                -- 如果是发起解散房间的人
                if m_seat_id == player_request and true == v.click then
                    self:LayerInit(true)
                end
            end
        else
            print("Dissolve data playerList overflow")
        end
    end

	self:startCountTime(data.mLeftTime)
end

function DissolveLayer:startCountTime(wait_time)
	-- body
	print("DissolveLayer wait_time : ",wait_time)
	local cur_time = 1
	if self.time_entry ~= -1 then
		self:unScheduler(self.time_entry)
		self.time_entry = -1
	end
	self.time_entry = self:schedulerFunc(function()
		-- body
		if cur_time > wait_time then
			self:unScheduler(self.time_entry)
			self.time_entry = -1
			return
		end
		local time = wait_time - cur_time
		self.node.timeout:setString(time..string_table.end_tape_second)
		cur_time = cur_time + 1
	end,1,false)
end

function DissolveLayer:LayerInit(isshow)
--    if true == self.bShowFirst and true == isshow then
--        self.bShowFirst = false
--    end

	if isshow == true then
		self.node.dissolveBg:show()
	else
        self.node.dissolveBg:hide()
	end
end

function DissolveLayer:backEvent()
	-- body
end

return DissolveLayer
