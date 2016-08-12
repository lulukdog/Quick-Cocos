----------------------------------------------------------------------------------
--[[
    FILE:           GridManager.lua
    DESCRIPTION:    cell数据控制器
    AUTHOR:         ZhaoLu
    CREATED:        2016-06-01 
--]]
----------------------------------------------------------------------------------

local GridManager = class("GridManager")
local data_CellInitCfg = require("data.CellInitCfg")
local GameConfig = require("data.GameConfig")
local stageCfg = require("data.data_stage")
local FightManager = require("app.game.FightManager")
local common = require("app.common")

function GridManager:ctor()
   self.data_ = {} -- 全部的cell信息
   self._moveTb = {} -- 将要移动的cell
   self._affectTb = {} -- 受消除或爆炸影响的cell要减生命值
   
   for i=1,game.GRID_COLS * game.GRID_ROWS do
      self.data_[i] = game.CELL_TYPE_UNKNOWN
   end

  -- self:test()
end

-- 删除将要移动的cellTb
function GridManager:removeMoveTb(  )
	self._moveTb = {}
end

-- 场景初始化的时候的cell位置
function GridManager:initCellId(row,col)
	-- local _stage = 1 -- 关卡
	local cellId = data_CellInitCfg[game.nowStage][8-row][col]
	if cellId==8 then
		local _ranCellId = self:randomId()
		if _ranCellId<=6 and _ranCellId>=1 then
			return _ranCellId
		else
			return 1
		end
	elseif cellId==19 then
		local _ranCellId = self:randomId()
		if _ranCellId<=6 and _ranCellId>=1 then
			return _ranCellId+12
		else
			return 13
		end
	elseif cellId==26 then
		local _ranCellId = self:randomId()
		if _ranCellId<=6 and _ranCellId>=1 then
			return _ranCellId+19
		else
			return 20
		end
	else
		return cellId
	end
end

function GridManager:find(row,col)
	local index = (row - 1) * game.GRID_COLS + col
	if self.data_[index] == game.CELL_TYPE_UNKNOWN then

		return nil
	else
		return self.data_[index]
	end

end

function GridManager:getRowAndCol(cell)
	if not cell then return nil end

	for i,v in ipairs(self.data_) do
		if cell==v then
			local row = math.ceil(i/game.GRID_COLS)
			local col = i%game.GRID_COLS==0 and game.GRID_COLS or i%game.GRID_COLS
			return row,col
		end
	end

end

function GridManager:set(row,col,cell)
	local index = (row - 1) * game.GRID_COLS + col
	--print(string.format("row===%d,col======%d,index=========%d", row,col,index))
	self.data_[index] = cell
end

function GridManager:del(row,col)
	local index = (row - 1) * game.GRID_COLS + col
	if self.data_[index] and self.data_[index]~=game.CELL_TYPE_UNKNOWN then
		-- 判断对周围有生命的cell的影响
		self:affectAroundCell(row,col)
		-- 播消失的动画
		self.data_[index]:playDisappearAni()
		--print(string.format("row===%d,col======%d,index=========%d", row,col,index))
		self.data_[index] = game.CELL_TYPE_UNKNOWN
	end
end
-- 从gridManager里删除收集物
function GridManager:delCollector(row,col)
	local index = (row - 1) * game.GRID_COLS + col
	if self.data_[index] and self.data_[index]~=game.CELL_TYPE_UNKNOWN then
		--print(string.format("row===%d,col======%d,index=========%d", row,col,index))
		self.data_[index] = game.CELL_TYPE_UNKNOWN
	end
end

function GridManager:removeCell(cell)
	local row,col = self:getRowAndCol(cell)
	if row~=nil then
		local index = (row - 1) * game.GRID_COLS + col
		cell:removeFromParent()
		self.data_[index] = game.CELL_TYPE_UNKNOWN
	end
end

