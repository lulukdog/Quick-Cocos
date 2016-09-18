----------------------------------------------------------------------------------
--[[
    FILE:           NameiGetPushView.lua
    DESCRIPTION:    获得娜美界面
    AUTHOR:         ZhaoLu
    CREATED:        2016-07-21 
--]]
----------------------------------------------------------------------------------
local NameiGetPushView = class("NameiGetPushView", function()
    return display.newNode()
end)

function NameiGetPushView:ctor(roleNum)

	self._mainNode = CsbContainer:createPushCsb("NameiGetPushView.csb"):addTo(self)
    self._mainAni = cc.CSLoader:createTimeline("NameiGetPushView.csb")
    self._mainNode:runAction(self._mainAni)
    self._mainAni:gotoFrameAndPlay(0,45,true)

    local closeBtn = cc.uiloader:seekNodeByName(self._mainNode,"mCloseBtn")
    CsbContainer:decorateBtnNoTrans(closeBtn,function()
        self:removeFromParent()
        self._mainNode = nil
    end)
    print("NameiGetPushView:ctor")
end

return NameiGetPushView