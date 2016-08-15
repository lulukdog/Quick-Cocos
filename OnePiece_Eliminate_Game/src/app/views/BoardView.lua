----------------------------------------------------------------------------------
--[[
    FILE:           BoardView.lua
    DESCRIPTION:    消除界面
    AUTHOR:         ZhaoLu
    CREATED:        2016-06-01 
--]]
----------------------------------------------------------------------------------

local Cell = import("..game.Cell")
local ChainView = import(".ChainView")
local GridManager = import("..game.GridManager")
local BubbleButton = import(".BubbleButton")
local scheduler  = require(cc.PACKAGE_NAME .. ".scheduler")
local FightManager = require("app.game.FightManager")
local common = require("app.common")
local GameConfig = require("data.GameConfig")

local BoardView = class("BoardView", function()
    return display.newNode()
end)

function BoardView:ctor(gameOverCallback)
  print("BoardView:ctor")
  self.gameOverCallback = gameOverCallback

  self.gridMgr = GridManager.new()
  self.linkData = {}
  self.isFirtEnterView = true -- 是否是第一次进入页面，控制滑动才扣除体力

  local boardBg = display.newSprite("pic/boardBG.png"):addTo(self)
  boardBg:setAnchorPoint(0.5,0)
  boardBg:setPosition(0,-5)
  -- 炸弹动画
  self.gridMgr:bombBlink()
  
  self:createBoard()
  self:createCell()

  addMessage(self, "BOARVIEW_EXIT",self.onExit)

  -- 如果9秒没有操作就给提示
  self._hintCount=0 --操作之后的倒计时
  self._isInhint = false --当前是否在提示中，方式不断添加提示线
  self._hintHanlder = scheduler.scheduleGlobal(function( )
    self._hintCount = self._hintCount + 3
    
    -- 6秒没有操作的话添加扫光
    if self._hintCount>=6 then
      self.gridMgr:cellBlink()
    end

    if self._hintCount>=9 and self._isInhint==false then
        local _hintOrderTb = self.gridMgr:getOrderedHintTable()
        if #_hintOrderTb>0 then
            self._isInhint = true
            for i=1,2 do
                local _p1 = cc.p(_hintOrderTb[i]:getGridPosition())
                local _p2 = cc.p(_hintOrderTb[i+1]:getGridPosition())
                self.chainLayer:pushChain(_p1,_p2,80)
            end
        else
            -- 没有可消除的物块时，刷新全部物块
            sendMessage({msg="GameScene_NoLinkTip"})
            self.gridMgr:refreshAllCell()
        end
    end
  end,3)
end

function BoardView:createCell()
  for i=1,game.GRID_COLS do
      for j=1,game.GRID_ROWS do
          local cellId = self.gridMgr:initCellId(j,i)
          self:addCell(j,i,cellId)
      end
   end
end

function BoardView:addCell(row, col, id, initPoint)
  local cell = Cell.new(id)
  self.gridMgr:set(row,col,cell)
  cell:addTo(self.boardLayer)
  if initPoint ~= nil then
     cell:setPosition(initPoint)
     cell:setVisible(false)
     self.gridMgr:setMoveCell(cell,row,col)
  else
     cell:setGridPosition(row, col)
     -- cell 是炸弹
     if cell:isBomb() then
      cell:setVisible(false)
      scheduler.performWithDelayGlobal(function(  )
        cell:setVisible(true)
        -- 炸弹动画
        cell:bombFlight()
      end,1)
     end
  end

  return cell
end

function BoardView:createBoard()
   local boardBg = cc.LayerColor:create(cc.c4b(90, 65, 73,255))
   boardBg:setContentSize(game.GRID_WIDTH,game.GRID_HEIGHT)
   boardBg:setPosition(boardBg:getContentSize().width * - 0.5 ,0)

   -- self:addChild(self.chainLayer)

   for i=1,game.GRID_COLS do
      for j=1,game.GRID_ROWS do
         local tile = nil
         if (i+j)%2==1 then
            tile = display.newSprite("bg_grid1.png")
         else
            tile = display.newSprite("bg_grid2.png")
         end
         tile:setPosition(gridToPoint(j,i))
         tile:addTo(boardBg)
      end
   end
   self.chainLayer =  ChainView.new():addTo(boardBg)
   self.chainLayer:setPosition(boardBg:getContentSize().width * 0.5 ,0)

   self.boardLayer = display.newNode()
   self.boardLayer:addTo(boardBg)
   self.boardLayer:setTouchEnabled(true)
   self.boardLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onTouchEvent))
   
   -- 剪裁区域
   local rect = cc.rect(boardBg:getPositionX(),boardBg:getPositionY(),boardBg:getContentSize().width,boardBg:getContentSize().height)
   self:addChild(boardBg)

end

