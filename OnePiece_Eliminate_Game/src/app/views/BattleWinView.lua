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
	self._mainAni:setFrameEventCallFunc(function(frame)
        local event = frame:getEvent() 
        print("BattleWinView:ctor **** " .. event)
        if frame:getEvent()=="starSound" then           
            GameUtil_PlaySound(GAME_SOUND.winStar)
        end
    end)

	self._mainNode:runAction(cc.Sequence:create(
		cc.DelayTime:create(starAni.firstEnd/GAME_FRAME_RATE),
		cc.CallFunc:create(function()
			self._mainAni:gotoFrameAndPlay(starAni.frameBegin,starAni.frameEnd,true)
		end)
	))
	
	-- 播放音乐
	GameUtil_PlayMusic(GAME_MUSIC.battleWin,false)

	local nextStage = cc.uiloader:seekNodeByName(self._mainNode,"mNextStageBtn")
	CsbContainer:decorateBtnNoTrans(nextStage,function()
		-- 失败权重清0
		game.stageLoseTimes[game.nowStage] = 0
		
		app:enterScene("MapScene", nil, "fade", 0.6, display.COLOR_WHITE)
	end)

	local advBtn = cc.uiloader:seekNodeByName(self._mainNode,"mViewAdvBtn")
	CsbContainer:decorateBtn(advBtn,function()
		print("view adv")
		advBtn:setEnabled(false)
		CsbContainer:setStringForLabel(self._mainNode, {mGoldLabel = "+"..(FightManager.winGold*2)})
		game.myGold = game.myGold + FightManager.winGold
	end)
	
	CsbContainer:setNodesVisible(self._mainNode, {
		mWinEnergyNode = FightManager.winEnergy>0,
	})

	CsbContainer:setStringForLabel(self._mainNode,{
		mShipExpLabel = FightManager.shipExp,
		mScoreLabel = game.getScores,
    	mHighestScoreLabel = FightManager.highestScore,
    	mGoldLabel = "+"..FightManager.winGold,
    	mEnergyLabel = "+"..FightManager.winEnergy,
    	mStageNumLabel = string.format("%03d",game.nowStage),
	})

end

return BattleWinView