function GridManager:swap(r1,c1,r2,c2)
	--print(string.format("r1===%d,c1===%d,r2===%d,c2===%d", r1,c1,r2,c2))
	local a1 = self:find(r1,c1)
	local a2 = self:find(r2,c2)
	
	if not a1 then
		a1 = game.CELL_TYPE_UNKNOWN
	end

	if not a2 then
		a2 = game.CELL_TYPE_UNKNOWN
	end

	self:set(r2,c2,a1)
	self:set(r1,c1,a2)
end

--[[
	能下落行数量
--]]
function GridManager:downNum(row,col)
	local num = 0
	local st = row - 1
	
	if st <= 0 then
	 	return num
	end

	for i=st,1,-1 do
		-- 障碍物影响下落数量
   		if self:isEmpty(i, col) then
   			num = num + 1
   		else
   			return num
   		end
 	end

 	return num
end

-- 每一列有多少个cell是空的
function GridManager:colEmptyNum()
	local colTb = {}
	for i=1,game.GRID_COLS do
		colTb[i] = 0
	end
	for i=1,game.GRID_COLS do
		colTb[i] = self:downNum(game.GRID_ROWS+1, i)
	end
	return colTb 
end


function GridManager:isEmpty(row,col)
	if not self:find(row,col) then
		return true
	end

	return false
end

function GridManager:test()
	--dump(self.data_)
end

-- 生成新的随机降落
function GridManager:randomId()
	local weightTb = {}
	if game.stageLoseTimes[game.nowStage] and game.stageLoseTimes[game.nowStage]>5 then
		weightTb = common:string_to_table(stageCfg[game.nowStage].initCellWeight3)
	elseif game.stageLoseTimes[game.nowStage] and game.stageLoseTimes[game.nowStage]>2 then
		weightTb = common:string_to_table(stageCfg[game.nowStage].initCellWeight2)
	else
		weightTb = common:string_to_table(stageCfg[game.nowStage].initCellWeight)
	end
    local randomCellId = common:getProbabilityWithTable(weightTb)
    -- 屏幕上有超过两个以上的收集物就不再落随机物了
    if randomCellId==stageCfg[game.nowStage].collectId then
    	local _collectorNum = 0
    	for col=1,game.GRID_COLS do
	      	for row=1,game.GRID_ROWS do
	      		local _cell = self:find(row, col)
	      		if _cell and _cell.id==stageCfg[game.nowStage].collectId then
	      			_collectorNum = _collectorNum + 1
	      		end
	      	end
      	end
      	if _collectorNum>=2 then
      		return self:randomId()
      	else
      		return randomCellId
      	end
    else
		return randomCellId
	end
end

-- 获取7连以上的生成cell
function GridManager:getLongLinkType()
	return 8
end

-- 将要移位的cell存在一起，到时候一起滑动
function GridManager:setMoveCell( cell,row,col )
	cell.toPosition = gridToPoint(row, col)
	if table.keyof(self._moveTb,cell)==nil then
		table.insert(self._moveTb,cell)
	end
end

-- 上面记录要滑动的cell运动，并颤
function GridManager:runDropAni()
	for i,v in ipairs(self._moveTb) do
		v:dropShakeAni(v.toPosition)
	end
	-- 划完之后要判断时候在新手引导
	if game.guideStep==2 or game.guideStep==5 or game.guideStep==7 then
		sendMessage({msg="GuideView_slideCell"})
	end
end

-- 找出当前列需要降落几个cell
function GridManager:getAllEmptyCell()
	local emptyCellTb = {}
	for i=1,game.GRID_COLS * game.GRID_ROWS do
	   if self.data_[i] == game.CELL_TYPE_UNKNOWN then
	   		table.insert(emptyCellTb,i)
	   end
	end
	return emptyCellTb
end

function GridManager:cellRunBomb(cell)
	if cell:isBomb() then
		print("GridManager:cellRunBomb")
		self:bombCross(cell)
	end