-- 从上往下降落
function BoardView:dropTopCell()

   local tb = self.gridMgr:colEmptyNum()
   for colNum,emptyNum in ipairs(tb) do
      for i=emptyNum,1,-1 do
        -- print(string.format("BoardView:dropTopCell %d,%d", game.GRID_ROWS-i+1,colNum))
        local targetPoint = gridToPoint(game.GRID_ROWS-i+1,colNum)
        local initPoint = cc.p(targetPoint.x,game.DROP_HEIGHT)
        local cellId = self.gridMgr:randomId()
        self:addCell(game.GRID_ROWS-i+1, colNum, cellId, initPoint)
      end
   end

end
-- 消除后，剩余的cell同列掉落的方案
function BoardView:dropCell()
  -- body
  for i=1,game.GRID_COLS do
      for j=2,game.GRID_ROWS do
         local cell = self.gridMgr:find(j,i) 
         if cell then
            if cell:canDrop() then
              local num = self.gridMgr:downNum(j, i)
              if num > 0 then
                self.gridMgr:swap(j,i,j-num,i)
                self.gridMgr:setMoveCell(cell,j - num,i)
              end
            end
         end  
      end
   end
end

-- 消除后，剩余的cell两侧掉落的方案，先左后右
function BoardView:sideDropCell()

  --往右侧掉落
   for i=1,game.GRID_COLS-1 do
      for j=game.GRID_ROWS,2,-1 do
         local cell = self.gridMgr:find(j,i) 
         if cell then
            if cell:canDrop() then
              local num = self.gridMgr:downNum(j, i + 1)
              if num > 0 then
                  self.gridMgr:swap(j,i,j-num,i + 1)
                  self.gridMgr:setMoveCell(cell,j - num,i+1)
              end
            end
         end  
      end
   end

   --往左侧掉落
   for i=game.GRID_COLS,2,-1 do
      for j=game.GRID_ROWS,2,-1 do
         local cell = self.gridMgr:find(j,i) 
         if cell then
            if cell:canDrop() then
              local num = self.gridMgr:downNum(j, i - 1)
              if num > 0 then
                  self.gridMgr:swap(j,i,j-num,i - 1)
                  self.gridMgr:setMoveCell(cell,j - num,i-1)
              end
            end
         end  
      end
   end

end

-- 其他cell降落规则
function BoardView:cellDropFill()
    local lastEmptyCells = {}
    while not common:is_table_same(lastEmptyCells,self.gridMgr:getAllEmptyCell()) do
      lastEmptyCells = self.gridMgr:getAllEmptyCell()
      -- dump(lastEmptyCells)
      -- 先判断同列的再判断两侧的
      --self.gridMgr:test()
       self:dropCell()
       --self.gridMgr:test()
       self:sideDropCell()
       self:dropTopCell()
    end
    self:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.8),
        cc.CallFunc:create(function()
            self:downCell()
        end),
        cc.DelayTime:create(0.2),
        cc.CallFunc:create(function( )
            if self.gridMgr:collectCell() then
                self:cellDropFill()
            end
        end)
        --self.gridMgr:test()
    ))
end

