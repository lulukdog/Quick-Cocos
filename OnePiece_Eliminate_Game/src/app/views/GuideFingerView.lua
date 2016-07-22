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
    UserDefaultUtil:saveGuideStep()
    print("GuideFingerView:onGuide "..game.guideStep)
    CsbContainer:setStringForLabel(self._mainNode, {
        mDialogLabel = guideCfg[game.guideStep].dialog,
    })
    if game.guideStep==8 then
        CsbContainer:setSpritesPic(self._mainNode, {
            mSprite = "pic/dao1.png",
        })
    elseif game.guideStep==9 then
        CsbContainer:setSpritesPic(self._mainNode, {
            mSprite = "GameScene/zanting.png",
        })
    else
        self:onExit()
    end
end

function GuideFingerView:onExit( )
    self._mainNode:removeFromParent()
    self._mainNode = nil
end

return GuideFingerView