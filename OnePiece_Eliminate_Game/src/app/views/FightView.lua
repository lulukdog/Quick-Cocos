----------------------------------------------------------------------------------
--[[
    FILE:           FightView.lua
    DESCRIPTION:    战斗界面
    AUTHOR:         ZhaoLu
    CREATED:        2016-06-06
--]]
----------------------------------------------------------------------------------
local GameConfig = require("data.GameConfig")
local FightManager = require("app.game.FightManager")
local common = require("app.common")
local scheduler = require("framework.scheduler")

local FightView = class("FightView", function()
    return display.newNode()
end)

function FightView:ctor(gameOverCallback)
  FightManager:init()
  self.gameOverCallback = gameOverCallback
  self._isInShield = false

  self._mainRoleAni = nil
  self._mainRoleNode = nil

  self._mainEffAni = nil
  self._mainEffNode = nil

  self._enemyAni = nil
  self._enemyNode = nil

  self:addMainRole()
  self:addEnemy(FightManager:getNowEnemyCsb())
  self:addEffect()

  addMessage(self, "MAIN_ROLE",self.mainRoleAni)
  addMessage(self, "MAIN_ROLE_COMBO",self.mainRoleComboAni)

  addMessage(self, "ENEMY_ROLE",self.enemyAni)

  addMessage(self, "FIGHTVIEW_CELL_ANI",self.refreshCellAni) -- 连到3个以上身上会闪光
  addMessage(self, "FIGHT_VIEW_EXIT",self.onExit)

end

function FightView:onExit()
	removeMessageByTarget(self)

	self:removeAllChildren()

	self._mainRoleAni = nil
	self._mainRoleNode = nil

	self._enemyAni = nil
	self._enemyNode = nil
end

function FightView:addHelperAni(data)
	print("FightView:addHelperAni")
	local helperNode =cc.CSLoader:createNode(data.csbFile):addTo(self)
	helperNode:setPosition(-100,0)
    local helperAni = cc.CSLoader:createTimeline(data.csbFile)
    helperNode:runAction(helperAni)
    helperAni:gotoFrameAndPlay(GameConfig.MainRole.attack.frameBegin,GameConfig.MainRole.attack.frameEnd,false)
    scheduler.performWithDelayGlobal(function()
    	helperNode:removeFromParent()
	end,(GameConfig.MainRole.attack.frameEnd-GameConfig.MainRole.attack.frameBegin)/GAME_FRAME_RATE)
end

function FightView:addMainRole( )
	print("FightView:addMainRole")
	self._mainRoleNode =cc.CSLoader:createNode("luffy01.csb"):addTo(self)
	self._mainRoleNode:setPosition(-210,0)
    self._mainRoleAni = cc.CSLoader:createTimeline("luffy01.csb")
    self._mainRoleNode:runAction(self._mainRoleAni)
    self._mainRoleAni:gotoFrameAndPlay(GameConfig.MainRole.stand.frameBegin,GameConfig.MainRole.stand.frameEnd,true)
end

-- 玩家攻击特效要在敌人上一层
function FightView:addEffect( )
	print("FightView:addEffect")
	self._mainEffNode =cc.CSLoader:createNode("luffyeff.csb"):addTo(self)
	self._mainEffNode:setPosition(-210,0)
    self._mainEffAni = cc.CSLoader:createTimeline("luffyeff.csb")
    self._mainEffNode:runAction(self._mainEffAni)
    self._mainEffAni:gotoFrameAndPlay(GameConfig.MainRole.stand.frameBegin,GameConfig.MainRole.stand.frameEnd,true)
end

function FightView:addEnemy( enemyCsb )
	print("FightView:addEnemy")
	self._enemyNode = cc.CSLoader:createNode(enemyCsb):addTo(self)
	self._enemyNode:setPosition(210,0)
    self._enemyAni = cc.CSLoader:createTimeline(enemyCsb)
    self._enemyNode:runAction(self._enemyAni)
    self._enemyAni:gotoFrameAndPlay(GameConfig.Enemy.stand.frameBegin,GameConfig.Enemy.stand.frameEnd,true)
end

-- 连到3个以上身上会闪光
function FightView:refreshCellAni( data )
	local cellId,linkCount = data.cellId,data.count
	if FightManager.in_dun_skill==0 then
	  	if linkCount>=3 then
		    self._mainRoleAni:gotoFrameAndPlay(GameConfig.MainRole["cell_ani"..cellId].frameBegin,GameConfig.MainRole["cell_ani"..cellId].frameEnd,true)
	  	else
	      	sendMessage({msg="MAIN_ROLE",aniStr="stand"})
	  	end
  	end
