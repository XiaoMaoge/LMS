local fjmj_layer_config = { --UI配置
	AdPart = "fjmj/lobby/views/AdPicNode.lua",
	AddRoomPart = "fjmj/lobby/views/AddRoomLayer.lua",
	BroadcastPart = "fjmj/lobby/views/BroadcastNode.lua",
	CardPart = "fjmj/room/views/CardLayer.lua",
	CardOptPart = "fjmj/room/views/CardOptNode.lua",
	ChatPart = "fjmj/room/views/ChatLayer.lua",
	CreateRoomPart = "fjmj/lobby/views/CreateRoomLayer.lua",
	GameEndPart = "fjmj/room/views/GameEndLayer.lua",
	HelpPart = "fjmj/lobby/views/HelpLayer.lua",
	LoadingPart = "fjmj/common/views/LoadingLayer.lua",
	GameLobbyPart = "fjmj/lobby/views/LobbyScene.lua",
	LobbyPart = "fjmj/lobby/views/LobbyScene.lua",
	NoticePart = "fjmj/lobby/views/NoticeLayer.lua",
	PurchasePart = "fjmj/lobby/views/PurchaseLayer.lua",
	RecordPart = "fjmj/lobby/views/RecordLayer.lua",
	-- SettingsPart = "fjmj/lobby/views/SettingsLayer.lua",
	RoomSettingPart = "fjmj/room/views/RoomSettingLayer.lua",
	SmallUserInfoPart  = "fjmj/common/views/SmallUserInfoLayer.lua",
	TablePart = "fjmj/room/views/TableScene.lua",
	TipsPart = "fjmj/common/views/TipsLayer.lua",
	UpdatePart = "fjmj/login/views/UpdateScene.lua",
	UserInfoPart = "fjmj/lobby/views/UserInfoLayer.lua",
	VipOverPart = "fjmj/room/views/VipOverLayer.lua",
	WifiAndNetPart = "fjmj/room/views/WifiAndNetNode.lua",
	ReferrerPart = "fjmj/lobby/views/ReferrerLayer.lua",
	ReadyPart = "fjmj/room/views/ReadyLayer.lua",
	DissolvePart = "fjmj/room/views/DissolveLayer.lua",
}

local part_base = "app.part."

local fjmj_part_config = { --组件配置
	AdPart = part_base .. "ad.AdPart",
	AddRoomPart =part_base ..  "addroom.AddRoomPart",
	BroadcastPart = part_base .. "broadcast.BroadcastPart",
	CardPart = part_base .."mjcard.LYCardPart",
	CardOptPart = part_base .."mjcardopt.LYCardOptPart",
	ChatPart = part_base .."chat.ChatPart",
	CreateRoomPart = part_base .."createroom.LYCreateRoomPart",
	GameEndPart =part_base .. "mjgameend.LYGameEndPart",
	HelpPart = part_base .."help.LYHelpPart",
	LoadingPart =part_base .. "loading.LoadingPart",
	LobbyPart = part_base .."mjlobby.LYLobbyPart",
	NoticePart = part_base .."notice.NoticePart",
	PurchasePart = part_base .."purchase.PurchasePart",
	RecordPart = part_base .."record.RecordPart",
	-- SettingsPart = part_base .."settings.SettingsPart",
	RoomSettingPart = part_base .. "roomsetting.RoomSettingPart",
	SmallUserInfoPart  = part_base .."smalluserinfo.SmallUserInfoPart",
	TablePart =part_base .. "mjtable.LYTablePart",
	TipsPart = part_base .."tips.TipsPart",
	UpdatePart = part_base .."update.UpdatePart",
	UserInfoPart = part_base .."userinfo.UserInfoPart",
	VipOverPart =part_base .. "mjvipover.LYVipOverPart",
	WifiAndNetPart = part_base .."wifiandnet.WifiAndNetPart",
	ReferrerPart =part_base .. "referrer.ReferrerPart",
	ReadyPart = part_base .."ready.ReadyPart",
	DissolvePart = part_base .."dissolve.DissolvePart",
}


if PartConfig then
	for i,v in pairs(fjmj_layer_config) do
		PartConfig.view[i] = v 	
	end

	for i,v in pairs(fjmj_part_config) do
		PartConfig.part[i] = v
	end
else
	cc.exports.PartConfig = {}
	PartConfig.view = fjmj_layer_config
end

cc.exports.SingleGame = false --是否是单品游戏