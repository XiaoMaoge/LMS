local TableScene = import(".TableScene")
local LYTableScene = class("LYTableScene",TableScene)

function LYTableScene:chaPlayer(offlinePos, show)
	print("LYTableScene:chaPlayer offlinePos show : ", offlinePos, show)
	local cha_icon = self.node['cha_icon' .. offlinePos]
	print("LYTableScene:chaPlayer cha_icon", cha_icon)
	if show then
		cha_icon:show()
	else
		cha_icon:hide()
	end
	
end

return LYTableScene