end

-- 防御状态被打不出现被打动画
function FightView:calRoleBeat()
	sendMessage({msg="GAMESCENE_REFRESH_LIFE"})
	if FightManager.lifeNum==0 then
		sendMessage({msg = "MAIN_ROLE",aniStr = "die"})
		return
	end
	FightManager:resetDefNum()
	FightManager:calDun2Skill()
	sendMessage({msg="GAMESCENE_ENABLE"})
	print("role's life is "..FightManager.lifeNum)
end
-- 大盾状态下一直播放大盾动画
function FightView:judgeStandOrShield2()
	if FightManager.in_dun_skill>0 then
		self._mainRoleAni:gotoFrameAndPlay(GameConfig.MainRole.shield2.frameBegin,GameConfig.MainRole.shield2.frameEnd,true)
	else
		self._mainRoleAni:gotoFrameAndPlay(GameConfig.MainRole.stand.frameBegin,GameConfig.MainRole.stand.frameEnd,true)
	end
end
function FightView:mainRoleAni(data)
	local aniStr = data.aniStr
	-- 主角攻击增加回合数，3回合后怪物攻击
	if aniStr~="stand" and aniStr~="beat" and aniStr~="die" and aniStr~="shield2" then
		FightManager:addRound()
	end

	if aniStr=="shield" then
		self._mainRoleNode:runAction(cc.Sequence:create(
			cc.DelayTime:create(0.5),
			cc.CallFunc:create(function()
				print("role's def is "..FightManager.defNum)
				if FightManager:judgeEnemyAttack()==false then
					FightManager:calDun2Skill()
				end
				sendMessage({msg="GAMESCENE_REFRESH_LIFE"})
				if FightManager.in_dun_skill==0 then
					self._mainRoleAni:gotoFrameAndPlay(GameConfig.MainRole[aniStr].frameBegin,GameConfig.MainRole[aniStr].frameEnd,true)
					self._isInShield = true
				end
			end)
		))
	elseif aniStr=="shield2" then
		self._mainRoleNode:runAction(cc.Sequence:create(
			cc.CallFunc:create(function()
				self._mainRoleAni:gotoFrameAndPlay(GameConfig.MainRole[aniStr].frameBegin,GameConfig.MainRole[aniStr].frameEnd,true)
			end),
			cc.DelayTime:create((GameConfig.MainRole[aniStr].frameEnd-GameConfig.MainRole[aniStr].frameBegin)/GAME_FRAME_RATE),
			cc.CallFunc:create(function()
				sendMessage({msg ="GAMESCENE_ENABLE"})
				self:judgeStandOrShield2()
			end)
		))
	elseif aniStr=="shieldBroken" then
		self._mainRoleNode:runAction(cc.Sequence:create(
			cc.CallFunc:create(function()
				print("role's def is "..FightManager.defNum)
				self._mainRoleAni:gotoFrameAndPlay(GameConfig.MainRole[aniStr].frameBegin,GameConfig.MainRole[aniStr].frameEnd,false)
			end),
			cc.DelayTime:create((GameConfig.MainRole[aniStr].frameEnd-GameConfig.MainRole[aniStr].frameBegin)/GAME_FRAME_RATE),
			cc.CallFunc:create(function()
				self:judgeStandOrShield2()
			end)
		))
	elseif aniStr=="shieldBroken2" then
		self._mainRoleNode:runAction(cc.Sequence:create(
			cc.CallFunc:create(function()
				print("role's def is "..FightManager.defNum)
				self._mainRoleAni:gotoFrameAndPlay(GameConfig.MainRole[aniStr].frameBegin,GameConfig.MainRole[aniStr].frameEnd,false)
			end),
			cc.DelayTime:create((GameConfig.MainRole[aniStr].frameEnd-GameConfig.MainRole[aniStr].frameBegin)/GAME_FRAME_RATE),
			cc.CallFunc:create(function()
				self:judgeStandOrShield2()
			end)
		))
	elseif aniStr=="attack" then
		self._mainRoleNode:runAction(cc.Sequence:create(
			cc.DelayTime:create(0.55),
			cc.CallFunc:create(function()
				self._isInShield = false
				self._mainRoleAni:gotoFrameAndPlay(GameConfig.MainRole[aniStr].frameBegin,GameConfig.MainRole[aniStr].frameEnd,false)
				self._mainEffAni:gotoFrameAndPlay(GameConfig.MainRole[aniStr].frameBegin,GameConfig.MainRole[aniStr].frameEnd,false)
			end),
			cc.DelayTime:create((GameConfig.MainRole[aniStr].frameEnd-GameConfig.MainRole[aniStr].frameBegin)/GAME_FRAME_RATE),
			cc.CallFunc:create(function()
				if FightManager:judgeEnemyAttack()==false then
					FightManager:calDun2Skill()
				end
				-- print(" attack stand")
				self:judgeStandOrShield2()
			end)
		))
	elseif aniStr=="attack2" then
		self._mainRoleNode:runAction(cc.Sequence:create(
			cc.DelayTime:create(0.55),
			cc.CallFunc:create(function()
				sendMessage({msg="LUFFIE_TOP_ANI"})
			end),
			cc.DelayTime:create(GameConfig.Attack2AniEnd.luffie/GAME_FRAME_RATE),
			cc.CallFunc:create(function()
				self._isInShield = false
				self._mainRoleAni:gotoFrameAndPlay(GameConfig.MainRole[aniStr].frameBegin,GameConfig.MainRole[aniStr].frameEnd,false)
				self._mainEffAni:gotoFrameAndPlay(GameConfig.MainRole[aniStr].frameBegin,GameConfig.MainRole[aniStr].frameEnd,false)
			end),
			cc.DelayTime:create((GameConfig.MainRole[aniStr].frameEnd-GameConfig.MainRole[aniStr].frameBegin)/GAME_FRAME_RATE),
			cc.CallFunc:create(function()
				if FightManager:judgeEnemyAttack()==false then
					FightManager:calDun2Skill()
				end
				-- print(" attack stand")
				self:judgeStandOrShield2()
			end)
		))
	elseif aniStr=="meat" then
		self._mainRoleNode:runAction(cc.Sequence:create(
			cc.DelayTime:create(0.55),
			cc.CallFunc:create(function()
				self._isInShield = false
				self._mainRoleAni:gotoFrameAndPlay(GameConfig.MainRole[aniStr].frameBegin,GameConfig.MainRole[aniStr].frameEnd,false)
				sendMessage({msg="LINKNUMVIEW_ONCE_END_ANI",aniTag = GameConfig.LinkNum.roleMeat})
			end),
			cc.DelayTime:create((GameConfig.MainRole[aniStr].frameEnd-GameConfig.MainRole[aniStr].frameBegin)/GAME_FRAME_RATE),
			cc.CallFunc:create(function()
				print("role's life is "..FightManager.lifeNum)
				sendMessage({msg="GAMESCENE_REFRESH_LIFE"})
				if FightManager:judgeEnemyAttack()==false then
					FightManager:calDun2Skill()
				end
				-- print("meat stand")
				self:judgeStandOrShield2()
			end)
		))
	elseif aniStr=="beat" then
		if self._isInShield == true or FightManager.in_dun_skill>0 then
			-- 播放破防动画
			if FightManager._onceRoleHarm>0 and FightManager.in_dun_skill==0 then
				sendMessage({msg = "MAIN_ROLE",aniStr = "shieldBroken"})
			elseif FightManager._onceRoleHarm>0 and FightManager.in_dun_skill>0 then
				sendMessage({msg = "MAIN_ROLE",aniStr = "shieldBroken2"})
			end
			self:calRoleBeat()
		else
			self._mainRoleNode:runAction(cc.Sequence:create(
				cc.DelayTime:create(0.55),
				cc.CallFunc:create(function()
					self._mainRoleAni:gotoFrameAndPlay(GameConfig.MainRole[aniStr].frameBegin,GameConfig.MainRole[aniStr].frameEnd,false)
				end),
				cc.DelayTime:create((GameConfig.MainRole[aniStr].frameEnd-GameConfig.MainRole[aniStr].frameBegin)/GAME_FRAME_RATE),
				cc.CallFunc:create(function()
					self:calRoleBeat()
					self:judgeStandOrShield2()
				end)
			))
		end
	elseif aniStr=="stand" then
		self._mainRoleNode:runAction(cc.Sequence:create(
			cc.CallFunc:create(function()
				self:judgeStandOrShield2()
			end)
		))
	elseif aniStr=="die" then
		self._mainRoleNode:runAction(cc.Sequence:create(
			-- cc.DelayTime:create(0.55),
			cc.CallFunc:create(function()
				self._enemyAni:gotoFrameAndPlay(GameConfig.Enemy[aniStr].frameBegin,GameConfig.Enemy[aniStr].frameEnd,false)
				sendMessage({msg="LINKNUMVIEW_ONCE_END_ANI",aniTag = GameConfig.LinkNum.roleBeat})
			end),
			cc.DelayTime:create((GameConfig.Enemy[aniStr].frameEnd-GameConfig.Enemy[aniStr].frameBegin)/GAME_FRAME_RATE),
			cc.CallFunc:create(function()
				print("LOSE")
				sendMessage({msg="GAMESCENE_ENABLE"})
				sendMessage({msg="LOSE"})
			end)
		))
	end
	
