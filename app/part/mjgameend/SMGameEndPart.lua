-- local BasePart = require("packages.mvc.BasePart")
local CURRENT_MODULE_NAME = ...
local GameEndPart = import(".GameEndPart")
local SMGameEndPart = class("SMGameEndPart",GameEndPart) --大厅模块
GameEndPart.DEFAULT_VIEW = "SMGameEndLayer"

--[
-- @brief 构造函数
--]
function SMGameEndPart:ctor(owner)
    SMGameEndPart.super.ctor(self, owner)
    -- self:initialize()
end

--激活模块
function SMGameEndPart:activate(data , tablepos)
	SMGameEndPart.super.activate(self, data , tablepos)
end

return SMGameEndPart

