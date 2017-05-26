local BroadcastNode = import(".BroadcastNode")
local FJBroadcastNode = class("FJBroadcastNode",BroadcastNode)
--[[
	界面处理需要保证就算是错误数据也做到不崩溃
	在获取到数据的时候进行checkData操作
]]

--广播文字移动
function FJBroadcastNode:broadcastUpdate(msg)
    local shap = self.node.pmdbg_img1
    local content_size = shap:getContentSize()
    if self.broad_cast == nil then
        self.broad_cast = ccui.Text:create()
        self.broad_cast:setFontSize(34)
        self.broad_cast:setAnchorPoint(cc.p(0,0.5))
        local cil_sprite = cc.Sprite:create(self.res_base .. "lobby/resource/pmdbg.png")
        if not cil_sprite then --todo 暂时处理合辑和其他目录名不同的问题，待优化
            cil_sprite = cc.Sprite:create(self.res_base .. "fjhjlobby/resource/pmdbg.png")
        end
        local cliper = cc.ClippingNode:create()
        local pos = cc.p(content_size.width/2 - 5,content_size.height/2)
        cliper:setStencil(cil_sprite)
        cliper:addChild(self.broad_cast)
        cliper:setPosition(pos)
        shap:addChild(cliper)
    end

    local start_pos = cc.p(content_size.width/2,0)
    self.broad_cast:setPosition(start_pos)
    self.broad_cast:setString(msg)

    local text_size = self.broad_cast:getStringLength()
    local end_time
    if text_size > 8 then
        end_time = 8+(text_size - 8)*0.3
    else
        end_time = 8
    end

    local text_width = self.broad_cast:getContentSize()
    local end_pos = {}
    end_pos.x = self.broad_cast:getPositionX() - content_size.width - text_width.width - 200
    end_pos.y = 0

    local actions = {
                        cc.MoveTo:create(end_time,end_pos),
                    }
    local seq = transition.sequence(actions)
    transition.execute(self.broad_cast , seq , { removeSelf= false, onComplete = function()
        self.part:setBroadcastState(false)
        self.part:checkBroadcast()
    end})
    self.part:setBroadcastState(true)
end

function FJBroadcastNode:isShowFJBroadcastNode(flag)
    -- body   
    if flag == true then 
        self.node.bc_panel:show()
    else
        self.node.bc_panel:hide()
    end
end

return FJBroadcastNode