end

function FightView:mainRoleComboAni(data)
	local _delayTime = 0.55
	-- 主角攻击增加回合数，3回合后怪物攻击
	FightManager:addRound()

	if common:table_has_value(data.aniTb,"attack2") then
		self._mainRoleNode:runAction(cc.Sequence:create(
				cc.DelayTime:create(_delayTime),
				cc.CallFunc:create(function()
					sendMessage({msg="LUFFIE_TOP_ANI"})
				end),
				cc.DelayTime:create(GameConfig.Attack2AniEnd.luffie/GAME_FRAME_RATE),
				cc.CallFunc:create(function()
					self._isInShield = false
					self._mainRoleAni:gotoFrameAndPlay(GameConfig.MainRole.attack2.frameBegin,GameConfig.MainRole.attack2.frameEnd,false)
					self._mainEffAni:gotoFrameAndPlay(GameConfig.MainRole.attack2.frameBegin,GameConfig.MainRole.attack2.frameEnd,false)
				end)
		))
		_delayTime = _delayTime + (GameConfig.MainRole.attack2.frameEnd-GameConfig.MainRole.attack2.frameBegin)/GAME_FRAME_RATE + GameConfig.Attack2AniEnd.luffie/GAME_FRAME_RATE
	end

	if common:table_has_value(data.aniTb,"meat") then
		self._mainRoleNode:runAction(cc.Sequence:create(
			cc.DelayTime:create(_delayTime),
			cc.CallFunc:create(function()
				print("role's life is "..FightManager.lifeNum)
				self._isInShield = false
				self._mainRoleAni:gotoFrameAndPlay(GameConfig.MainRole.meat.frameBegin,GameConfig.MainRole.meat.frameEnd,false)
				sendMessage({msg="LINKNUMVIEW_ONCE_END_ANI",aniTag = GameConfig.LinkNum.roleMeat})
			end)
		))
		_delayTime = _delayTime + (GameConfig.MainRole.meat.frameEnd-GameConfig.MainRole.meat.frameBegin)/GAME_FRAME_RATE
	end

	self._mainRoleNode:runAction(cc.Sequence:create(
		cc.DelayTime:create(_delayTime),
		cc.CallFunc:create(function()
			-- print("combo stand")
			FightManager:judgeEnemyAttack()
			FightManager:calDun2Skill()
			self:judgeStandOrShield2()
		end)
	))

	if common:table_has_value(data.aniTb,"shield") then
		self._mainRoleNode:runAction(cc.Sequence:create(
			cc.DelayTime:create(_delayTime),
			cc.CallFunc:create(function()
				print("role's def is "..FightManager.defNum)
				if FightManager.in_dun_skill==0 then
					self._isInShield = true
					self._mainRoleAni:gotoFrameAndPlay(GameConfig.MainRole.shield.frameBegin,GameConfig.MainRole.shield.frameEnd,true)
				end
			end)
		))
	end
	
