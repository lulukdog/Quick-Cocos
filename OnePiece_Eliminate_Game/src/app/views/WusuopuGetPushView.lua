----------------------------------------------------------------------------------
--[[
    FILE:           WusuopuGetPushView.lua
    DESCRIPTION:    获得乌索普界面
    AUTHOR:         ZhaoLu
    CREATED:        2016-07-21 
--]]
----------------------------------------------------------------------------------
local WusuopuGetPushView = class("WusuopuGetPushView", function()
    return display.newNode()
end)

function WusuopuGetPushView:ctor(roleNum)

	self._mainNode = CsbContainer:createPushCsb("WusuopuGetPushView.csb"):addTo(self)
    self._mainAni = cc.CSLoader:createTimeline("WusuopuGetPushView.csb")
    self._mainNode:runAction(self._mainAni)
    self._mainAni:gotoFrameAndPlay(0,45,true)

    local closeBtn = cc.uiloader:seekNodeByName(self._mainNode,"mCloseBtn")
    CsbContainer:decorateBtnNoTrans(closeBtn,function()
        self:removeFromParent()
        self._mainNode = nil
    end)
    print("WusuopuGetPushView:ctor")
end

return WusuopuGetPushView