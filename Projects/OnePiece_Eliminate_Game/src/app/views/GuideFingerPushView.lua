----------------------------------------------------------------------------------
--[[
    FILE:           GuideFingerPushView.lua
    DESCRIPTION:    引导页面
    AUTHOR:         ZhaoLu
    CREATED:        2016-07-18 
--]]
----------------------------------------------------------------------------------
local guideCfg = require("data.data_guide")

local GuideFingerPushView = class("GuideFingerPushView", function()
    return display.newNode()
end)

function GuideFingerPushView:ctor()

	self._mainNode = CsbContainer:createPushCsb("GuideFingerPushView.csb"):addTo(self)

    addMessage(self, "GuideFingerPushView_onNext", self.onNext)
    addMessage(self, "GuideFingerPushView_onNextGuide", self.onNextGuide)
    
    self:onGuide()
end

function GuideFingerPushView:onNext()
    game.guideStep = game.guideStep + 1
    self:onExit()
end
-- 选择人物引导页面不退出指引
function GuideFingerPushView:onNextGuide()
    game.guideStep = game.guideStep + 1
    self:onGuide()
end

function GuideFingerPushView:onGuide()
    print("GuideFingerPushView:onGuide "..game.guideStep)
    CsbContainer:setStringForLabel(self._mainNode, {
        mDialogLabel = guideCfg[game.guideStep].dialog,
    })
    local _ani = cc.CSLoader:createTimeline("GuideFingerPushView.csb")
    self._mainNode:runAction(_ani)
    _ani:gotoFrameAndPlay(0,30,true)

    if game.guideStep==10 then
        local size = cc.size(260*display.right/750,90*display.right/750)
        self._mainNode:setPosition(size.width,size.height)
    elseif game.guideStep==11 then
        local size = fitScreenSize(cc.size(-160,170))
        self._mainNode:setPosition(display.cx+size.width,display.cy+size.height)
    elseif game.guideStep==12 then
        local size = fitScreenSize(cc.size(100,-440))
        self._mainNode:setPosition(display.cx+size.width,display.cy+size.height)
    elseif game.guideStep==14 then
        local size = fitScreenSize(cc.size(260,200))
        self._mainNode:setPosition(display.cx+size.width,display.cy+size.height)
    elseif game.guideStep==15 then
        local size = fitScreenSize(cc.size(80,-500))
        self._mainNode:setPosition(display.cx+size.width,display.cy+size.height)
    elseif game.guideStep==16 then
        local size = fitScreenSize(cc.size(160,50))
        self._mainNode:setPosition(size.width,size.height)
    else
        self:onExit()
    end
end

function GuideFingerPushView:onExit( )
    self._mainNode:removeFromParent()
    self._mainNode = nil

    removeMessageByTarget(self)
end

return GuideFingerPushView