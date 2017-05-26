-- local BasePart = require("packages.mvc.BasePart")
local CURRENT_MODULE_NAME = ...
local HelpPart = import(".HelpPart")
local LYHelpPart = class("LYHelpPart",HelpPart) 
LYHelpPart.DEFAULT_VIEW = "LYHelpLayer"

return LYHelpPart 
