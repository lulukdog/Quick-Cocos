----------------------------------------------------------------------------------
--[[
    FILE:           Cell.lua
    DESCRIPTION:    基本滑动单元
    AUTHOR:         ZhaoLu
    CREATED:        2016-06-01 
--]]
----------------------------------------------------------------------------------
local cellCfg = require("data.data_eliminate")
local GameConfig = require("data.GameConfig")
local common = require("app.common")

local Cell = class("Cell", function()
    return display.newNode()
end)

function Cell:ctor(id)
   --self.elements = {}
   self.id = id
   self.life = cellCfg[self.id].life
   self.isLinked = false -- 是否是连接状态的cell

   -- self.sprite = display.newSprite(string.format("cell_%d.png", type))
   self.sprite = display.newSprite(cellCfg[self.id].icon)
   local size = self.sprite:getContentSize()

   -- print(string.format("sprite size is width=%d,height=%d",size.width,size.height))

   self.sprite:setAnchorPoint(0.5,0)
   self.sprite:setPosition(0,size.height * -0.5)

   self:addChild(self.sprite)

   -- 物块遮罩
   self.shadeSprite = display.newGraySprite(cellCfg[self.id].icon,{0,0,0,0}):addTo(self)
   self.shadeSprite:setOpacity(150)
   self.shadeSprite:setVisible(false)

   self:setContentSize(size)

   self.boxRect = {centerX=0,centerY=0,r=0}

end

function Cell:moveToGrid(row,col,delay)
	-- bodyR 
	self:runAction(cc.Sequence:create(
		cc.DelayTime:create(delay),
		cc.MoveTo:create(0.15,gridToPoint(row, col))
	))
end

function Cell:setGridPosition(row,col)
	self:setPosition(gridToPoint(row,col))
end

function Cell:getGridPosition()
	local x,y = self:getPosition()
	local col = math.ceil(x / game.CELL_WIDTH)
	local row = math.ceil(y / game.CELL_HEIGHT)
	return row,col
end


function Cell:selected()
	self.sprite:setTexture(cellCfg[self.id].iconSelected)
	self.sprite:runAction(cc.Sequence:create(
		cc.ScaleTo:create(0.04,0.7),
		cc.ScaleTo:create(0.04,1)
	))
end
function Cell:setLinkTag()
	self.isLinked = true
end

function Cell:unselected()
	-- self.sprite:setColor(cc.c3b(255, 255, 255))
	self.sprite:setTexture(cellCfg[self.id].icon)
	--self.sprite:runAction(cc.TintTo:create(0.01, 255, 255, 255))
end

function Cell:rock()
	self:runAction(cc.Sequence:create(
		cc.MoveBy:create(0.03,cc.p(15,0)),
		cc.MoveBy:create(0.03,cc.p(-30,0)),
		cc.MoveBy:create(0.03,cc.p(30,0)),
		cc.MoveBy:create(0.03,cc.p(-15,0))
	))
end

function Cell:getBoxRect()
	local point = self.sprite:convertToWorldSpace(cc.p(0,0))
	local adjustSize = fitScreenSize(self.sprite:getContentSize())
	self.boxRect.r = adjustSize.width*0.45
	self.boxRect.centerX = point.x+adjustSize.width*0.5
	self.boxRect.centerY = point.y+adjustSize.height*0.5
	-- print("x "..self.boxRect.x.." y "..self.boxRect.y.." width "..self.boxRect.width.." height "..self.boxRect.height)
	return self.boxRect
end

function Cell:dropShakeAni(toPosition)
	local ap = self:getAnchorPoint()
	local x,y = self:getPosition()
	-- print(string.format("cell anchorpoint x=%d,y=%d,position is x=%d,y=%d",ap.x,ap.y,x,y))

	self:runAction(cc.Sequence:create(
			cc.DelayTime:create(0.3),
			cc.MoveTo:create(0.2,toPosition),
			-- cc.DelayTime:create(0.05),
			cc.CallFunc:create(function()
				self:setVisible(true)
			end)
		))
		
	self.sprite:runAction(
		cc.Sequence:create(
			cc.DelayTime:create(0.4),
		   	cc.ScaleTo:create(0.1,1,0.6),
		   	cc.ScaleTo:create(0.1,1,1)
		)
	)
end

function Cell:canDrop()
	if cellCfg[self.id].canDrop==1 then
		-- print("Cell:canDrop()"..self.id)
		return true
	end
	return false
end

function Cell:canClick()
	if cellCfg[self.id].canClick==1 then
		-- print("Cell:canClick()"..self.id)
		return true
	end
	return false
end

