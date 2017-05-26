local VipOverLayer = class("VipOverLayer",cc.load("mvc").ViewBase)
--[[
	界面处理需要保证就算是错误数据也做到不崩溃
	在获取到数据的时候进行checkData操作
]]
function VipOverLayer:onCreate()
	-- body
	self:init("VipOverLayer")
end

function VipOverLayer:setPlayerInfo(data , vipoverdata , index , tableid , winPos ,length)
    local playerInfo = vipoverdata
    print("------------index:",index)
    local vip_over = self.node["vip_over" .. index]
    local head_bg = self.node["head_bg" .. index]
    local zongchengji = self.node["zongchengji" .. index]
    local over_win = self.node["over_win" .. index]
    local head_node = self.node["head_node" .. index]
    local name = self.node["name"..index]
    vip_over:show()
    head_bg:show()
    head_node:show()
    zongchengji:show()
    name:show()

    local id = self.node["id" .. index]
    local hu_txt = self.node['hu_txt' .. index]
    local gonggang_txt = self.node['gonggang_txt' .. index]
    local angang_txt= self.node['angang_txt'..index]
    local zhongma_txt= self.node['zhongma_txt'..index]
    local num = self.node['num'..index]

    name:setString(data.name)
    id:setString(data.playerIndex)
    hu_txt:setString(playerInfo.dianpaoCount)
    gonggang_txt:setString(playerInfo.ming_gang)
    angang_txt:setString(playerInfo.an_gang)
    zhongma_txt:setString(playerInfo.hit_horse)
    num:setString(data.coin)

    local date_txt = os.date("%Y%m%d %H:%M")
    self.node.time:setString(date_txt)
    self.node.roomid:setString(string.format(string_table.room_id_txt,tableid))

    if data.headImgUrl and data.headImgUrl ~= "" then
        self.part:loadHeadImg(data.headImgUrl,head_node)
    end

    if length == 4 then
        if winPos == data.tablepos then
            over_win:show()
        end
    end
end

function VipOverLayer:BackClick()
    self.part:returnGame()
end

function VipOverLayer:ShowClick()
    local bridge = global:getModuleWithId(ModuleDef.BRIDGE_MOD)
    bridge:saveGamePic()

    local shareContent = string_table.wx_one_friend
    local shareUrl = string_table.share_weixin_android_url
    --分享内容和分享链接都是从服务器上拉取的

    local user = global:getGameUser()
    local props = user:getProps()
    local gameConfigList = props["gameplayer" .. SocketConfig.GAME_ID].gameConfigList

    for i,v in ipairs(gameConfigList) do
        local gameParam = gameConfigList[i]
        if gameParam.paraId == ClientParamConfig.WEIXIN_SHARE_CONTENT then
            if gameParam.valueStr then
                shareContent = gameParam.valueStr --分享内容
            end
        end

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

    local time = nil
    time = self:schedulerFunc(function()
        if time ~= nil then
            self:unScheduler(time)
        end
        bridge:ShareToWX(2,shareContent,shareUrl) --分享图片
    end,0.5,false)
    --self:BackClick()
end

return VipOverLayer
