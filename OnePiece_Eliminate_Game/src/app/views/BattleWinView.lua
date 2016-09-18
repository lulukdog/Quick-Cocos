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

function BattleWin_Video( result )
	if result=="success" then
		sendMessage({msg="BattleWinView_VideoSuccess"})
    end
end
function BattleWin_Share( result )
	if result=="success" then
		sendMessage({msg="BattleWinView_ShareSuccess"})
    end
end

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
		
		removeMessageByTarget(self)
		app:enterScene("MapScene", nil, "fade", 0.6, display.COLOR_WHITE)
	end)

	local advBtn = cc.uiloader:seekNodeByName(self._mainNode,"mViewAdvBtn")
	CsbContainer:decorateBtn(advBtn,function()
		print("view adv")
		common:javaOnVideo(BattleWin_Video)
		game.needPlayAd = false
		if device.platform == "windows" then
			self:videoSuccess()
		end
	end)

	local shareBtn = cc.uiloader:seekNodeByName(self._mainNode,"mShareBtn")
	if shareBtn then
		CsbContainer:decorateBtnNoTrans(shareBtn,function()
		
			if device.platform == "android" then
				print("BattleWinView:ctor share")
			    local args = {
			    	BattleWin_Share,
				}
			    local className = "org/cocos2dx/sdk/YoumengSDK"
			    local ok,ret = luaj.callStaticMethod(className, "Youmeng_Share", args, "(I)V")
			    print("Youmeng_Share")
			    if not ok then
			        print("BattleWinView Youmeng_Share error "..ret)
			    end
			end

			if device.platform == "windows" then
				self:shareSuccess()
			end
		end)
	end
	
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
    	mShareGoldLabel = "+"..stageCfg[game.nowStage].shareGold,
	})

	-- 统计关卡_战斗次数_胜利次数
	UserDefaultUtil:recordResult(1,game.nowStage,0)

	addMessage(self, "BattleWinView_VideoSuccess", self.videoSuccess)
	addMessage(self, "BattleWinView_ShareSuccess", self.shareSuccess)
end

-- 观看视频成功的回调
function BattleWinView:videoSuccess()
   	local advBtn = cc.uiloader:seekNodeByName(self._mainNode,"mViewAdvBtn")
   	advBtn:setEnabled(false)
   	CsbContainer:refreshBtnView(advBtn, "pic/anniu_quse.png", "pic/anniu_quse.png")

	CsbContainer:setStringForLabel(self._mainNode, {mGoldLabel = "+"..(FightManager.winGold*2)})
	CsbContainer:setColorForNodes(self._mainNode, {mGoldLabel = cc.c3b(255, 0, 0)})
	game.myGold = game.myGold + FightManager.winGold
	UserDefaultUtil:saveGold()

	-- 统计视频次数
	local jsonStr = json.encode({adv_video={
		type=GameConfig.AdvType.winTwiceCoin,
	}})
    common:javaSaveUserData(jsonStr)
    -- 统计获得金币的地方
    local jsonStrCoin = json.encode({coin_reward={
    	type=GameConfig.AdvType.winTwiceCoin,
		getcoin=FightManager.winGold,
        leftcoin=game.myGold,
	}})
    common:javaSaveUserData(jsonStrCoin)
end

-- 分享成功的回调
function BattleWinView:shareSuccess()
	local shareRewardString = GameConfig.ShareRewardString..stageCfg[game.nowStage].shareGold
	MessagePopView.new(shareRewardString):addTo(self)
	CsbContainer:setNodesVisible(self._mainNode, {mShareNode=false})
	local shareBtn = cc.uiloader:seekNodeByName(self._mainNode,"mShareBtn")
	shareBtn:setEnabled(false)
	CsbContainer:refreshBtnView(shareBtn, "pic/anniu_share_quse.png", "pic/anniu_share_quse.png")
	
   	game.myGold = game.myGold + stageCfg[game.nowStage].shareGold
   	UserDefaultUtil:saveGold()

   	-- 统计获得金币的地方
    local jsonStrCoin = json.encode({coin_reward={
    	type=5, -- 分享获得金币类型
		getcoin=stageCfg[game.nowStage].shareGold,
        leftcoin=game.myGold,
	}})
    common:javaSaveUserData(jsonStrCoin)
end

return BattleWinView