function Cell:hasMoreLife()
	if cellCfg[self.id].life>0 then
		-- print("Cell:canEliminate()"..self.id)
		return true
	end
	return false
end

function Cell:isBomb()
	if self.id==game.BOMBID then
		return true
	end
	return false
end

-- 触碰炸弹要标记下，否则会出现手不松开移到炸弹上松开执行炸弹方法导致错误
function Cell:setBombTouching(isTouch)
	self.bombTouchBegan = isTouch or true
end
function Cell:getBombTouching()
	return self.bombTouchBegan or false
end

-- cell消失动画播放后删除掉
function Cell:playDisappearAni( )
	-- 计算cell积分
	game.getScores = game.getScores + cellCfg[self.id].score
	-- print("move to x "..(display.cx-200).." y "..(display.top-400))
	-- 动画效果添加到cell下面，并在cell初始位置不变
	local cellParent = self:getParent()
	local x,y = self:getPosition()
	local sprite = display.newSprite("#disappear01.png")
	sprite:setPosition(cc.p(x,y))
	sprite:addTo(cellParent)
	sprite:setLocalZOrder(-1)
	sprite:setScale(1.3)
	sprite:runAction(cc.Sequence:create(
		cc.DelayTime:create(0.1+GameConfig.FlyDelayTime),
		cc.CallFunc:create(function()
			sprite:playAnimationOnce(display.getAnimationCache("disappear"),true)
		end)
		
	))


	self.sprite:setTexture(cellCfg[self.id].iconSelected)
	self:setLocalZOrder(10)
	self:runAction(cc.Sequence:create(
		
		cc.DelayTime:create(0.57+GameConfig.FlyDelayTime),
		cc.CallFunc:create(function()
			self:removeAllChildren()
			self:removeFromParent()
		end)
	))
	
	transition.execute(self, cc.MoveTo:create(0.3, GameConfig.MainRole.pos), {delay = 0.3+GameConfig.FlyDelayTime})
	transition.execute(self, cc.ScaleTo:create(0.3, 0.5), {delay = 0.3+GameConfig.FlyDelayTime})
	GameConfig.FlyDelayTime = GameConfig.FlyDelayTime+GameConfig.FlyDelayInterval
end

-- 有生命的cell被影响的时候换成另一个cell
function Cell:minusLife()
	if self.id==10 or self.id==11 or self.id==12 then
		local sprite = display.newSprite("#stone_1.png"):addTo(self:getParent())
		sprite:setPosition(self:getPositionX(),self:getPositionY())
		sprite:setLocalZOrder(1)
		sprite:playAnimationOnce(display.getAnimationCache("stone"),true)
	end
	if cellCfg[self.id].nextId==0 then
		self.id = 0 
		return
	end
	if self.life>0 then
		if cellCfg[self.id].hasIceAni==1 then
			local sprite = display.newSprite("#ice_1.png"):addTo(self)
			sprite:setScale(0.9)
			sprite:playAnimationOnce(display.getAnimationCache("ice"),true)
		end
		self.id = cellCfg[self.id].nextId
	end
end
-- 刷新被影响的物块图片
function Cell:refreshPic()
	if self.isLinked==false and self.id~=0 then
		self.sprite:setTexture(cellCfg[self.id].icon)
		local shadeTexture = display.newGraySprite(cellCfg[self.id].icon,{0,0,0,0}):getTexture()
		self.shadeSprite:setTexture(shadeTexture)
	end
end

-- 可刷新的cell
function Cell:isInRefreshTb()
	if common:table_has_value({1,2,3,4,5,6,8}, self.id) then
		return true
	end
	return false 
end

-- 控制cell显示遮罩
function Cell:setShadeVisible( visible )
	self.shadeSprite:setVisible(visible)
end

-- 获取cell当前分数
function Cell:getScore( )
	return cellCfg[self.id].score
end

-- 给当前cell加上扫光效果
function Cell:clipFlight()
	local _saoguangTb = {"maozi","dao","juzi","dangong", "dun", "xin"}
	local _picName = "#".._saoguangTb[self.id].."1.png"
    local sprite = display.newSprite(_picName):addTo(self)
    sprite:playAnimationOnce(display.getAnimationCache(_saoguangTb[self.id]),true)

end

-- 给炸弹加上炸弹效果
function Cell:bombFlight()
	local _picName = "#bomb_1.png"
    local sprite = display.newSprite(_picName):addTo(self)
    sprite:setAnchorPoint(0.5,0)
   	sprite:setPosition(0,self.sprite:getContentSize().height * -0.5)
    sprite:playAnimationForever(display.getAnimationCache("bomb"))

end

return Cell
