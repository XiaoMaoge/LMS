-- local BasePart = require("packages.mvc.BasePart")
local CURRENT_MODULE_NAME = ...
local PurchasePart = class("PurchasePart",cc.load('mvc').PartBase) --登录模块
local cjson = require "cjson"
PurchasePart.DEFAULT_PART = {}
PurchasePart.DEFAULT_VIEW = "PurchaseLayer"
PurchasePart.ALI_PAY = 1 --阿里支付
PurchasePart.WX_PAY = 0 --微信支付
PurchasePart.CONFIG_URL = "http://mjcz1.xingyuhudong.com/recharge/get-goods?gid="
PurchasePart.ALI_ORDER = "http://mjcz1.xingyuhudong.com/recharge/alipay-app?"
PurchasePart.WX_ORDER = "http://mjcz1.xingyuhudong.com/recharge/wx-app?"
-- PurchasePart.CONFIG_URL_GJ = "http://hjczgj.sparkingfuture.com/recharge/get-goods?gid="
-- PurchasePart.ALI_ORDER_GJ = "http://hjczgj.sparkingfuture.com/recharge/alipay-app?"
-- PurchasePart.WX_ORDER_GJ = "http://hjczgj.sparkingfuture.com/recharge/wx-app?"
-- PurchasePart.CONFIG_URL_BS = "http://hjczbs.xiaoxiongyouxi.com/recharge/get-goods?gid="
-- PurchasePart.ALI_ORDER_BS = "http://hjczbs.xiaoxiongyouxi.com/recharge/alipay-app?"
-- PurchasePart.WX_ORDER_BS = "http://hjczbs.xiaoxiongyouxi.com/recharge/wx-app?"
--[
-- @brief 构造函数
--]
function PurchasePart:ctor(owner)
	PurchasePart.super.ctor(self, owner)
	self:initialize()
end

--[
-- @override
--]
function PurchasePart:initialize()
	self.purchase_config = {}  --当前商品配置
end

--发送Http请求接收商品配置
function PurchasePart:requestPurchaseConfig()
-- body
	print("----------tmp chongzhi SocketConfig.GAME_ID :",type(SocketConfig.GAME_ID))

-- if tonumber(SocketConfig.GAME_ID) == 262401 then
-- 	self.CONFIG_URL = PurchasePart.CONFIG_URL_GJ..SocketConfig.GAME_ID
-- 	self.ALI_ORDER = PurchasePart.ALI_ORDER_GJ
-- 	self.WX_ORDER = PurchasePart.WX_ORDER_GJ
-- elseif tonumber(SocketConfig.GAME_ID) == 262402 then
-- 	self.CONFIG_URL = PurchasePart.CONFIG_URL_BS..SocketConfig.GAME_ID
-- 	self.ALI_ORDER = PurchasePart.ALI_ORDER_BS
-- 	self.WX_ORDER = PurchasePart.WX_ORDER_BS
-- end

	self.CONFIG_URL = PurchasePart.CONFIG_URL..SocketConfig.GAME_ID
	--self.CONFIG_URL = PurchasePart.CONFIG_URL.."sanming"
	self.ALI_ORDER = PurchasePart.ALI_ORDER
	self.WX_ORDER = PurchasePart.WX_ORDER

local http_mode = global:getModuleWithId(ModuleDef.HTTP_MOD)
--print(PurchasePart.CONFIG_URL)
--http_mode:send("req_purchase_config",PurchasePart.CONFIG_URL,"",0,function(resultCode,data)
print("self.CONFIG_URL : ",self.CONFIG_URL)
http_mode:send("req_purchase_config",self.CONFIG_URL,"",0,function(resultCode,data)
	-- body
	if resultCode == HTTP_STATE_SUCCESS then
		self.owner:endLoading()
	local table_data = cjson.decode(data)
		self.purchase_config = table_data.list
		self.view:initConfig(self.purchase_config) --刷新道具
	end
	end)
end

function PurchasePart:pcBtnClick(selectType ,selectIndex ,isSelect)
-- body
	if isSelect == false then
		local tips_part = global:createPart("TipsPart",self)
	if tips_part then
		tips_part:activate({info_txt=string_table.purchase_tip})
	end
	elseif isSelect == true then
		if selectType == 0 then
			self:requestOrder(PurchasePart.WX_PAY,selectIndex)
		elseif selectType == 1 then
			self:requestOrder(PurchasePart.ALI_PAY,selectIndex)
	end
	end
end

--下订单
function PurchasePart:requestOrder(payType,selectIndex)
-- body
local purchase_id = self.purchase_config[selectIndex].id
-- local order_url = PurchasePart.ALI_ORDER --默认是阿里的请求地址
-- if payType == PurchasePart.WX_PAY then
-- 	order_url = PurchasePart.WX_ORDER
-- end

local order_url = self.ALI_ORDER --默认是阿里的请求地址
if payType == PurchasePart.WX_PAY then
	order_url = self.WX_ORDER
end

	local user = global:getGameUser()
	local game_player = user:getProp("gameplayer"..SocketConfig.GAME_ID)
	--local game_id = game_player.gameId --暂时测试用
	local uid = game_player.playerIndex --暂时测试用
	-- order_url = order_url .. "&uid=" .. "1085" .. "&gid=" .. SocketConfig.GAME_ID .. "&rid=" ..purchase_id
	order_url = order_url .. "&uid=" .. uid .. "&gid=" .. SocketConfig.GAME_ID  .. "&rid=" ..purchase_id
	print("order_url : ",order_url)
	--order_url = order_url .. "&uid=" .. "267020" .. "&gid=" .. "qujing" .. "&rid=" .."1"
	local http_mode = global:getModuleWithId(ModuleDef.HTTP_MOD)
	http_mode:send("req_order",order_url,"",0,function(resultCode,data)
		-- body
		if resultCode == HTTP_STATE_SUCCESS then
		--下完订单就需要走支付流程
			print("-----------------现在走支付流程")
			local lua_bridge = global:getModuleWithId(ModuleDef.BRIDGE_MOD)
			lua_bridge:payCall(payType,data)
		end
	end)
end

--激活模块
function PurchasePart:activate(data)
	self.owner:startLoading()
	PurchasePart.super.activate(self,CURRENT_MODULE_NAME)
	self:requestPurchaseConfig()
	-- self.view:initConfig(self.purchase_config)
end

function PurchasePart:deactivate()
	if self.view then
		self.view:removeSelf()
		self.view = nil
	end
end

function PurchasePart:selectTimes(type)
-- body
	self.cur_good = type
	for i,v in ipairs(self.purchase_config) do
		if type == i then
			self.cur_num = v.num
			self.cur_price = v.price
		end
	end
	self.view:setSelectTimes(self.cur_good,self.cur_num ,self.cur_price)
end

function PurchasePart:getPartId()
-- body
	return "PurchasePart"
end

return PurchasePart
