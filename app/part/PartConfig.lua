cc.exports.PartConfig = {}
PartConfig.view = { --配置组件UI路径
	FjhjLobbyPart = "fjhj/fjhjlobby/views/FjhjLobbyScene.lua",
	UpdateGamePart = "fjhj/fjhjlobby/views/UpdateGameLayer.lua",
	LobbyPart = "fjhj/lobby/views/FjhjLobbyScene.lua",
	LoadingPart = "fjhj/common/views/LoadingLayer.lua",
	UpdatePart = "fjhj/login/views/UpdateScene.lua",
	LoginPart = "fjhj/login/views/LoginScene.lua",
	AssetsUpdatePart = "fjhj/fjhjlobby/views/AssetsUpdateNode.lua",
	GameManagePart = "fjhj/fjhjlobby/views/GameManageLayer.lua",
	BroadcastPart = "fjhj/fjhjlobby/views/BroadcastNode.lua",
	SettingsPart = "fjhj/fjhjlobby/views/SettingsLayer.lua",
	TipsPart = "fjhj/common/views/TipsLayer.lua",
	AdPart = "fjhj/fjhjlobby/views/AdPicNode.lua",
	NoticePart = "fjhj/fjhjlobby/views/NoticeLayer.lua",
}


local app_base = "app.part."
PartConfig.part = { --配置组件路径
	FjhjLobbyPart = app_base .. "fjhjlobby.FjhjLobbyPart",
	UpdateGamePart = app_base .. "updategame.UpdateGamePart",
	LobbyPart = app_base .. "fjhjlobby.FjhjLobbyPart",
	LoadingPart =app_base .. "loading.LoadingPart",
	UpdatePart = app_base .. "update.UpdatePart",
	LoginPart = app_base .. "fjhjlogin.LoginPart",
	AssetsUpdatePart = app_base .. "assetsupdate.AssetsUpdatePart",
	GameManagePart = app_base .. "gamemanage.GameManagePart",
	BroadcastPart = app_base .. "broadcast.BroadcastPart",
	SettingsPart = app_base .. "settings.SettingsPart",
	TipsPart = app_base .. "tips.TipsPart",
	AdPart = app_base .. "ad.AdPart",
	NoticePart = app_base .."notice.NoticePart",
}
