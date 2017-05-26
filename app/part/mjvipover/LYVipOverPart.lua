-- local BasePart = require("packages.mvc.BasePart")
local CURRENT_MODULE_NAME = ...
local VipOverPart = import(".VipOverPart")
local LYVipOverPart = class("LYVipOverPart",VipOverPart) 
LYVipOverPart.DEFAULT_VIEW = "LYVipOverLayer"

function LYVipOverPart:vipOverDataDeal(data ,vipoverdata ,index , tableid , winPos , length)

    print("LYVipOverPart : ",vipoverdata)

    self.view:setPlayerInfo(data , vipoverdata , index , tableid , winPos ,length)

end

return LYVipOverPart