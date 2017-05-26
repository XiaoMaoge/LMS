local RecordLayer = class("RecordLayer",cc.load("mvc").ViewBase)
--[[
	界面处理需要保证就算是错误数据也做到不崩溃
	在获取到数据的时候进行checkData操作
]]
function RecordLayer:onCreate(data) --传入数据
	-- body
	self:addMask()
	self:init("RecordLayer")
	self.node.record_panel_list:setItemModel(self.node.record_panel)
end


function RecordLayer:CloseClick()
    global:getAudioModule():playSound("res/sound/Button32.mp3",false)
	self.part:deactivate()
end

function RecordLayer:setData(data,name)
	-- body
	local str = ""
	local strtmp = ""
	local name = name
	if self.node.nomassage then
		self.node.nomassage:hide()
	end
	if #(data.record) ~= 0 then
		for k,v in ipairs(data.record) do
		--for i=1,10 do
			self.node.record_panel_list:insertDefaultItem(k-1)
			local item = self.node.record_panel_list:getItem(k-1)

			local number = item:getChildByName("number")
			local roomid = item:getChildByName("roomid")
			local time = item:getChildByName("time")
			local scoreInfo = item:getChildByName("scoreInfo")

			number:setString(k)
			roomid:setString(string.format(string_table.room_id_txt,v.roomIndex))
			time:setString(string_table.game_time..v.startTime)

			if v.player then
				for i,j in ipairs(v.player) do
					if i == 1 then
						str = name..":"..j.score
					else
						strtmp = ", "..j.playerID ..":".. j.score
						str = str..strtmp 
					end
				end
			end	

			scoreInfo:setString(str)
		end
	else
		self.node.nomassage:show()
		return
	end
end

return RecordLayer