end
-- 炸弹爆炸，消除十字型
function GridManager:bombCross(cell)
	local row,col = self:getRowAndCol(cell)
	if row == nil then return end
	
	-- 爆炸的cell id
	local cellIdTb = {}
	table.insert(cellIdTb,cell.id)
	self:del(row, col)
	-- 从中心往右爆炸
	for i=col+1,game.GRID_ROWS do
		local cell = self:find(row, i)
		if not cell then break end
		if cell:hasMoreLife() then
			table.insert(self._affectTb, cell)
			break
		end
		self:cellRunBomb(cell)
		table.insert(cellIdTb,cell.id)
		self:del(row, i)
	end
	-- 从中心往左爆炸
	for i=col-1,1,-1 do
		local cell = self:find(row, i)
		if not cell then break end
		if cell:hasMoreLife() then
			table.insert(self._affectTb, cell)
			break
		end
		self:cellRunBomb(cell)
		table.insert(cellIdTb,cell.id)
		self:del(row, i)
	end
	-- 从中心往下爆炸
	for i=row-1,1,-1 do
		local cell = self:find(i, col)
		if not cell then break end
		if cell:hasMoreLife() then
			table.insert(self._affectTb, cell)
			break
		end
		self:cellRunBomb(cell)
		table.insert(cellIdTb,cell.id)
		self:del(i, col)
	end
	-- 从中心往上爆炸
	for i=row+1,game.GRID_COLS do
		local cell = self:find(i, col)
		if not cell then break end
		if cell:hasMoreLife() then
			table.insert(self._affectTb, cell)
			break
		end
		self:cellRunBomb(cell)
		table.insert(cellIdTb,cell.id)
		self:del(i, col)
	end
	-- 对战斗的数值影响
	FightManager:calActNum( cellIdTb )
	self:runBombRoleAni(cellIdTb)
end

-- 两个cell是不是挨着
function GridManager:isLink(cell1,cell2)
    local r1,c1 = cell1:getGridPosition()
    local r2,c2 = cell2:getGridPosition()

    --print(string.format("%d=====%d========%d=========%d", r1,c1,r2,c2))
    local a = math.abs(r2 - r1)
    local b = math.abs(c2 - c1)
    
    if a > 1 or b > 1 then
      return false
    end

    if (a + b) > 2 or (a + b) == 0 then
      return false
    end
    
    return true
end

-- 炸弹cell爆炸后，主角动画
function GridManager:runBombRoleAni( idTb )
	local delayTime = 0
	local comboTb = {}
	-- 物块按延迟飞向人物
	GameConfig.FlyDelayTime = 0

	if common:table_has_value(idTb,{1,2,3,4}) then
		sendMessage({msg ="ENEMY_ROLE",aniStr = "beat2"})
		table.insert(comboTb,"attack2")
	end

	if common:table_has_value(idTb,5) then
		table.insert(comboTb,"shield")
	end

	if common:table_has_value(idTb,6) then
		table.insert(comboTb,"meat")
	end

	sendMessage({msg ="MAIN_ROLE_COMBO",aniTb = comboTb})

end

-- 普通cell连接消失后，主角动画
function GridManager:runRoleAni( cellId,cellCount )
	-- 物块按延迟飞向人物
  	GameConfig.FlyDelayTime = 0
  	-- 6个以上播放大招动画
	if cellId==1 or cellId==2 or cellId==3 or cellId==4 then
		if cellCount>=6 then
			sendMessage({msg ="MAIN_ROLE",aniStr = "attack2"})
			sendMessage({msg ="ENEMY_ROLE",aniStr = "beat2"})
		else
			sendMessage({msg ="MAIN_ROLE",aniStr = "attack"})
			sendMessage({msg ="ENEMY_ROLE",aniStr = "beat"})
		end
	elseif cellId==6 then
		sendMessage({msg ="MAIN_ROLE",aniStr = "meat"})
	elseif cellId==5 then
		sendMessage({msg ="MAIN_ROLE",aniStr = "shield"})
	end