function BoardView:mergeCell()
  -- 消除第一次之后在开始扣除体力
  if self.isFirtEnterView then
    self.isFirtEnterView = false
    common:energyCost(5)
  end
  -- 连消7个以上
  local r1,c1 = 0,0
  if #self.linkData>=game.BOMB_LINK_NUM then
    local lastCell = self.linkData[#self.linkData]
    r1,c1 = lastCell:getGridPosition()
  end

  local cellIdTb = {}
  for k,v in pairs(self.linkData) do
     v:setLinkTag()
     table.insert(cellIdTb,v.id)

     local r2,c2 = v:getGridPosition()
     -- 从grid数据中删除该cell
     self.gridMgr:del(r2,c2)
  end
  -- 计算伤害，加血，防御
  FightManager:calActNum(cellIdTb)
  -- 播放动画
  self.gridMgr:runRoleAni(self.linkData[1].id,#self.linkData)

  self.gridMgr:refreshAffectCell()

  self.linkData = {}

  -- 炸弹
  if r1~=0 then
    self:addCell(r1, c1, game.BOMBID)
  end
  self:cellDropFill()

end

-- 填补规则，从上往下掉落cell
function BoardView:downCell()
   self.gridMgr:runDropAni()
   self.gridMgr:removeMoveTb()
end

function BoardView:onTouchEvent(event)

  -- event.name 是触摸事件的状态：began, moved, ended, cancelled
    -- event.x, event.y 是触摸点当前位置
    -- event.prevX, event.prevY 是触摸点之前的位置
    -- printf("sprite: %s x,y: %0.2f, %0.2f",
    --        event.name, event.x, event.y)

    local cell = self:cellForTouch(event)
    self._hintCount = 0

    if event.name == "began" then

        if cell then
            -- 防止bug
            sendMessage({msg="GameScene_PauseDisable"})
            -- print("BoardView:onTouchEvent began cell id "..cell.id)
            -- 不可点击的障碍物
            if cell:canClick()==false then
                return
            end
            -- 有操作就不给提示
            self.chainLayer:removeAllChain()
            self._isInhint = false
            -- 点击爆炸物
            if cell:isBomb() then
                cell:setBombTouching(true)
                cell:selected()
            else
                self.lastPoint = cc.p(event.x,event.y)
                table.insert(self.linkData,cell)
                cell:selected()

                local p1 = cc.p(cell:getGridPosition())
                self.chainLayer:pushChain(p1)

                -- 选中同色物块高亮，其他遮罩
                self.gridMgr:cellHightLight(cell.id)
                -- 播放选中音效
                GameUtil_PlaySound(GAME_SOUND.linkCell1)
            end
        end

        return true

    elseif event.name == "moved" then
        
        local linkCount = table.nums(self.linkData)
        if linkCount == 0 then
            return
        end

        if not cell then
            return
        end

        local firstCell = self.linkData[linkCount]
        if linkCount > 1 then
            local secondCell =  self.linkData[linkCount - 1]
            if cell == secondCell then
                firstCell:unselected()
                table.remove(self.linkData,linkCount)
                self.chainLayer:popChain()
                -- 播放选中音效
                if #self.linkData>8 then
                  GameUtil_PlaySound(GAME_SOUND["linkCell"..8])
                else
                  GameUtil_PlaySound(GAME_SOUND["linkCell"..#self.linkData])
                end
                -- 连接时计算伤害
                sendMessage({msg="LINKNUMVIEW_REFRESH_HARM",cellId=cell.id,count=table.nums(self.linkData)})
                sendMessage({msg="FIGHTVIEW_CELL_ANI",cellId=cell.id,count=table.nums(self.linkData)})
                return
            end
        end

        if table.keyof(self.linkData,cell) then
          return
        end

        if cell.id ~= firstCell.id then
            return
        end

        if not self.gridMgr:isLink(firstCell,cell) then
            return
        end

        cell:selected()
        table.insert(self.linkData,cell)
        -- 播放选中音效
        if #self.linkData>8 then
          GameUtil_PlaySound(GAME_SOUND["linkCell"..8])
        else
          GameUtil_PlaySound(GAME_SOUND["linkCell"..#self.linkData])
        end

        local p1 = cc.p(cell:getGridPosition())
        local p2 = cc.p(firstCell:getGridPosition())
        self.chainLayer:pushChain(p1, p2)
        sendMessage({msg="LINKNUMVIEW_REFRESH_HARM",cellId=cell.id,count=table.nums(self.linkData)})
        sendMessage({msg="FIGHTVIEW_CELL_ANI",cellId=cell.id,count=table.nums(self.linkData)})

    elseif event.name == "ended" then
        -- 防止bug
        sendMessage({msg="GameScene_PauseEnable"})
        -- 点击爆炸物
        if cell and cell:isBomb() and cell:getBombTouching() then
            self.gridMgr:bombCross(cell)
            self.gridMgr:refreshAffectCell()
            self:cellDropFill()
            sendMessage({msg ="GAMESCENE_DISABLE"})
            GameUtil_PlaySound(GAME_SOUND.bomb)
            return
        end
        local linkCount = table.nums(self.linkData)
        
        if linkCount == 0 then
            return
        end

        self.chainLayer:removeAllChain()
        -- 取消所有选中高亮
        self.gridMgr:cancelHightLight()

        if linkCount < 3 then
            for k,v in pairs(self.linkData) do
               v:unselected() 
               v:rock() 
            end
            self.linkData = {}
        else
            -- 取消伤害显示
            if self.linkData[1].id~=6 then
                sendMessage({msg="LINKNUMVIEW_HIDE"})
            end
            -- sendMessage({msg="MAIN_ROLE",aniStr="stand"})
            self:mergeCell()
            --开始合并时停止触摸
            sendMessage({msg ="GAMESCENE_DISABLE"})
        end

    elseif event.name == "cancelled" then

    end
end

function BoardView:cellForTouch(event)
  -- body
  local tb =  self.boardLayer:getChildren()
  local point = cc.p(event.x,event.y)

  for k,v in pairs(tb) do
      -- cell消失的图片和蚂蚁线等会加到上面，sprite是没有getBoxRect()方法的
      if v:getBoxRect()~=nil then
          local rect = v:getBoxRect()
          -- print("BoardView:cellForTouch event x "..event.x.." y "..event.y)
          -- print("BoardView:cellForTouch rect width "..rect.width.." height "..rect.height.." x "..rect.x.." y "..rect.y)
          if common:pointInCircle(rect, point) then
              return v
          end
      end
  end
  return nil
end

function BoardView:gamePause()
  self.boardLayer:setTouchEnabled(false)
end

function BoardView:gameResume()
  self.boardLayer:setTouchEnabled(true)
end

function BoardView:onExit()
  removeMessageByTarget(self)
  scheduler.unscheduleGlobal(self._hintHanlder)
  self.boardLayer:removeAllChildren()
  self:removeAllChildren()
  self.boardLayer = nil
  self.chainLayer = nil
  self.gridMgr = nil
  self.linkData = {}
end

return BoardView
