-- local BasePart = require("packages.mvc.BasePart")
local CURRENT_MODULE_NAME = ...
local NoticePart = class("NoticePart",cc.load('mvc').PartBase) --登录模块
NoticePart.DEFAULT_VIEW = "NoticeLayer"

--[
-- @brief 构造函数
--]
function NoticePart:ctor(owner)
    NoticePart.super.ctor(self, owner)
    self:initialize()
end

--[
-- @override
--]
function NoticePart:initialize()
	
end

--激活模块
function NoticePart:activate(data)
	NoticePart.super.activate(self,CURRENT_MODULE_NAME)
	if data then
		self.view:setNoticeInfo(data.msg[1])
	else
		local net_mode = global:getModuleWithId(ModuleDef.NET_MOD)
		net_mode:registerMsgListener(SocketConfig.MSG_GET_GAME_CONFIG_RSP,handler(self,NoticePart.noticeAck))  -- 没有操作 
		self:noticeReq()
	end
end

function NoticePart:noticeReq()
	-- body
	local notice_req = hjlobby_message_pb.GetGameConfigReq()
	notice_req.type = 3
	local net_mode = global:getModuleWithId(ModuleDef.NET_MOD)
	net_mode:sendProtoMsg(notice_req,SocketConfig.MSG_GET_GAME_CONFIG_REQ,SocketConfig.GAME_ID)
end

function NoticePart:noticeAck(data,gameID)
	-- body
	local notice_ack = hjlobby_message_pb.GetGameConfigRsp()
	notice_ack:ParseFromString(data)
	printInfo("NoticePart:noticeAck %s",notice_ack)
	if notice_ack.resultCode == 0 and notice_ack.type == 3 then
		self.view:setNoticeInfo(notice_ack.msg[1])
	else
		self.owner:msgGameConfigRsp(data)
	end
end

function NoticePart:deactivate()
	-- local net_mode = global:getModuleWithId(ModuleDef.NET_MOD)
	-- net_mode:unRegisterMsgListener(SocketConfig.MSG_GET_GAME_CONFIG_RSP)
	if self.view then
		self.view:removeSelf()
	  	self.view =  nil
	end
end

function NoticePart:getPartId()
	-- body
	return "NoticePart"
end

-- 设置标题文本
function NoticePart:setTitleText(strText)
    self.view:setTitleText(strText)
end

return NoticePart 