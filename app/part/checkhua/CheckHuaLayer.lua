local CheckHuaLayer = class("CheckHuaLayer",cc.load("mvc").ViewBase)
--[[
	界面处理需要保证就算是错误数据也做到不崩溃
	在获取到数据的时候进行checkData操作
]]
function CheckHuaLayer:onCreate()
	-- body
	-- self:addMask()
	self:init("CheckHuaLayer")
	--self.node.im_board:setScrollBarEnabled(false)
    if self.node.Panel_swallowTouches then
        self.node.Panel_swallowTouches:setSwallowTouches(true)
    end
end


function CheckHuaLayer:ResetClick()    
	self.part:resetNum()
end

function CheckHuaLayer:DelClick()    
	self.part:delNum()
end

function CheckHuaLayer:CloseClick()
	-- body
	self.part:deactivate()
end



function CheckHuaLayer:CreateGameClick()
	-- body
	self.part:createGameClick()
end

function CheckHuaLayer:getList(date,pos)
    local list = {}
    local area = 1
	for k,v in pairs(date.beforeCards) do 
        if  v == 100 then
            area = area + 1        
        else 
            if area == pos then
                table.insert(list,v)     
            end
        end
    end
    return list
end


function CheckHuaLayer:initUI(date,listName)
    self.card_sprite = require("app.part.mjcard.CardFactory").new(self)
	self.card_sprite:init(self.res_base)
    local mark_Num = date.opValue;
    
    
    
    for i = 1,mark_Num do
       local list1 = {};
       local list = {};
       local numList = 0;
       list1= self:getList(date,i) 
       for k,v in pairs(list1) do
            if "number" == type(v) and v ~= nil then
                numList = numList + 1 
                table.insert(list,v)      
            end 
       end
       table.sort(list)
       --numList = table.getn(list)
        local item = self.node["player"..i]
		local name = item:getChildByName("name"..i)
        local number_hua = item:getChildByName("number_hua"..i)
        local hua_card_list = item:getChildByName("hua_card_list"..i)
        local number_cards = 0;
        number_hua:setString("花x"..numList)
        name:setString(listName[i].."")
        local mark_hua = 1;
        for m=1,#list do
            if list[m] ==list[m + 1] then 
                     number_cards = number_cards + 1;
            else 
                mark_hua = mark_hua + 1
                number_cards = number_cards + 1;
                if "number" == type(list[m]) then
                    local frame_name = self.card_sprite:getFrameName(RoomConfig.MySeat,list[m])
                    local card_pic = self.node["card_pic"]:clone()
                    local num_card = card_pic:getChildByName("number_card")
                    local cardSize = card_pic:getContentSize()
                    card_pic:loadTexture(frame_name,1)
                    num_card:setString(tostring( math.abs(number_cards)))
                    if number_cards > 1 then 
                        num_card:show()
                    
                    else
                        num_card:hide()
                    end
                    card_pic:setPosition(cc.p((cardSize.width-cardSize.width*0.5) * mark_hua - 20,20))
                    hua_card_list:addChild(card_pic)
                    number_cards = 0;
                end
                
            end
        end
    end

    if mark_Num < 4 then
        for i = mark_Num+1,4 do
            local item = self.node["player"..i]
	        local name = item:getChildByName("name"..i)
            name:hide()
            local number_hua = item:getChildByName("number_hua"..i)
            number_hua:hide()
            local hua_card_list = item:getChildByName("hua_card_list"..i)
            hua_card_list:hide()
        end
    end

        


  --[[  for i = 1,length do

		local item = self.node["player"..i]
		local name = item:getChildByName("name"..i)
        local number_hua = item:getChildByName("number_hua"..i)
        local hua_card_list = item:getChildByName("hua_card_list"..i)

        name = data.players.name 
        number_hua = data.players.name 
        -- data.players.list 是列表 local card = self.card_factory:createWithData(viewId,v) #self.card_list
        --card = self.card_sprite:createEndCard(card_value[m]);
        local list = #data.players.card_list
        local number_cards = 0
        for i = 1,list[i]  do 
            
            if list[i] ==list[i + 1] then 
                 number_cards = number_cards + 1;
            else 
                number_cards = number_cards + 1;
                local frame_name = self.card_sprite:getFrameName(RoomConfig.MySeat,list[i])
                local hua_card = self.node["hua_card"];
                local card_pic = hua_card:getChildByName("card_pic")
                local num_card = hua_card:getChildByName("number_card")
                local cardSize = hua_card:getContentSize()
                card_pic:loadTexture(frame_name,1)
                num_card:setString(tostring( math.abs(number_cards)))
                if number_cards > 1 then 
                    num_card:show()
                    
                else
                    num_card:hide()
                end
                hua_card:setPosition(cc.p(cardSize.width * (i-0.5),0))
                hua_card_list:addChild(hua_card)
                number_cards = 0;
            end


        end
 


      

	end]]

end



return CheckHuaLayer