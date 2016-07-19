----------------------------------------------------------------------------------
--[[
    FILE:           ChainView.lua
    DESCRIPTION:    连线页面
    AUTHOR:         ZhaoLu
    CREATED:        2016-06-08
--]]
----------------------------------------------------------------------------------

local ChainView = class("ChainView", function()
    return display.newNode()
end)

function ChainView:ctor()
	-- body
   self.chainLayer = cc.LayerColor:create(cc.c4b(0, 0, 255,0))
   self.chainLayer:setContentSize(game.GRID_WIDTH,game.GRID_HEIGHT)
   self.chainLayer:setPosition(self.chainLayer:getContentSize().width * - 0.5 ,0)
   self.chainLayer:addTo(self)

   self.chainData = {}

end

function ChainView:pushChain(p1,p2,opacityNum)
	-- body

		-- local angle = cc.pGetAngle(gridToPoint(p1.x, p1.y), gridToPoint(p2.x, p2.y));
		-- print(angle / 3.14 * 180 )
	if p1~=nil and p2~=nil then
		local p = cc.pSub(p1,p2)
		--dump(p)

		if p.x == 1 and p.y == 0 then
			--todo 上

			-- local sp = display.newSprite("chain_2.png")
			local sp = display.newSprite("#mayixian1.png")
			if opacityNum~=nil then
				sp:setOpacity(opacityNum)
			end
			sp:setRotation(-90)
			local point = gridToPoint(p2.x, p2.y)
			sp:setPosition(point.x,point.y + game.CELL_HEIGHT * 0.5)
			sp:addTo(self.chainLayer)
			sp:playAnimationForever(display.getAnimationCache("mayixian"))
			table.insert(self.chainData,sp)
		elseif p.x == -1 and p.y == 0  then
			--todo 下
			local sp = display.newSprite("#mayixian1.png")
			if opacityNum~=nil then
				sp:setOpacity(opacityNum)
			end
			sp:setRotation(90)
			local point = gridToPoint(p2.x, p2.y)
			sp:setPosition(point.x,point.y - game.CELL_HEIGHT * 0.5)
			sp:addTo(self.chainLayer)
			sp:playAnimationForever(display.getAnimationCache("mayixian"))
			table.insert(self.chainData,sp)
		elseif p.x == 0 and p.y == -1  then
			--todo 左
			local sp = display.newSprite("#mayixian1.png")
			if opacityNum~=nil then
				sp:setOpacity(opacityNum)
			end
			sp:setRotation(180)
			local point = gridToPoint(p2.x, p2.y)
			sp:setPosition(point.x - game.CELL_WIDTH * 0.5 ,point.y)
			sp:addTo(self.chainLayer)
			sp:playAnimationForever(display.getAnimationCache("mayixian"))
			table.insert(self.chainData,sp)
		elseif p.x == 0 and p.y == 1  then
			--todo 右
			local sp = display.newSprite("#mayixian1.png")
			if opacityNum~=nil then
				sp:setOpacity(opacityNum)
			end
			local point = gridToPoint(p2.x, p2.y)
			sp:setPosition(point.x + game.CELL_WIDTH * 0.5 ,point.y)
			sp:addTo(self.chainLayer)
			sp:playAnimationForever(display.getAnimationCache("mayixian"))
			table.insert(self.chainData,sp)
		elseif p.x == 1 and p.y == -1  then
			--todo 左上
			local sp = display.newSprite("#mayixian1.png")
			if opacityNum~=nil then
				sp:setOpacity(opacityNum)
			end
			sp:setRotation(-135)
			local point = gridToPoint(p2.x, p2.y)
			sp:setPosition(point.x - game.CELL_HEIGHT * 0.5,point.y + game.CELL_HEIGHT * 0.5)
			sp:addTo(self.chainLayer)
			sp:playAnimationForever(display.getAnimationCache("mayixian"))
			table.insert(self.chainData,sp)
		elseif p.x == -1 and p.y == -1  then
			--todo 左下
			local sp = display.newSprite("#mayixian1.png")
			if opacityNum~=nil then
				sp:setOpacity(opacityNum)
			end
			sp:setRotation(135)
			local point = gridToPoint(p2.x, p2.y)
			sp:setPosition(point.x - game.CELL_HEIGHT * 0.5,point.y - game.CELL_HEIGHT * 0.5)
			sp:addTo(self.chainLayer)
			sp:playAnimationForever(display.getAnimationCache("mayixian"))
			table.insert(self.chainData,sp)
		elseif p.x == 1 and p.y == 1  then
			--todo 右上
			local sp = display.newSprite("#mayixian1.png")
			if opacityNum~=nil then
				sp:setOpacity(opacityNum)
			end
			sp:setRotation(-45)
			local point = gridToPoint(p2.x, p2.y)
			sp:setPosition(point.x + game.CELL_HEIGHT * 0.5,point.y + game.CELL_HEIGHT * 0.5)
			sp:addTo(self.chainLayer)
			sp:playAnimationForever(display.getAnimationCache("mayixian"))
			table.insert(self.chainData,sp)
		elseif p.x == -1 and p.y == 1  then
			--todo 右下
			local sp = display.newSprite("#mayixian1.png")
			if opacityNum~=nil then
				sp:setOpacity(opacityNum)
			end
			sp:setRotation(45)
			local point = gridToPoint(p2.x, p2.y)
			sp:setPosition(point.x + game.CELL_HEIGHT * 0.5,point.y - game.CELL_HEIGHT * 0.5)
			sp:addTo(self.chainLayer)
			sp:playAnimationForever(display.getAnimationCache("mayixian"))
			table.insert(self.chainData,sp)
		end
	end
end

function ChainView:popChain()
	-- body
	local num = table.nums(self.chainData)
	local chain = table.remove(self.chainData)
	chain:removeFromParent()
end

function ChainView:removeAllChain()
	-- body
	self.chainData = {}
	self.chainLayer:removeAllChildren()

end

return ChainView

