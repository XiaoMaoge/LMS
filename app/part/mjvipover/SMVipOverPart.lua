-- local BasePart = require("packages.mvc.BasePart")
local CURRENT_MODULE_NAME = ...
local VipOverPart = import(".VipOverPart")
local SMVipOverPart = class("SMVipOverPart",VipOverPart) 
SMVipOverPart.DEFAULT_VIEW = "SMVipOverLayer"

function VipOverPart:vipOverDataDeal(data ,vipoverdata ,index , tableid , winPos , length)
    print("-----------------VipOverPart")
	
	local dianpao = vipoverdata.wincount
    local hithorsecount = vipoverdata.hithorsecount
    local gangCount = vipoverdata.gangcount;
    local dianpaoCount = vipoverdata.dianpaocount;
    local vipoverdata = {}

    if globlerule ~= nil then
        if globlerule >= bit.lshift(1,24) and globlerule < bit.lshift(1,25) then--三明
            vipoverdata.dianpaoCount = dianpao
            vipoverdata.danyou = dianpaoCount
            vipoverdata.shaungyou = bit._and(bit.rshift(hithorsecount,16),0xff)
            vipoverdata.gang = bit._and(bit.rshift(hithorsecount,0),0xff)
            vipoverdata.sanyou = bit._and(bit.rshift(hithorsecount,8),0xff)
            vipoverdata.hostid = bit._and(gangCount,0xff);
            vipoverdata.payway = bit._and(bit.rshift(gangCount, 8),0xff);
            
        elseif globlerule >= bit.lshift(1,25) and globlerule < bit.lshift(1,26) then--大田
            vipoverdata.dianpaoCount = dianpao
            vipoverdata.danyou = bit._and(bit.rshift(hithorsecount,8),0xff)
            vipoverdata.shaungyou = bit._and(bit.rshift(hithorsecount,16),0xff)
            vipoverdata.gang = bit._and(bit.rshift(hithorsecount,0),0xff)
            vipoverdata.sanyou = bit._and(bit.rshift(hithorsecount,24),0xff)
            vipoverdata.hostid = bit._and(gangCount,0xff);
            vipoverdata.payway = bit._and(bit.rshift(gangCount, 8),0xff);
        elseif globlerule >= bit.lshift(1,26) and globlerule < bit.lshift(1,27) then--三明
            vipoverdata.dianpaoCount = dianpao
            vipoverdata.danyou = dianpaoCount
            vipoverdata.shaungyou = bit._and(bit.rshift(hithorsecount,16),0xff)
            vipoverdata.gang = bit._and(bit.rshift(hithorsecount,0),0xff)
            vipoverdata.sanyou = bit._and(bit.rshift(hithorsecount,8),0xff)
            vipoverdata.hostid = bit._and(gangCount,0xff);
            vipoverdata.payway = bit._and(bit.rshift(gangCount, 8),0xff);
        end
    end
    
    self.view:setPlayerInfo(data , vipoverdata , index , tableid , winPos, length)
end

return SMVipOverPart