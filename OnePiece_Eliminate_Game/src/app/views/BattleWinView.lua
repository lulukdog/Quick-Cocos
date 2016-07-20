----------------------------------------------------------------------------------
--[[
    FILE:           BattleWinView.lua
    DESCRIPTION:    船升级页面
    AUTHOR:         ZhaoLu
    CREATED:        2016-06-21 
--]]
----------------------------------------------------------------------------------
local FightManager = require("app.game.FightManager")
local stageCfg = require("data.data_stage")
local GameConfig = require("data.GameConfig")
local common = require("app.common")

local BattleWinView = class("BattleWinView", function()
    return display.newNode()
end)

function BattleWinView:ctor()

	self._mainNode = CsbContainer:createPushCsb("WinPopPage.csb"):addTo(self)
	self._mainAni = cc.CSLoader:createTimeline("WinPopPage.csb")
	self._mainNode:runAction(self._mainAni)
	local starAni = GameConfig.WinAniFrame["star"..FightManager.starNum]
	self._mainAni:gotoFrameAndPlay(1,starAni.firstEnd,false)
	self._mainNode:runAction(cc.Sequence:create(
		cc.DelayTime:create(starAni.firstEnd/GAME_FRAME_RATE),
		cc.CallFunc:create(function()
			self._mainAni:gotoFrameAndPlay(starAni.frameBegin,starAni.frameEnd,true)
		end)
	))
	
	local nextStage = cc.uiloader:seekNodeByName(self._mainNode,"mNextStageBtn")
	CsbContainer:decorateBtnNoTrans(nextStage,function()
		-- 失败权重清0
		game.stageLoseTimes[game.nowStage] = 0
		
		app:enterScene("MapScene", nil, "fade", 0.6, display.COLOR_WHITE)
	end)

	-- 显示奖励内容 TODO
	-- local rewardStr = stageCfg[game.nowStage]["starReward"..FightManager.starNum]
	-- local rewardCfg = common:parseStrWithComma(rewardStr)
	-- for i,v in ipairs(rewardCfg) do
	-- 	if v.id == game.ITEM.EXP then
			
	-- 	end
	-- end

	CsbContainer:setStringForLabel(self._mainNode,{
		mShipExpLabel = FightManager.shipExp,
		mScoreLabel = game.getScores,
    	mHighestScoreLabel = FightManager.highestScore,
    	mGoldLabel = FightManager.winGold,
    	mStageNumLabel = string.format("%03d",game.nowStage),
	})

end

return BattleWinView