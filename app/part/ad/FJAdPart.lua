-- local BasePart = require("packages.mvc.BasePart")
local CURRENT_MODULE_NAME = ...
local AdPart = import(".AdPart")
local FJAdPart = class("FJAdPart",AdPart) --登录模块
FJAdPart.DEFAULT_VIEW = "FJAdNode"

return FJAdPart 