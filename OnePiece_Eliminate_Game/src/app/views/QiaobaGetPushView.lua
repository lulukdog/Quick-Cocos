----------------------------------------------------------------------------------
--[[
    FILE:           QiaobaGetPushView.lua
    DESCRIPTION:    获得乔巴界面
    AUTHOR:         ZhaoLu
    CREATED:        2016-07-21 
--]]
----------------------------------------------------------------------------------
local QiaobaGetPushView = class("QiaobaGetPushView", function()
    return display.newNode()
end)

function QiaobaGetPushView:ctor(roleNum)

	self._mainNode = CsbContainer:createPushCsb("QiaobaGetPushView.csb"):addTo(self)
    self._mainAni = cc.CSLoader:createTimeline("QiaobaGetPushView.csb")
    self._mainNode:runAction(self._mainAni)
    self._mainAni:gotoFrameAndPlay(0,45,true)

    local closeBtn = cc.uiloader:seekNodeByName(self._mainNode,"mCloseBtn")
    CsbContainer:decorateBtnNoTrans(closeBtn,function()
        self:removeFromParent()
        self._mainNode = nil
    end)
    print("QiaobaGetPushView:ctor")
end

return QiaobaGetPushView