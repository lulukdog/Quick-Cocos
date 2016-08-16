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
    self._guideNode = cc.uiloader:seekNodeByName(self._mainNode,"mGuideNode")

    addMessage(self, "GuideFingerPushView_onNext", self.onNext)
    addMessage(self, "GuideFingerPushView_onNextGuide", self.onNextGuide)
    
    self:onGuide()
end

function GuideFingerPushView:onNext()
    game.guideStep = game.guideStep + 1
    UserDefaultUtil:saveGuideStep()
    self:onExit()
end
-- 选择人物引导页面不退出指引
function GuideFingerPushView:onNextGuide()
    game.guideStep = game.guideStep + 1
    UserDefaultUtil:saveGuideStep()
    self:onGuide()
end

function GuideFingerPushView:onGuide()
    print("GuideFingerPushView:onGuide "..game.guideStep)
    CsbContainer:setStringForLabel(self._mainNode, {
        mDialogLabel = guideCfg[game.guideStep].dialog,
    })
    local _ani = cc.CSLoader:createTimeline("GuideFingerPushView.csb")
    self._mainNode:runAction(_ani)
    _ani:gotoFrameAndPlay(0,40,true)

    if game.guideStep==10 then
        local size = cc.size(260*display.right/750,90*display.right/750)
        self._mainNode:setPosition(size.width,size.height)
    elseif game.guideStep==11 then
        local mRedSprite = cc.uiloader:seekNodeByName(self._mainNode, "mRedSprite")
        mRedSprite:setVisible(true)
        self._guideNode:setPosition(-116,180)
    elseif game.guideStep==12 then
        self._guideNode:setPosition(100,-430)
        local _dialogNode = cc.uiloader:seekNodeByName(self._mainNode, "mDialogNode")
        _dialogNode:setPosition(-150,-50)
    elseif game.guideStep==14 then
        local _fingerSprite = cc.uiloader:seekNodeByName(self._mainNode, "mFingerSprite")
        _fingerSprite:setPositionY(-80)
        _fingerSprite:setRotation(0)
        self._guideNode:setPosition(-200,225)
        -- 防止使用索隆没有钱
        game.myGold = game.myGold + 200
        UserDefaultUtil:saveGold()
    elseif game.guideStep==15 then
        self._guideNode:setPosition(80,-510)
        local _dialogNode = cc.uiloader:seekNodeByName(self._mainNode, "mDialogNode")
        _dialogNode:setPosition(-100,-50)
    elseif game.guideStep==16 then
        local size = fitScreenSize(cc.size(200,50))
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