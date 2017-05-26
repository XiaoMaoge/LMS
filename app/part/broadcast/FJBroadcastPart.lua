local CURRENT_MODULE_NAME = ...
local BroadcastPart = import(".BroadcastPart")
local FJBroadcastPart = class("FJBroadcastPart",BroadcastPart) --登录模块
FJBroadcastPart.DEFAULT_VIEW = "FJBroadcastNode"

return FJBroadcastPart 