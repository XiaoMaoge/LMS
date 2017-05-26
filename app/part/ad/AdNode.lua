local AdNode = class("AdNode",cc.load("mvc").ViewBase)
--[[
	界面处理需要保证就算是错误数据也做到不崩溃
	在获取到数据的时候进行checkData操作
]]
function AdNode:onCreate()
	-- body
	self:init("AdNode")
end

function AdNode:initAdPageView(data)
	self.node.Left_flag:setOpacity(50)
	self.node.Right_flag:setOpacity(255)

	local PAGE_GAME_NUM = math.ceil(#data)
	PAGE_GAME_NUM = 2
	self.page_game_num = PAGE_GAME_NUM
	for i=1,PAGE_GAME_NUM do 
		self.node.Ad_PageView:addPage(self.node.Ad_Image:clone())
	end
	self.node.Ad_PageView:setCurrentPageIndex(1)
	self.node.Ad_PageView:addEventListener(handler(self,AdNode.pageViewEvent))
end

function AdNode:pageViewEvent(tag,event)
	-- body
	local cur_page = self.node.Ad_PageView:getCurrentPageIndex()
	print('this is  page view event:',tag,event,cur_page)
	if cur_page == 0 then --到了第一页将最后一页放到第一页前面
		print("first page")
		--[[local page = self.node.Ad_PageView:getItem(self.page_game_num - 1)
		self.node.Ad_PageView:insertPage(page:clone(),0)
		self.node.Ad_PageView:setCurrentPageIndex(1)
		self.node.Ad_PageView:removePageAtIndex(self.page_game_num)]]
		self.node.Left_flag:setOpacity(255)
		self.node.Right_flag:setOpacity(50)
	end
	--[[elseif cur_page == self.page_game_num then --到了最后一页，将第一页放到最后一页后面
		print("last page")
		local page = self.node.Ad_PageView:getItem(0)
		self.node.Ad_PageView:addPage(page:clone())
		self.node.Ad_PageView:removePageAtIndex(0)
		self.node.Ad_PageView:scrollToPage(self.page_game_num - 2)
	end]]

	if cur_page == self.page_game_num - 1 then
		self.node.Left_flag:setOpacity(50)
		self.node.Right_flag:setOpacity(255)
	end
end

function AdNode:getAdImgNode(idx)
	local page_panel = self.node.Ad_PageView:getItem(idx - 1)
	local sprite = cc.Sprite:create(self.res_base .. "/Fjhjlobby/resource/AdPic.png")
	if sprite == nil then
		sprite = cc.Sprite:create(self.res_base .. "/lobby/resource/AdPic.png")
	end
	local size = page_panel:getContentSize()
	sprite:setPosition(cc.p(size.width * 0.5, size.height * 0.5))
	page_panel:addChild(sprite)
	return sprite
end

return AdNode