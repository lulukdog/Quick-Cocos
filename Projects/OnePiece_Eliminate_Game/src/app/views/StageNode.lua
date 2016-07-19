----------------------------------------------------------------------------------
--[[
    FILE:           StageNode.lua
    DESCRIPTION:    
    AUTHOR:         ZhaoLu
    CREATED:        2016-06-30 
--]]
----------------------------------------------------------------------------------
local StageNode = class("StageNode", function()
    return display.newNode()
end)

function StageNode:ctor(callFunc,starNum)
    self._btn = cc.ui.UIPushButton.new({normal = "guanka_blue_btn.png"}):addTo(self)
    self._btn:setVisible(true)
    self._btn:onButtonClicked(function()
        callFunc()
    end)

    for i=1,starNum do
        local star = display.newSprite("star-000.png"):addTo(self)
        star:setVisible(true)
        star:setPosition((i-2)*20,-80)
        star:setRotation((i-2)*20)
    end
end

return StageNode