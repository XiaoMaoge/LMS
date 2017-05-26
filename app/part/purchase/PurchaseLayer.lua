local PurchaseLayer = class("PurchaseLayer",cc.load("mvc").ViewBase)
--[[
	界面处理需要保证就算是错误数据也做到不崩溃
	在获取到数据的时候进行checkData操作
]]
function PurchaseLayer:onCreate()
	-- body
	self:addMask()
	self:init("PurchaseLayer")
	self.isSelect = false
	for i=1,10 do
		PurchaseLayer["paySelectEvent" .. i] = function(self)
			self.part:selectTimes(i)
		end
	end

end

--根据商品配置初始化商品列表
function PurchaseLayer:initConfig(config)
	-- body
	for i,v in ipairs(config) do
		self.node["good_check" .. i]:show()
		local good_name = self.node["good_name" .. i]
		good_name:setString(string_table.mall_text_rmb..v.price)
	end
end

function PurchaseLayer:CloseClick() 
	self.part:deactivate()   
end

function PurchaseLayer:setSelectTimes(type,cur_num ,cur_price)
	-- body
	for i=1,10 do --关闭当前选择
		if i ~= type then
			self.node["good_check" .. i]:setSelected(false)
			self.node["good_check" .. i]:setTouchEnabled(true)
			self.isSelect = true
		else 
			self.node["good_check" .. i]:setTouchEnabled(false)
			self.isSelect = false
		end
	end

	local cur_money = self.node.cur_money_txt
	cur_money:setString(string.format(string_table.pay_text_price_yuan,cur_price))
	local diamond_num = self.node.diamond_txt
	diamond_num:setString(cur_num)

	self.selectIndex = type
end

function PurchaseLayer:WxBtnClick()
	self.part:pcBtnClick(0 , self.selectIndex , self.isSelect )
end

function PurchaseLayer:AliBtnClick()
	self.part:pcBtnClick(1 , self.selectIndex , self.isSelect )
end


return PurchaseLayer