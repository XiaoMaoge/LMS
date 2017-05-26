local fjhj_layer_config = { --UI配置
	UpdateGamePart = "fjhj/fjhjlobby/views/UpdateGameLayer.lua",
	AssetsUpdatePart = "fjhj/fjhjlobby/views/AssetsUpdateNode.lua",
	GameManagePart = "fjhj/fjhjlobby/views/GameManageLayer.lua",
	BroadcastPart = "fjhj/fjhjlobby/views/BroadcastNode.lua",
	SettingsPart = "fjhj/fjhjlobby/views/SettingsLayer.lua",
	TipsPart = "fjhj/common/views/TipsLayer.lua",
	AdPart = "fjhj/fjhjlobby/views/AdPicNode.lua",
	-- webview test
	WebViewPart = "fjhj/common/views/WebViewLayer.lua",
	--
}

local app_base = "app.part."

local fjhj_part_config = { --组件配置
	UpdateGamePart = app_base .. "updategame.UpdateGamePart",
	AssetsUpdatePart = app_base .. "assetsupdate.FJAssetsUpdatePart",
	GameManagePart = app_base .. "gamemanage.GameManagePart",
	BroadcastPart = app_base .. "broadcast.FJBroadcastPart",
	SettingsPart = app_base .. "settings.SettingsPart",
	TipsPart = app_base .. "tips.TipsPart",
	AdPart = app_base .. "ad.FJAdPart",
	-- webview test
	WebViewPart = app_base .. "webview.WebViewPart",
	-- 
}


if PartConfig then
	for i,v in pairs(fjhj_layer_config) do
		PartConfig.view[i] = v 	
	end

	for i,v in pairs(fjhj_part_config) do
		PartConfig.part[i] = v
	end
else
	cc.exports.PartConfig = {}
	PartConfig.view = fjhj_layer_config
end

cc.exports.SingleGame = true --是否是单品游戏