end

-- 判断对周围有生命的cell的影响
function GridManager:affectAroundCell( row,col )
	local indexTb = {}
	if col>1 then
		indexTb[1] = (row - 1) * game.GRID_COLS + col-1 --left
	end
	if row>1 then
		indexTb[2] = (row-2) * game.GRID_COLS + col -- down
	end
	if col<7 then
		indexTb[3] = (row-1) * game.GRID_COLS + col+1 -- right
	end
	if row<7 then
		indexTb[4] = row * game.GRID_COLS + col -- up
	end
	for i,v in pairs(indexTb) do
		if v>0 and v <= game.GRID_COLS*game.GRID_ROWS then
			local cell = self.data_[v]
			if cell and cell~=game.CELL_TYPE_UNKNOWN then
				table.insert(self._affectTb, cell)
			end
		end
	end

end

-- 更换被影响的物块图片
function GridManager:refreshAffectCell( )
	local affectTb = common:table_del_repeat_value(self._affectTb)
	for k,v in pairs(affectTb) do
        if v and v.id~=nil then
        	-- print("v.id is "..v.id)
			v:minusLife()
			v:refreshPic()
		end
		if v.id==0 then
			self:removeCell(v)
		end
	end
	self._affectTb = {}
end

-- 该cell旁边可以连接的所有cell
function GridManager:canLinkCell( row,col )
	local _cell = self:find(row, col)
	if not _cell or _cell:canClick()==false then return {} end
	local indexTb,canLinkTb = {},{}
	if row<7 and col>1 then
		table.insert(indexTb,row * game.GRID_COLS + col-1)-- up left
	end
	if row<7 then
		table.insert(indexTb,row * game.GRID_COLS + col)-- up
	end
	if col<7 and row<7 then
		table.insert(indexTb,row * game.GRID_COLS + col+1)-- right up
	end
	if col>1 then
		table.insert(indexTb,(row - 1) * game.GRID_COLS + col-1)--left
	end
	if col<7 then
		table.insert(indexTb,(row-1) * game.GRID_COLS + col+1)-- right
	end
	if col>1 and row>1 then
		table.insert(indexTb,(row - 2) * game.GRID_COLS + col-1)--left down
	end
	if row>1 then
		table.insert(indexTb,(row-2) * game.GRID_COLS + col)-- down
	end
	if row>1 and col<7 then
		table.insert(indexTb,(row-2) * game.GRID_COLS + col+1)-- down right
	end
	
	
	for i,v in pairs(indexTb) do
		if v>0 and v <= game.GRID_COLS*game.GRID_ROWS then
			local cell = self.data_[v]
			if cell and cell~=game.CELL_TYPE_UNKNOWN and cell.id~=nil and _cell.id==cell.id then
				table.insert(canLinkTb, cell)
			end
		end
	end
	return canLinkTb
end
-- 判断是否无可消除物块
-- function GridManager:judgeNoEliminateCell( )
-- 	local isRefresh = false
-- 	for col=1,game.GRID_COLS do
--       	for row=1,game.GRID_ROWS do
-- 			local linkTb = self:canLinkCell(row,col)
-- 			if #linkTb>0 then
-- 				if #linkTb==1 and linkTb[1].id~=nil then
-- 					local _row,_col = self:getRowAndCol(linkTb[1])
-- 					local _linkTb = self:canLinkCell(_row,_col)
-- 					if #_linkTb==1 and _linkTb[1].id~=nil and linkTb[1].id==_linkTb[1].id then
-- 						isRefresh = true
-- 					end
-- 				else
-- 					return false
-- 				end
-- 			end
-- 		end
-- 	end
-- 	return isRefresh
-- end

