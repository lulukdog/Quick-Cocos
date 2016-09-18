----------------------------------------------------------------------------------
--[[
    FILE:           ShanzhiGetPushView.lua
    DESCRIPTION:    获得山治界面
    AUTHOR:         ZhaoLu
    CREATED:        2016-07-21 
--]]
----------------------------------------------------------------------------------
local ShanzhiGetPushView = class("ShanzhiGetPushView", function()
    return display.newNode()
end)

function ShanzhiGetPushView:ctor(roleNum)

	self._mainNode = CsbContainer:createPushCsb("ShanzhiGetPushView.csb"):addTo(self)
    self._mainAni = cc.CSLoader:createTimeline("ShanzhiGetPushView.csb")
    self._mainNode:runAction(self._mainAni)
    self._mainAni:gotoFrameAndPlay(0,45,true)

    local closeBtn = cc.uiloader:seekNodeByName(self._mainNode,"mCloseBtn")
    CsbContainer:decorateBtnNoTrans(closeBtn,function()
        self:removeFromParent()
        self._mainNode = nil
    end)
    print("ShanzhiGetPushView:ctor")
end

return ShanzhiGetPushView