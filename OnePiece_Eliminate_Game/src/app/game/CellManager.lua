--
-- Author: zhaolu
-- Date: 2016-06-1 18:06:50
--

local CellManager = class("CellManager")
local GridManager = import(".GridManager")
local Cell = import(".Cell")

function CellManager:ctor()
	self.gridMgr = GridManager.new()
  -- self:test()
end

function CellManager:removeCell(row,col)
   -- body
    local cell = self.gridMgr:find(row,col)
    if cell then
         self.gridMgr:del(row,col)
         cell:removeFromParent()
    end
end

function CellManager:removeAllCell()
   for i=1,game.GRID_COLS do
      for j=1,game.GRID_ROWS do
         self:removeCell(j,i)
      end
   end
end


return CellManager
