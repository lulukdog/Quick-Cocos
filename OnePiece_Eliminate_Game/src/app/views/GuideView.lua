----------------------------------------------------------------------------------
--[[
    FILE:           GuideView.lua
    DESCRIPTION:    引导页面
    AUTHOR:         ZhaoLu
    CREATED:        2016-07-18 
--]]
----------------------------------------------------------------------------------
local guideCfg = require("data.data_guide")

local GuideView = class("GuideView", function()
    return display.newNode()
end)

function GuideView:ctor()

	self._mainNode = CsbContainer:createCsb("GuideView.csb"):addTo(self)

    local _nextBtn = cc.uiloader:seekNodeByName(self._mainNode, "mNextBtn")
    CsbContainer:decorateBtnNoTrans(_nextBtn,function()
        game.guideStep = game.guideStep + 1
        self:onGuide()
    end)
    local _nextCollectBtn = cc.uiloader:seekNodeByName(self._mainNode, "mCollectNextBtn")
    CsbContainer:decorateBtnNoTrans(_nextCollectBtn,function()
        game.guideStep = game.guideStep + 1
        self:onGuide()
    end)

    addMessage(self, "GuideView_slideCell", self.slideCell)
    
    self:onGuide()
end

function GuideView:slideCell()
    if game.guideStep==2 or game.guideStep==5 or game.guideStep==7 then
        game.guideStep = game.guideStep+1
        self:onGuide()
    end
end

function GuideView:onGuide()
    UserDefaultUtil:saveGuideStep()
    print("GuideView:onGuide "..game.guideStep)
    if game.guideStep<=game.MAXGUIDESTEP then
        CsbContainer:setStringForLabel(self._mainNode, {
            mDialogLabel = guideCfg[game.guideStep].dialog,
            mSlideLabel = guideCfg[game.guideStep].dialog,
            mCollectLabel = guideCfg[game.guideStep].dialog,
        })
    end
    local _ani = cc.CSLoader:createTimeline("GuideView.csb")
    self._mainNode:runAction(_ani)

    if game.nowStage==1 and (game.guideStep==1 or game.guideStep==2 or game.guideStep==3) then
        CsbContainer:setNodesVisible(self._mainNode, {
            mGuideNode = game.guideStep==1 or game.guideStep==3,
            mMaskNode = game.guideStep==2,
            mPointToEnemy = game.guideStep==1,
            mAnyPointNode = game.guideStep==1,
            mCollectNode = false,
        })
        if game.guideStep==1 then
            _ani:gotoFrameAndPlay(80,160,true)
        elseif game.guideStep==2 then
            _ani:gotoFrameAndPlay(0,60,true)
        end
    elseif game.nowStage==2 and (game.guideStep==4 or game.guideStep==5 or game.guideStep==6 or game.guideStep==7) then
        CsbContainer:setNodesVisible(self._mainNode, {
            mGuideNode = game.guideStep==4 or game.guideStep==6,
            mMaskNode = game.guideStep==5 or game.guideStep==7,
            mEnemyRound = game.guideStep==4 or game.guideStep==6,
            mCollectNode = false,
        })
        if game.guideStep==4 or game.guideStep==6 then
            _ani:gotoFrameAndPlay(80,160,true)
        elseif game.guideStep==7 then
            local _maskNode = cc.uiloader:seekNodeByName(self._mainNode, "mMaskNode")
            _maskNode:setPosition(106*2,0)
        end
        if game.guideStep==5 or game.guideStep==7 then
            _ani:gotoFrameAndPlay(0,60,true)
        end
    elseif game.nowStage==9 and game.guideStep==13 then
        CsbContainer:setNodesVisible(self._mainNode, {
            mGuideNode = false,
            mMaskNode = false,
            mCollectNode = true,
            mPointToCollect = true
        })
    else
        self:onExit()
    end
end

function GuideView:onExit( )
    self._mainNode:removeFromParent()
    self._mainNode = nil

    removeMessageByTarget(self)
end

return GuideView