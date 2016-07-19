----------------------------------------------------------------------------------
--[[
    FILE:           GuideFingerView.lua
    DESCRIPTION:    引导页面
    AUTHOR:         ZhaoLu
    CREATED:        2016-07-18 
--]]
----------------------------------------------------------------------------------
local guideCfg = require("data.data_guide")

local GuideFingerView = class("GuideFingerView", function()
    return display.newNode()
end)

function GuideFingerView:ctor()

	self._mainNode = CsbContainer:createCsb("GuideFingerView.csb"):addTo(self)

    local _nextBtn = cc.uiloader:seekNodeByName(self._mainNode, "mNextBtn")
    CsbContainer:decorateBtnNoTrans(_nextBtn,function()
        game.guideStep = game.guideStep + 1
        self:onGuide()
    end)
    
    self:onGuide()
end

function GuideFingerView:onGuide()
    print("GuideFingerView:onGuide "..game.guideStep)
    CsbContainer:setStringForLabel(self._mainNode, {
        mDialogLabel = guideCfg[game.guideStep].dialog,
    })
    if game.guideStep==8 or game.guideStep==9 then
        local _ani = cc.CSLoader:createTimeline("GuideFingerView.csb")
        self._mainNode:runAction(_ani)
        _ani:gotoFrameAndPlay(0,30,true)
    else
        self:onExit()
    end
end

function GuideFingerView:onExit( )
    self._mainNode:removeFromParent()
    self._mainNode = nil
end

return GuideFingerView