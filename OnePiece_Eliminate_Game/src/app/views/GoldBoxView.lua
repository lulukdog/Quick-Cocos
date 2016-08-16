----------------------------------------------------------------------------------
--[[
    FILE:           GoldBoxView.lua
    DESCRIPTION:    
    AUTHOR:         ZhaoLu
    CREATED:        2016-06-24 
--]]
----------------------------------------------------------------------------------
local GameConfig = require("data.GameConfig")
local stageCfg = require("data.data_stage")
local common = require("app.common")

local GoldBoxView = class("GoldBoxView", function()
    return display.newNode()
end)

function GoldBoxView:ctor()

	self._mainNode = CsbContainer:createPushCsb("GoldBoxView.csb"):addTo(self)

    local _boxGold = tonumber(stageCfg[common:getNowMaxStage()].boxGold)
    local getBtn = cc.uiloader:seekNodeByName(self._mainNode,"mGetBtn")
	CsbContainer:decorateBtn(getBtn,function()
        -- 统计视频次数
        common:javaSaveUserData("AdvVideo",tostring(GameConfig.AdvType.rewardBox))
        game.boxLeftTime = game.boxRewardTime
        UserDefaultUtil:SaveBoxLeftTime()
        game.myGold = game.myGold+_boxGold
        sendMessage({msg="REFRESHGOLD"})
        sendMessage({msg="MapScene_getBoxReward"})
        self:removeFromParent()
        self._mainNode = nil
	end)

    CsbContainer:setStringForLabel(self._mainNode, {mGoldLabel=_boxGold})
end

return GoldBoxView