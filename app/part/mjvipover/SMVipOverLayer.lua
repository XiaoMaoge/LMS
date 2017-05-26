local VipOverLayer = import(".VipOverLayer")
local SMVipOverLayer = class("SMVipOverLayer",VipOverLayer)

function SMVipOverLayer:setPlayerInfo(data , vipoverdata , index , tableid , winPos ,length)
    local playerInfo = vipoverdata
    local vip_over = self.node["vip_over" .. index]
    local head_bg = self.node["head_bg" .. index]
    local zongchengji = self.node["zongchengji" .. index]
    local over_win = self.node["over_win" .. index]
    local head_node = self.node["head_node" .. index]
    local name = self.node["name"..index]
    local host = self.node["host"..index];
    vip_over:show()
    head_bg:show()
    head_node:show()
    zongchengji:show()
    name:show()

    if vipoverdata.hostid == data.tablepos then
        host:show();
    end

    local id = self.node["id" .. index]--ID号
    local hu_txt = self.node['hu_txt' .. index]--胡的次数
    local danyou_txt = self.node['danyou_txt' .. index]--点炮
    local shuangyou_txt= self.node['shuangyou_txt'..index]--暗杠
    local sanyou_txt= self.node['sanyou_txt'..index]--点杠（明杠）
    local gang_txt= self.node['gang_txt'..index]--明杠（补杠）
    local num = self.node['num'..index]--分数

    --根据不同地区修改不同描述

    if globlerule ~= nil then
        if globlerule >= bit.lshift(1,24) and globlerule < bit.lshift(1,25) then--三明
            self.node['hu_txt000' .. index]:setString("胡牌次数:")     --胡牌次数
            self.node['danyou_txt000' .. index]:setString("点炮次数")  --点炮次数
            self.node['shuangyou_txt000'..index]:setString("暗杠次数") --暗杠次数
            self.node['sanyou_txt000'..index]:setString("点杠次数")    --点杠次数（明杠）
            self.node['gang_txt000'..index]:setString("明杠次数")      --明杠次数（补杠）

        elseif globlerule >= bit.lshift(1,25) and globlerule < bit.lshift(1,26) then--大田
            self.node['hu_txt000' .. index]:setString("胡牌次数:")      --胡的次数
            self.node['danyou_txt000' .. index]:setString("单游次数:")  --单游次数
            self.node['shuangyou_txt000'..index]:setString("双游次数:") --双游次数
            self.node['sanyou_txt000'..index]:setString("三游次数:")    --三游次数
            self.node['gang_txt000'..index]:setString("公杠次数:")      --公杠次数

       elseif globlerule >= bit.lshift(1,26) and globlerule < bit.lshift(1,27) then--三明16张
            self.node['hu_txt000' .. index]:setString("胡牌次数:")     --胡牌次数
            self.node['danyou_txt000' .. index]:setString("点炮次数")  --点炮次数
            self.node['shuangyou_txt000'..index]:setString("暗杠次数") --暗杠次数
            self.node['sanyou_txt000'..index]:setString("明杠次数")    --点杠次数（明杠）
            self.node['gang_txt000'..index]:setString("补杠次数")      --明杠次数（补杠）
        end
    end

    name:setString(data.name)
    id:setString(data.playerIndex)
    hu_txt:setString(playerInfo.dianpaoCount)
    danyou_txt:setString(playerInfo.danyou)
    shuangyou_txt:setString(playerInfo.shaungyou)
    sanyou_txt:setString(playerInfo.sanyou)
    gang_txt:setString(playerInfo.gang)
    num:setString(data.coin)

    local date_txt = os.date("%Y%m%d %H:%M")
    self.node.time:setString(date_txt)
    self.node.roomid:setString("房间号:"..tableid)

    -- 局数
    if globalTotalHand > 0 then
        self.node.around:show()
        self.node.around:setString("局数：" .. globalTotalHand .. "局")
    else
        self.node.around:hide()
    end

    -- 房间规则
    local strRule = ""

    if bit._and(globlerule, bit.lshift(1, 24)) ~= 0 then
        if string.len(strRule) > 0 then
            strRule = strRule .. "\n三明13张"
        else
            strRule = strRule .. "三明13张"
        end
    end

    if bit._and(globlerule, bit.lshift(1, 25)) ~= 0 then
        if string.len(strRule) > 0 then
            strRule = strRule .. "\n大田麻将"
        else
            strRule = strRule .. "大田麻将"
        end
    end

    if bit._and(globlerule, bit.lshift(1, 0)) ~= 0 then
        if string.len(strRule) > 0 then
            strRule = strRule .. "\n无平胡"
        else
            strRule = strRule .. "无平胡"
        end
    end

    if bit._and(globlerule, bit.lshift(1, 1)) ~= 0 then
        if string.len(strRule) > 0 then
            strRule = strRule .. "\n抢杠胡"
        else
            strRule = strRule .. "抢杠胡"
        end
    end

    if bit._and(globlerule, bit.lshift(1, 2)) ~= 0 then
        if string.len(strRule) > 0 then
            strRule = strRule .. "\n带白板"
        else
            strRule = strRule .. "带白板"
        end
    end 

    if bit._and(globlerule, bit.lshift(1, 3)) ~= 0 then
        if string.len(strRule) > 0 then
            strRule = strRule .. "\n庄家翻倍"
        else
            strRule = strRule .. "庄家翻倍"
        end
    end 

    if bit._and(globlerule, bit.lshift(1, 4)) ~= 0 then
        if string.len(strRule) > 0 then
            strRule = strRule .. "\n点炮胡牌"
        else
            strRule = strRule .. "点炮胡牌"
        end
    end

    if bit._and(globlerule, bit.lshift(1, 5)) ~= 0 then
        if string.len(strRule) > 0 then
            strRule = strRule .. "\n红中补花"
        else
            strRule = strRule .. "红中补花"
        end
    end
    self.node.hostpay:show()
    self.node.hostpay:setString(strRule)

--    if 1 == vipoverdata.payway then
--        self.node.aapay:show();
--        self.node.hostpay:hide();
--    else
--        self.node.aapay:hide();
--        self.node.hostpay:show();
--    end

    if data.headImgUrl and data.headImgUrl ~= "" then
        self.part:loadHeadImg(data.headImgUrl,head_node)
    end

    if winPos == data.tablepos then
        over_win:show()
    end
end

return SMVipOverLayer