-- 刷新全部物块
function GridManager:refreshAllCell( )
	local _midPos = gridToPoint(4,4)
	for col=1,game.GRID_COLS do
      	for row=1,game.GRID_ROWS do
      		local cell = self:find(row, col)
      		if cell and cell:isInRefreshTb() then
      			-- 动画：向中间物块飞过去然后再飞回来
      			local _oriPos = gridToPoint(row, col)
      			cell:runAction(cc.Sequence:create(
      				cc.MoveTo:create(0.3,_midPos),
      				cc.CallFunc:create(function( )
      					cell.id = self:randomId()
      					cell:refreshPic()
      				end),
      				cc.MoveTo:create(0.3,_oriPos)
      			))
      		end
      	end
  	end
end
-- 提示可以连接的物块
function GridManager:hintLinkCellTb( needFindId )
	for row=game.GRID_ROWS,1,-1 do
      	for col=1,game.GRID_COLS  do
      		local _cell = self:find(row,col)
      		if _cell and _cell.id==needFindId then
	      		local linkTb = self:canLinkCell(row,col)
	      		if #linkTb>1 then
	      			local _hintLinkTb = {}
	      			_hintLinkTb[1] = {_row=row,_col=col}
	      			for i,v in ipairs(linkTb) do
	      				if self:getRowAndCol(v) then
	      					local r,c = self:getRowAndCol(v)
		      				table.insert(_hintLinkTb,{_row=r,_col=c})
		      			end
	      			end
	      			return _hintLinkTb
	      		end
	      	end
      	end
  	end
  	return nil
end
-- 提示一个按顺序连接的table
function GridManager:getOrderedHintTable()
	local _orderTb,_tempTb = {},{}
	for k,v in ipairs({1,2,3,4,6,5}) do
		if self:hintLinkCellTb(v)~=nil then
			_tempTb = self:hintLinkCellTb(v)
			break
		end
	end
	
	if #_tempTb>0 then
		_orderTb[2] = self:find(_tempTb[1]._row,_tempTb[1]._col)
		_orderTb[3] = self:find(_tempTb[2]._row,_tempTb[2]._col)
		_orderTb[1] = self:find(_tempTb[3]._row,_tempTb[3]._col)
	end
	return _orderTb
end
-- 选中物块高亮
function GridManager:cellHightLight( cellId )
	for col=1,game.GRID_COLS do
      	for row=1,game.GRID_ROWS do
      		local _cell = self:find(row, col)
      		if _cell and _cell.id ~= cellId then
      			_cell:setShadeVisible(true)
      		end
      	end
  	end
end
-- 取消所有选中高亮
function GridManager:cancelHightLight()
	for col=1,game.GRID_COLS do
      	for row=1,game.GRID_ROWS do
      		local _cell = self:find(row, col)
      		if _cell then
      			_cell:setShadeVisible(false)
      		end
      	end
  	end
end
-- 收集收集物
function GridManager:collectCell()
	local row = 1
	for col=1,game.GRID_COLS do
		local _cell = self:find(row,col)
		-- 改cell是收集物
		if _cell and _cell.id==stageCfg[game.nowStage].collectId then
			self:delCollector(row, col)
            game.getScores = game.getScores + _cell:getScore()
			_cell:removeFromParent()
			
			game.collectNum = game.collectNum + 1
			sendMessage({msg="GAMESCENE_REFRESH_LEFTNUM"})
			FightManager:judgeWin()
			return true
		end
	end
	return false
end

-- 物块扫光
function GridManager:cellBlink()
	local _ranId = math.random(1,6)
	for col=1,game.GRID_COLS do
      	for row=1,game.GRID_ROWS do
      		local _cell = self:find(row, col)
      		if _cell and _cell.id == _ranId then
      			_cell:clipFlight()
      		end
      	end
  	end
end

-- 炸弹2秒动画
function GridManager:bombBlink()
	for col=1,game.GRID_COLS do
      	for row=1,game.GRID_ROWS do
      		local _cell = self:find(row, col)
      		if _cell and _cell:isBomb() then
      			_cell:bombFlight()
      		end
      	end
  	end
end

return GridManager

