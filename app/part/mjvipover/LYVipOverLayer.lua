local VipOverLayer = import(".VipOverLayer")
local LYVipOverLayer = class("LYVipOverLayer",VipOverLayer)

function LYVipOverLayer:setPlayerInfo(data , vipoverdata , index , tableid , winPos ,length)
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
    local kaigang_txt= self.node['kaigang_txt'..index]
    local num = self.node['num'..index]

    name:setString(data.name)
    id:setString(data.playerIndex)
    hu_txt:setString(playerInfo.wincount)
    gonggang_txt:setString(playerInfo.zhuangcount)
    angang_txt:setString(playerInfo.dianpaocount)
    zhongma_txt:setString(playerInfo.hithorsecount)
    kaigang_txt:setString(playerInfo.gangcount)
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

return LYVipOverLayer