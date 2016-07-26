----------------------------------------------------------------------------------
--[[
    FILE:           MapDetailView.lua
    DESCRIPTION:    
    AUTHOR:         ZhaoLu
    CREATED:        2016-06-06 
--]]
----------------------------------------------------------------------------------
local SelectHelperView = import(".SelectHelperView")
local CommonConfirmView = import(".CommonConfirmView")
local BuyEnergyView = import(".BuyEnergyView")

local FightManager = import("..game.FightManager")
local stageCfg = require("data.data_stage")
local stageMapCfg = require("data.data_stagemap")
local cellCfg = require("data.data_eliminate")
local monsterCfg = require("data.data_monster")
local GameConfig = require("data.GameConfig")

local common = require("app.common")

local MapDetailView = class("MapDetailView", function()
    return display.newNode()
end)

function MapDetailView:ctor()

	self._mainNode = CsbContainer:createPushCsb("MapDetail.csb"):addTo(self)

	local startBtn = cc.uiloader:seekNodeByName(self._mainNode,"mFightBtn")
	CsbContainer:decorateBtnNoTrans(startBtn,function()
		for i,v in ipairs(game.helper) do
			if i>1 and v~=0 then
				SelectHelperView.new(false):addTo(self)
				return
			end
		end
		
		if common:energyIsEnough(5) then
			app:enterScene("GameScene", nil, "fade", 0.6, display.COLOR_WHITE)
		else
			CommonConfirmView.new(GameConfig.NotEnoughEnergy,function()
				BuyEnergyView.new():addTo(self)
			end):addTo(self)
		end
	end)

    local closeBtn = cc.uiloader:seekNodeByName(self._mainNode,"mCloseBtn")
    CsbContainer:decorateBtn(closeBtn,function()
		self:removeFromParent()
		
		self._mainNode = nil
	end)

    CsbContainer:setStringForLabel(self._mainNode, {
    	mStageLabel = string.format("%03d",game.nowStage),
    })

    self:refreshPage()
end

function MapDetailView:refreshPage()
	local mapTb = common:parseStrOnlyWithComma(stageCfg[game.nowStage].stageMap)
	local _goalId,_goalCount = FightManager:getGoalId()
	local _goalIcon,_goalDes = "shoujiwu_01_item.png",1
	if _goalId~=0 then
		_goalIcon = cellCfg[_goalId].icon
		_goalDes = 2
	end
	CsbContainer:setSpritesPic(self._mainNode, {
		mBgSprite = stageMapCfg[tonumber(mapTb[1])].picPath,
		mGoalSprite = _goalIcon
	})
	CsbContainer:setStringForLabel(self._mainNode, {
		mGoalWordLabel = GameConfig.StageGoalDes[_goalDes],
		mGoalNumabel = "x".._goalCount,
	})

	-- 添加人物动画
	local _aniNode = cc.uiloader:seekNodeByName(self._mainNode, "mRoleAniNode")
	if _aniNode then
		-- 添加主角
		local roleNode =cc.CSLoader:createNode("luffy01.csb"):addTo(_aniNode)
		roleNode:setPosition(-180,0)
	    local roleAni = cc.CSLoader:createTimeline("luffy01.csb")
	    roleNode:runAction(roleAni)
	    roleAni:gotoFrameAndPlay(GameConfig.MainRole.stand.frameBegin,GameConfig.MainRole.stand.frameEnd,true)

	    -- 添加敌人
	    local nowMonsterTb = common:parseStrOnlyWithComma(stageCfg[game.nowStage].monsterId)
	    local nowEnemyCsb = monsterCfg[tonumber(nowMonsterTb[1])].csb 
	    local enemyNode = cc.CSLoader:createNode(nowEnemyCsb):addTo(_aniNode)
		enemyNode:setPosition(180,0)
	    local enemyAni = cc.CSLoader:createTimeline(nowEnemyCsb)
	    enemyNode:runAction(enemyAni)
	    enemyAni:gotoFrameAndPlay(GameConfig.Enemy.stand.frameBegin,GameConfig.Enemy.stand.frameEnd,true)
	end
end

return MapDetailView