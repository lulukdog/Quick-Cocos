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

function GoldBoxView_video(result)
    if result== "success" then
        sendMessage({msg="GoldBoxView_videoSuccess"})
    end
end

function GoldBoxView:ctor()

	self._mainNode = CsbContainer:createPushCsb("GoldBoxView.csb"):addTo(self)

    local closeBtn = cc.uiloader:seekNodeByName(self._mainNode,"mCloseBtn")
    CsbContainer:decorateBtn(closeBtn,function()
        removeMessageByTarget(self)
        self:removeFromParent()
        self._mainNode = nil
    end)
    
    local getBtn = cc.uiloader:seekNodeByName(self._mainNode,"mGetBtn")
	CsbContainer:decorateBtn(getBtn,function()
        common:javaOnVideo(GoldBoxView_video)
        if device.platform=="windows" then
            self:videoSuccess()
        end
	end)

    self._boxGold = tonumber(stageCfg[common:getNowMaxStage()].boxGold)
    CsbContainer:setStringForLabel(self._mainNode, {mGoldLabel=self._boxGold})

    addMessage(self, "GoldBoxView_videoSuccess", self.videoSuccess)
end

function GoldBoxView:videoSuccess( )
    game.boxLeftTime = game.boxRewardTime
    UserDefaultUtil:SaveBoxLeftTime()
    game.myGold = game.myGold+self._boxGold
    sendMessage({msg="REFRESHGOLD"})
    sendMessage({msg="MapScene_getBoxReward"})

    -- 统计视频次数
    local jsonStr = json.encode({adv_video={
        type=GameConfig.AdvType.rewardBox,
    }})
    common:javaSaveUserData(jsonStr)
    -- 统计获得金币的地方
    local jsonStrCoin = json.encode({coin_reward={
        type=GameConfig.AdvType.rewardBox,
        getcoin=self._boxGold,
        leftcoin=game.myGold,
    }})
    common:javaSaveUserData(jsonStrCoin)

    removeMessageByTarget(self)
    self:removeFromParent()
    self._mainNode = nil
end

return GoldBoxView