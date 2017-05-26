--[[-------------------------------------------------------------

Author:     Y.Zhang, york.zhang@sparkingfuture.com
Date:       2016-08-15 18:13:09
Version:    0.1
Company:    SparkingFuture LLC.

                Copyright (c) 2015, Y.Zhang

-------------------------------------------------------------]]--

--local RoomPart = import(".parts.RoomPart")

local GameUser = class("GameUser")

function GameUser:ctor()
    self.props = {
    }
    self.parts = {}

--    self:addPart(RoomPart.new(self))
end

--[
-- @brief 初始化
--]
function GameUser:initialize(loginAck)
    table.walk(self.parts, function(part)
        return part and part:initialize(loginAck)
    end)
end

--[
-- @brief 释放
--]
function GameUser:release()
    self:deactivate()
end

--[
-- @brief 激活
--]
function GameUser:activate()
    table.walk(self.parts, function(part)
        return part and part:activate()
    end)
end

--[
-- @brief 反激活
--]
function GameUser:deactivate()
    table.walk(self.parts, function(part)
        return part and part:deactivate()
    end)
end

--[
-- @brief  设置属性
-- @param  propId 属性ID
-- @param  value 属性值
-- @return void
--]
function GameUser:setProp(propId, value)
    -- if type(propId) ~= "number" then
    --     printError("PropertypCom:setProp - prop_id不是数字")
    --     return
    -- end

    local oldvalue = self:getProp(propId)
    local changed  = oldvalue ~= value

    self.props[propId] = value

    if changed then
        --todo:发送事件
    end
end

--[
-- @brief  取得属性
-- @param  propId 属性ID
-- @return number
--]
function GameUser:getProp(propId)
    return self.props[propId]
end

--[
-- @brief  获取所有属性
-- @param  void
-- @return table
--]
function GameUser:getProps()
    return self.props
end

--[
-- @brief  添加部件
-- @param  part
-- @return void
--]
function GameUser:addPart(part)
    local id = part:getPartId()
    if id == PartDef.INVALID then
        printError("GameUser:addPart - 无效的部件, %s", part.__cname)
        return
    end
    self.parts[id] = part
end

--[
-- @brief  移除部件
-- @param  partId 部件ID
-- @return void
--]
function GameUser:removePart(partId)
    local part = self.parts[partId]
    if part then
        part:release()
        self.parts[partId] = nil
    end
end

--[
-- @brief  获取部件
-- @param  partId 部件ID
-- @return 部件
--]
function GameUser:getPart(partId)
    return self.parts[partId]
end

--[
-- @brief  获取大厅子游戏列表
-- @return 游戏列表
--]
function GameUser:getGameList()
    return self.game_list
end

--[
-- @brief  设置大厅子游戏列表
-- @param  gamelist
-- @return 游戏列表
--]
function GameUser:setGameList(gameList)
    self.game_list = gameList
end

return GameUser
