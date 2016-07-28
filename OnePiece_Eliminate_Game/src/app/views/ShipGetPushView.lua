
----------------------------------------------------------------------------------
--[[
    FILE:           ShipGetPushView.lua
    DESCRIPTION:    购买船获得页面
    AUTHOR:         ZhaoLu
    CREATED:        2016-07-28 
--]]
----------------------------------------------------------------------------------
local scheduler = require("framework.scheduler")

local ShipGetPushView = class("ShipGetPushView", function()
    return display.newNode()
end)

function ShipGetPushView:ctor(roleNum)

	self._mainNode = CsbContainer:createPushCsb("ShipGetPushView.csb"):addTo(self)
    local _ani = cc.CSLoader:createTimeline("ShipGetPushView.csb")

    local closeBtn = cc.uiloader:seekNodeByName(self._mainNode,"mCloseBtn")
    closeBtn:setEnabled(false)
    CsbContainer:decorateBtnNoTrans(closeBtn,function()
        print("ShipGetPushView:ctor closeBtn")
        self:removeFromParent()
        self._mainNode = nil
    end)

    self._mainNode:runAction(_ani)    
    _ani:gotoFrameAndPlay(0,150,false)
    scheduler.performWithDelayGlobal(function()
        _ani:gotoFrameAndPlay(90,150,true)
        closeBtn:setEnabled(true)
    end,150/GAME_FRAME_RATE)

end

return ShipGetPushView