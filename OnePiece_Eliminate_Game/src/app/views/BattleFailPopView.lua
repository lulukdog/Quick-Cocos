----------------------------------------------------------------------------------
--[[
    FILE:           BattleFailPopView.lua
    DESCRIPTION:    
    AUTHOR:         ZhaoLu
    CREATED:        2016-06-25 
--]]
----------------------------------------------------------------------------------
local FightManager = require("app.game.FightManager")
local stageCfg = require("data.data_stage")
local common = require("app.common")

local BattleFailPopView = class("BattleFailPopView", function()
    return display.newNode()
end)

function BattleFailPopView:ctor()

	self._mainNode = CsbContainer:createPushCsb("BattleFailPopView.csb"):addTo(self)

    local refightBtn = cc.uiloader:seekNodeByName(self._mainNode,"mRefightBtn")
	CsbContainer:decorateBtnNoTrans(refightBtn,function()
        game.stageLoseTimes[game.nowStage] = game.stageLoseTimes[game.nowStage]==nil and 1 or game.stageLoseTimes[game.nowStage]+1
        app:enterScene("MapScene", nil, "fade", 0.6, display.COLOR_WHITE)
	end)

    local halfRebirtBtn = cc.uiloader:seekNodeByName(self._mainNode,"mHalfRebirthBtn")
    CsbContainer:decorateBtn(halfRebirtBtn,function()
        self:onRebirthBtn(0.5)
    end)

    local allRebirthBtn = cc.uiloader:seekNodeByName(self._mainNode,"mAllRebirthBtn")
    CsbContainer:decorateBtn(allRebirthBtn,function()
        local _rebirthGold = stageCfg[game.nowStage].rebirthGold
        if common:goldIsEnough(_rebirthGold) then
            self:onRebirthBtn(1)
        else
            MessagePopView.new(2):addTo(self)
        end
    end)

    CsbContainer:setStringForLabel(self._mainNode, {
        mRebirtGoldLabel = stageCfg[game.nowStage].rebirthGold
    })
end

function BattleFailPopView:onRebirthBtn( per )
    FightManager:setRoleLifePercent(per)
    sendMessage({msg="GAMESCENE_REFRESH_LIFE"})
    self:removeFromParent()
    self._mainNode = nil
end

return BattleFailPopView