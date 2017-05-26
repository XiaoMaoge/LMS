--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local CURRENT_MODULE_NAME = ...
local ReadyPart = import(".ReadyPart")
local SMReadyPart = class("SMReadyPart",ReadyPart) 
SMReadyPart.DEFAULT_PART = {
	"ChatPart",
	'BroadcastPart',--加入小喇叭节点
}
ReadyPart.DEFAULT_VIEW = "SMReadyLayer"


function SMReadyPart:ctor(...)
    SMReadyPart.super.ctor(self, ...)
end

function SMReadyPart:activate(data)
    SMReadyPart.super.activate(self, data)

    -- 根据打的第几圈判断是否显示“邀请好友”按钮（仅仅第一局显示该按钮）
    local iQuanNum = data.tableinfo.currenthand     -- 目前打的是第几圈
    if iQuanNum > 0 then
        self.view:hideInviteBtn()
    else
        self.view:showInviteBtn()
    end
end

function SMReadyPart:inviteFriends()
	print("tablewating_inviteFriends1")
	if RoomConfig.Ai_Debug then
		local player_info = self:getDebugPlayer()
		local ai_mod = global:getModuleWithId(ModuleDef.AI_MOD)
		ai_mod:addPlayer(player_info)
	else
		print("tablewating_inviteFriends2",string_table.game_name[tonumber(SocketConfig.GAME_ID)],SocketConfig.GAME_ID)
		local title = string_table.game_title_yi_chang
		local bridge = global:getModuleWithId(ModuleDef.BRIDGE_MOD)
		
		if self.m_totalhand == nil or self.m_totalhand == 0 then
			self.m_totalhand = 4
		end

        -- 游戏名称
        local strGameName = ""
        -- if string_table.game_name[tonumber(SocketConfig.GAME_ID)] then
        --     strGameName = string_table.game_name[tonumber(SocketConfig.GAME_ID)]
        -- end

        if bit._and(globlerule, bit.lshift(1, 24)) ~= 0 then
            strGameName = "三明13张"
        end

        if bit._and(globlerule, bit.lshift(1, 25)) ~= 0 then
            strGameName = "大田麻将"
        end

        -- local tempStr = "【房号】%d   六六福建麻将，GPS定位让作弊无所遁形《%s》 %d局 %d人场"-- string_table.vip_table_invite_share_word

        local strRule = ""

        if bit._and(globlerule, bit.lshift(1, 19)) ~= 0 then
            if string.len(strRule) > 0 then
                strRule = strRule .. "、AA支付"
            else
                strRule = strRule .. "AA支付"
            end
        else
            if string.len(strRule) > 0 then
                strRule = strRule .. "、房主支付"
            else
                strRule = strRule .. "房主支付"
            end
        end

        if bit._and(globlerule, bit.lshift(1, 0)) ~= 0 then
            if string.len(strRule) > 0 then
                strRule = strRule .. "、无平胡"
            else
                strRule = strRule .. "无平胡"
            end
        end

        if bit._and(globlerule, bit.lshift(1, 1)) ~= 0 then
            if string.len(strRule) > 0 then
                strRule = strRule .. "、点杠包三家"
            else
                strRule = strRule .. "点杠包三家"
            end
        end

        if bit._and(globlerule, bit.lshift(1, 2)) ~= 0 then
            if string.len(strRule) > 0 then
                strRule = strRule .. "、带白板"
            else
                strRule = strRule .. "带白板"
            end
        end 

        if bit._and(globlerule, bit.lshift(1, 3)) ~= 0 then
            if string.len(strRule) > 0 then
                strRule = strRule .. "、庄家翻倍"
            else
                strRule = strRule .. "庄家翻倍"
            end
        end 

        if bit._and(globlerule, bit.lshift(1, 4)) ~= 0 then
            if string.len(strRule) > 0 then
                strRule = strRule .. "、点炮胡牌"
            else
                strRule = strRule .. "点炮胡牌"
            end
        end

        if bit._and(globlerule, bit.lshift(1, 5)) ~= 0 then
            if string.len(strRule) > 0 then
                strRule = strRule .. "、红中补花"
            else
                strRule = strRule .. "红中补花"
            end
        end

        local tempStr = "<%s>房号:【%d】,%d局,%s,当前%d缺%d"    -- 游戏名、房号、局数、玩法、当前%d缺%d
        local shareContent = string.format(tempStr, strGameName, self.vip_table_id, self.m_totalhand, strRule, globlePlayersNum, globlePlayersNum - self.iCurrentPlayerNum)

		local shareUrl = string_table.share_weixin_android_url
		--分享内容和分享链接都是从服务器上拉取的
		
		local user = global:getGameUser()
	    local props = user:getProps()
	    local gameConfigList = props["gameplayer" .. SocketConfig.GAME_ID].gameConfigList

	    for i,v in ipairs(gameConfigList) do
	    	local gameParam = gameConfigList[i]
			if device.platform == "android" then
				if gameParam.paraId == ClientParamConfig.WEIXIN_SHARE_URL_ANDROID then
					if gameParam.valueStr then
						shareUrl = gameParam.valueStr --分享链接
					end
				end
			elseif device.platform == "ios" then
				if gameParam.paraId == ClientParamConfig.WEIXIN_SHARE_URL_IOS then
					if gameParam.valueStr then
						shareUrl = gameParam.valueStr --分享链接
					end
				end
			end
		end

		bridge:ShareToWX(1,shareContent,shareUrl)
	end
	-- self:addPlayer(player_info)
end


return SMReadyPart
--endregion
