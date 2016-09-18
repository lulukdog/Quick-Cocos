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
local GameConfig = require("data.GameConfig")

local BattleFailPopView = class("BattleFailPopView", function()
    return display.newNode()
end)

function BattleFail_Video(result)
    print("BattleFail_Video")
    if result=="success" then
        print("BattleFail_Video success")
        -- 统计关卡_战斗次数_胜利次数
        UserDefaultUtil:recordResult(2,game.nowStage,2)
       
        sendMessage({msg="BattleFailPopView_halfRebirth"})
    end
end

function BattleFailPopView:ctor()

	self._mainNode = CsbContainer:createPushCsb("BattleFailPopView.csb"):addTo(self)

    local refightBtn = cc.uiloader:seekNodeByName(self._mainNode,"mRefightBtn")
	CsbContainer:decorateBtnNoTrans(refightBtn,function()
        game.stageLoseTimes[game.nowStage] = game.stageLoseTimes[game.nowStage]==nil and 1 or game.stageLoseTimes[game.nowStage]+1
        app:enterScene("MapScene", nil, "fade", 0.6, display.COLOR_WHITE)
	end)

    local halfRebirtBtn = cc.uiloader:seekNodeByName(self._mainNode,"mHalfRebirthBtn")
    CsbContainer:decorateBtn(halfRebirtBtn,function()
        common:javaOnVideo(BattleFail_Video)
        if device.platform=="windows" then
            self:onVideoSuccess()
        end
    end)

    local allRebirthBtn = cc.uiloader:seekNodeByName(self._mainNode,"mAllRebirthBtn")
    CsbContainer:decorateBtn(allRebirthBtn,function()
        local _rebirthGold = stageCfg[game.nowStage].rebirthGold
        if common:goldCost(_rebirthGold) then
            self:onRebirthBtn(1)
            -- 记录消耗
            UserDefaultUtil:recordRebirthCost(_rebirthGold)
            -- 记录统计
            UserDefaultUtil:recordResult(2,game.nowStage,1)
        else
            MessagePopView.new(2):addTo(self)
        end
    end)

    CsbContainer:setStringForLabel(self._mainNode, {
        mRebirtGoldLabel = stageCfg[game.nowStage].rebirthGold
    })
    CsbContainer:setNodesVisible(self._mainNode, {mHalfNode = game.usedHalfRebirth==false})
    addMessage(self, "BattleFailPopView_halfRebirth", self.onVideoSuccess)
end

function BattleFailPopView:onVideoSuccess()
    print("BattleFailPopView:onVideoSuccess")
    game.usedHalfRebirth = true
    self:onRebirthBtn(0.5)
end

function BattleFailPopView:onRebirthBtn( per )
    FightManager:setRoleLifePercent(per)
    sendMessage({msg="GAMESCENE_REFRESH_LIFE"})
    removeMessageByTarget(self)
    self:removeFromParent()
    self._mainNode = nil
end

return BattleFailPopView