end

function FightView:enemyAni(data)
	local aniStr = data.aniStr

	if aniStr=="attack" then
		self._enemyNode:runAction(cc.Sequence:create(
			cc.DelayTime:create(0.55),
			cc.CallFunc:create(function()
				self._enemyAni:gotoFrameAndPlay(GameConfig.Enemy[aniStr].frameBegin,GameConfig.Enemy[aniStr].frameEnd,false)
				sendMessage({msg="LINKNUMVIEW_ONCE_END_ANI",aniTag = GameConfig.LinkNum.roleBeat})
				-- 怪物被打音效
				FightManager:enemyAttackSound()
			end),
			cc.DelayTime:create((GameConfig.Enemy[aniStr].frameEnd-GameConfig.Enemy[aniStr].frameBegin)/GAME_FRAME_RATE),
			cc.CallFunc:create(function()
				-- sendMessage({msg ="MAIN_ROLE",aniStr = "stand"})
				self._enemyAni:gotoFrameAndPlay(GameConfig.Enemy.stand.frameBegin,GameConfig.Enemy.stand.frameEnd,true)
			end)
		))
	elseif aniStr=="beat" then
		self._enemyNode:runAction(cc.Sequence:create(
			cc.DelayTime:create(0.55),
			cc.CallFunc:create(function()
				self._enemyAni:gotoFrameAndPlay(GameConfig.Enemy[aniStr].frameBegin,GameConfig.Enemy[aniStr].frameEnd,false)
				sendMessage({msg="LINKNUMVIEW_ONCE_END_ANI",aniTag = GameConfig.LinkNum.enemyBeat})
				
			end),
			cc.DelayTime:create((GameConfig.Enemy[aniStr].frameEnd-GameConfig.Enemy[aniStr].frameBegin)/GAME_FRAME_RATE),
			cc.CallFunc:create(function()
				sendMessage({msg="GAMESCENE_REFRESH_LIFE"})
				FightManager:resetAttackNum()
				if FightManager.enemyLife==0 then
					sendMessage({msg = "ENEMY_ROLE",aniStr = "die"})
					return
				end
				print("enemy's life is "..FightManager.enemyLife)
				-- audio.playSound(GAME_SOUND.luffieAttack1)
				self._enemyAni:gotoFrameAndPlay(GameConfig.Enemy.stand.frameBegin,GameConfig.Enemy.stand.frameEnd,true)
			end)
		))
		scheduler.performWithDelayGlobal(function()
			-- 怪物被打音效
			FightManager:enemyBeatSound()
		end,1.2)
	elseif aniStr=="beat2" then
		self._enemyNode:runAction(cc.Sequence:create(
			cc.DelayTime:create(0.55),
			cc.DelayTime:create(GameConfig.Attack2AniEnd.luffie/GAME_FRAME_RATE),
			cc.CallFunc:create(function()
				self._enemyAni:gotoFrameAndPlay(GameConfig.Enemy[aniStr].frameBegin,GameConfig.Enemy[aniStr].frameEnd,false)
				sendMessage({msg="LINKNUMVIEW_ONCE_END_ANI",aniTag = GameConfig.LinkNum.enemyBeat2})
				sendMessage({msg="GAMESCENE_COMBO_ANI"})
			end),
			cc.DelayTime:create((GameConfig.Enemy[aniStr].frameEnd-GameConfig.Enemy[aniStr].frameBegin)/GAME_FRAME_RATE),
			cc.CallFunc:create(function()
				sendMessage({msg="GAMESCENE_REFRESH_LIFE"})
				FightManager:resetAttackNum()
				if FightManager.enemyLife==0 then
					sendMessage({msg = "ENEMY_ROLE",aniStr = "die"})
					return
				end
				print("enemy's life is "..FightManager.enemyLife)
				self._enemyAni:gotoFrameAndPlay(GameConfig.Enemy.stand.frameBegin,GameConfig.Enemy.stand.frameEnd,true)
			end)
		))
		scheduler.performWithDelayGlobal(function()
			-- 怪物被打音效
			FightManager:enemyBeatSound()
		end,2.6)
	elseif aniStr=="die" then
		FightManager:beatOneEnemy()
		self._enemyNode:runAction(cc.Sequence:create(
			-- cc.DelayTime:create(0.55),
			cc.CallFunc:create(function()
				self._enemyAni:gotoFrameAndPlay(GameConfig.Enemy[aniStr].frameBegin,GameConfig.Enemy[aniStr].frameEnd,false)
				sendMessage({msg="LINKNUMVIEW_ONCE_END_ANI",aniTag = GameConfig.LinkNum.enemyLose})
			end),
			cc.DelayTime:create((GameConfig.Enemy[aniStr].frameEnd-GameConfig.Enemy[aniStr].frameBegin)/GAME_FRAME_RATE),
			cc.CallFunc:create(function()
				local nowEnemyCsb = FightManager:getNowEnemyCsb()
				if nowEnemyCsb~=nil then
					scheduler.performWithDelayGlobal(function()
						FightManager:refreshRoundAndLife()
						self._enemyNode:removeFromParent()
						self:addEnemy(nowEnemyCsb)
						FightManager:changeFightBg()
						sendMessage({msg ="GAMESCENE_ENABLE"})
					end, 0.2)
				else
					FightManager:refreshRoundAndLife()
					-- 战斗胜利计算星星数和获得经验
					FightManager:calStarAndExp()
					print("WIN")
					sendMessage({msg="WIN"})
				end
			end)
		))
	end
	
end

return FightView