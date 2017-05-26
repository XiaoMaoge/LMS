local CURRENT_MODULE_NAME = ...
local CardOptPart = import(".CardOptPart")
local SMCardOptPart = class("SMCardOptPart",CardOptPart)

SMCardOptPart.DEFAULT_VIEW = "SMCardOptNode"

return SMCardOptPart