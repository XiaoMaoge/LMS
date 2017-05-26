local smmj_layer_config = { --UI配置
	AddRoomPart = "smmj/lobby/views/AddRoomLayer.lua",
	BroadcastPart = "smmj/lobby/views/BroadcastNode.lua",
	CardPart = "smmj/room/views/CardLayer.lua",
	CardOptPart = "smmj/room/views/CardOptNode.lua",
	ChatPart = "smmj/room/views/ChatLayer.lua",
	CreateRoomPart = "smmj/lobby/views/CreateRoomLayer.lua",
	GameEndPart = "smmj/room/views/GameEndLayer.lua",
	HelpPart = "smmj/lobby/views/HelpLayer.lua",
	LoadingPart = "smmj/common/views/LoadingLayer.lua",
	GameLobbyPart = "smmj/lobby/views/LobbyScene.lua",
	LobbyPart = "smmj/lobby/views/LobbyScene.lua",
	NoticePart = "smmj/lobby/views/NoticeLayer.lua",
	PurchasePart = "smmj/lobby/views/PurchaseLayer.lua",
	RecordPart = "smmj/lobby/views/RecordLayer.lua",
	SMSettingsPart = "smmj/lobby/views/SettingsLayer.lua",
	RoomSettingPart = "smmj/room/views/RoomSettingLayer.lua",
	SmallUserInfoPart  = "smmj/common/views/SmallUserInfoLayer.lua",
	TablePart = "smmj/room/views/TableScene.lua",
	TipsPart = "smmj/common/views/TipsLayer.lua",
	UpdatePart = "smmj/login/views/UpdateScene.lua",
	UserInfoPart = "smmj/lobby/views/UserInfoLayer.lua",
	VipOverPart = "smmj/room/views/VipOverLayer.lua",
	WifiAndNetPart = "smmj/room/views/WifiAndNetNode.lua",
	ReferrerPart = "smmj/lobby/views/ReferrerLayer.lua",
	ReadyPart = "smmj/room/views/ReadyLayer.lua",
	DissolvePart = "smmj/room/views/DissolveLayer.lua",
	WebViewPart = "fjhj/common/views/WebViewLayer.lua",
	GpsPart = "smmj/room/views/GpsLayer.lua",
	GpsTipPart = "smmj/room/views/GpsTipLayer.lua",
	RoomRulePart = "smmj/room/views/RoomMessage.lua",
    EffectPart = "smmj/room/views/EffectLayer.lua",
    CheckHuaPart = "smmj/room/views/CheckHuaLayer.lua",
}

local part_base = "app.part."

local smmj_part_config = { --组件配置
	AddRoomPart =part_base ..  "addroom.AddRoomPart",
	BroadcastPart = part_base .. "broadcast.BroadcastPart",
	CardPart = part_base .."mjcard.SMCardPart",
	CardOptPart = part_base .."mjcardopt.SMCardOptPart",
	ChatPart = part_base .."chat.ChatPart",
	CreateRoomPart = part_base .."createroom.SMCreateRoomPart",
	GameEndPart =part_base .. "mjgameend.SMGameEndPart",
	HelpPart = part_base .."help.SMHelpPart",
	LoadingPart =part_base .. "loading.LoadingPart",
	LobbyPart = part_base .."mjlobby.SMLobbyPart",
	NoticePart = part_base .."notice.NoticePart",
	PurchasePart = part_base .."purchase.PurchasePart",
	RecordPart = part_base .."record.RecordPart",
	SMSettingsPart = part_base .."settings.SMSettingsPart",
	RoomSettingPart = part_base .. "roomsetting.RoomSettingPart",
	SmallUserInfoPart  = part_base .."smalluserinfo.SmallUserInfoPart",
	TablePart =part_base .. "mjtable.SMTablePart",
	TipsPart = part_base .."tips.TipsPart",
	UpdatePart = part_base .."update.UpdatePart",
	UserInfoPart = part_base .."userinfo.UserInfoPart",
	VipOverPart =part_base .. "mjvipover.SMVipOverPart",
	WifiAndNetPart = part_base .."wifiandnet.WifiAndNetPart",
	ReferrerPart =part_base .. "referrer.ReferrerPart",
	ReadyPart = part_base .."ready.SMReadyPart",
	DissolvePart = part_base .."dissolve.DissolvePart",
	WebViewPart = part_base .. "webview.WebViewPart",
	GpsPart = part_base .. "gps.GpsPart",
	GpsTipPart = part_base .. "gpstip.GpsTipPart",
	RoomRulePart = part_base .. "roomrule.RoomRulePart",
    EffectPart = part_base .. "mjEffectLayer.EffectPart",
    CheckHuaPart = part_base .. "checkhua.CheckHuaPart",
}


if PartConfig then
	for i,v in pairs(smmj_layer_config) do
		PartConfig.view[i] = v 	
	end

	for i,v in pairs(smmj_part_config) do
		PartConfig.part[i] = v
	end
else
	cc.exports.PartConfig = {}
	PartConfig.view = smmj_layer_config
end

cc.exports.SingleGame = false --是否是单品游戏