local WifiAndNetNode = class("WifiAndNetNode",cc.load("mvc").ViewBase)
--[[
	界面处理需要保证就算是错误数据也做到不崩溃
	在获取到数据的时候进行checkData操作
]]
function WifiAndNetNode:onCreate() 
	-- body
	self:init("WifiAndNetNode")
	
end

function WifiAndNetNode:startUpdate()
	-- body
	self.part:checkUpdateInfo()
	self:schedulerFunc(function()
        -- body
		self.part:checkUpdateInfo()
    end,10,false)
end

function WifiAndNetNode:updateTime(time)
	-- body
	self.node.time_txt:setString(time)
end

function WifiAndNetNode:updateBattery(status)
	-- body
	local index = 1
	if status > 80 then
		index = 5
	elseif status >60 then
		index = 4
	elseif status > 40 then
		index = 3
	elseif status > 20 then
		index = 2
	else
		index = 1
	end
	local frame_name = string.format("%s/room/resource/wifiandnet/dianliang-%d.png",self.res_base,index)
	self.node.battery_img:loadTexture(frame_name,1)
end

function WifiAndNetNode:updateWifi(status,ping)
	-- body
	local index = 1
	if status > 80 then
    	index = 5
    elseif status > 60 then
    	index = 4
    elseif status > 40 then
    	index = 3
    elseif status > 20 then
    	index = 2
    else
    	index = 1
	end
	
	local net_level = 5;
	if ping <= 50 then
		net_level = 5
	elseif ping <= 100 then
		net_level = 4
	elseif ping <= 200 then
		net_level = 3
	elseif ping <= 500 then
		net_level = 2
	elseif ping <= 1000 then
		net_level = 1
	else
		net_level = 0
	end

	local frame_name = string.format(self.res_base .. "/room/resource/wifiandnet/wifi-%d.png",net_level)
	if status == 1 then
		if net_level > 3 then
			net_level = 3 
		end
		frame_name = string.format(self.res_base .. "/room/resource/wifiandnet/wifi-%d.png",net_level)
	elseif status == 2 then --4g
		frame_name = string.format(self.res_base .. "/room/resource/wifiandnet/xinhao-%d.png",net_level)
	else
		frame_name = self.res_base .. "/room/resource/wifiandnet/wifi-0.png"
	end

	self.node.wifi_img:loadTexture(frame_name,1)
end

return WifiAndNetNode