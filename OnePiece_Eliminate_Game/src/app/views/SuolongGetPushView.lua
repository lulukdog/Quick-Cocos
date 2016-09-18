----------------------------------------------------------------------------------
--[[
    FILE:           SuolongGetPushView.lua
    DESCRIPTION:    获得索隆界面
    AUTHOR:         ZhaoLu
    CREATED:        2016-07-21 
--]]
----------------------------------------------------------------------------------
local SuolongGetPushView = class("SuolongGetPushView", function()
    return display.newNode()
end)

function SuolongGetPushView:ctor(roleNum)

	self._mainNode = CsbContainer:createPushCsb("SuolongGetPushView.csb"):addTo(self)
    self._mainAni = cc.CSLoader:createTimeline("SuolongGetPushView.csb")
    self._mainNode:runAction(self._mainAni)
    self._mainAni:gotoFrameAndPlay(0,45,true)

    local closeBtn = cc.uiloader:seekNodeByName(self._mainNode,"mCloseBtn")
    CsbContainer:decorateBtnNoTrans(closeBtn,function()
        self:removeFromParent()
        self._mainNode = nil
    end)
    print("SuolongGetPushView:ctor")

end

return SuolongGetPushView