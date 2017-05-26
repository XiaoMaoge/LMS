local CURRENT_MODULE_NAME = ...
local GameEndPart = import(".GameEndPart")
local LYGameEndPart = class("LYGameEndPart",GameEndPart)
LYGameEndPart.DEFAULT_VIEW = "LYGameEndLayer"

return LYGameEndPart 