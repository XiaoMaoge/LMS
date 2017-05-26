local CURRENT_MODULE_NAME = ...
local AssetsUpdatePart = import(".AssetsUpdatePart")
local FJAssetsUpdatePart = class("FJAssetsUpdatePart",AssetsUpdatePart) --登录模块
FJAssetsUpdatePart.DEFAULT_VIEW = "FJAssetsUpdateNode"

return FJAssetsUpdatePart 