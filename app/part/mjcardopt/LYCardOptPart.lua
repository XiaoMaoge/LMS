local CURRENT_MODULE_NAME = ...
local CardOptPart = import(".CardOptPart")
local LYCardOptPart = class("LYCardOptPart",CardOptPart)

LYCardOptPart.DEFAULT_VIEW = "LYCardOptNode"

function LYCardOptPart:deactivate()
	self.view =  nil
end

return LYCardOptPart