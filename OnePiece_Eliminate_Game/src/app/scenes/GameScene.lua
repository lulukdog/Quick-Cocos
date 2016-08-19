----------------------------------------------------------------------------------
--[[
    FILE:           GameScene.lua
    DESCRIPTION:    游戏主场景
    AUTHOR:         ZhaoLu
    CREATED:        2016-06-01 
--]]
----------------------------------------------------------------------------------

local BoardView  = import("..views.BoardView")
local PauseView = import("..views.PauseView")
local FightView = import("..views.FightView")
local BattleWinView = import("..views.BattleWinView")
local BattleFailPopView = import("..views.BattleFailPopView")
local FightManager = import("..game.FightManager")
local SelectHelperView = import("..views.SelectHelperView")
local LinkNumView = import("..views.LinkNumView")
local TopAniView = import("..views.TopAniView")
local GuideView = import("..views.GuideView")
local GuideFingerView = import("..views.GuideFingerView")
local GuideFingerPushView = import("..views.GuideFingerPushView")
local StoryView = import("..views.StoryView")
local CostConfirmView = import("..views.CostConfirmView")
local BigSkillPreView = import("..views.BigSkillPreView")

local common = import("app.common")

local helperCfg = require("data.data_helper")
local GameConfig = require("data.GameConfig")
local cellCfg = require("data.data_eliminate")
local stageCfg = require("data.data_stage")
local scheduler = require("framework.scheduler")


local GameScene = class("GameScene", function()
    return display.newScene("GameScene")
end)

function GameScene:ctor()
    self._mainNode = CsbContainer:createCsb("GameScene.csb"):addTo(self)
    self._mainAni = cc.CSLoader:createTimeline("GameScene.csb")
    self._mainNode:runAction(self._mainAni)

    self._roleLastLife = -1 -- 自己上一次的血量
    self._enemyLastLife = -1 -- 敌人上一次的血量

    addMessage(self, "WIN",self.pushWinPage)
    addMessage(self, "LOSE",self.pushLosePage)
    addMessage(self, "GameScene_pushBigSkillPreView",self.pushBigSkillPreView)

    addMessage(self, "GAMESCENE_REFRESH_LIFE",self.refreshLife)
    addMessage(self, "GAMESCENE_REFRESH_ROUND",self.refreshRound)
    addMessage(self, "GAMESCENE_REFRESH_LEFTNUM",self.refreshLeftNum)
    addMessage(self, "GAMESCENE_COMBO_ANI",self.runComboAni)
    addMessage(self, "GameScene_LongLinkAni",self.longLinkAni)
    addMessage(self, "GameScene_NoLinkTip",self.noLinkTip)
    addMessage(self, "GameScene_BigSkillAni",self.bigSkillAni)

    addMessage(self, "GAMESCENE_REFRESH_HELPER",self.refreshHelper)
    addMessage(self, "GAMESCENE_CHANGE_FIGHTBG",self.refreshFightBg)

    addMessage(self, "GAMESCENE_ENABLE",self.gameEnable)
    addMessage(self, "GAMESCENE_DISABLE",self.gameDisable)
    addMessage(self, "GameScene_PauseEnable",self.pauseEnable)
    addMessage(self, "GameScene_PauseDisable",self.pauseDisable)

    addMessage(self, "StoryView_Exit",self.storyViewExit)

    self.boardView = BoardView.new(handler(self, self.gameOverCallback))
    self.boardView:setPosition(0, 130)
    local _bottomNode = cc.uiloader:seekNodeByTag(self._mainNode,2)
    if _bottomNode then
      self.boardView:addTo(_bottomNode)
    end

    -- 界面按钮初始化
    self:createHub()

    self.pauseView = PauseView.new(handler(self, self.gameResume))
    self.pauseView:addTo(self)

    self.fightView = FightView.new(handler(self, self.gameOverCallback))
    local _fightViewNode = cc.uiloader:seekNodeByName(self._mainNode,"mFightViewNode")
    if _fightViewNode then
        self.fightView:addTo(_fightViewNode)
    end

    self.linkNumView = LinkNumView.new(handler(self, self.gameOverCallback))
    local _linkNumNode = cc.uiloader:seekNodeByName(self._mainNode,"mLinkNumNode")
    if _linkNumNode then
        self.linkNumView:addTo(_linkNumNode)
    end

    self.TopAniView = TopAniView.new()
    local _topAniNode = cc.uiloader:seekNodeByName(self._mainNode,"AniTopNode")
    if _topAniNode then
        self.TopAniView:addTo(_topAniNode)
    end

    -- 剧情
    if stageCfg[game.nowStage].storyId~=nil then
        StoryView.new():addTo(self)
    else
        self:guideStep()
    end

    -- 如果第一次进来播动画
    if game.firstEnterGame==true then
        local _movieNode = CsbContainer:createPushCsb("lufyymutou.csb"):addTo(self)
        local _moveAni = cc.CSLoader:createTimeline("lufyymutou.csb")
        _movieNode:runAction(_moveAni)
        _moveAni:gotoFrameAndPlay(0,220,false)
        scheduler.performWithDelayGlobal(function()
            game.firstEnterGame = false
            UserDefaultUtil:saveFirstGame()
            _movieNode:removeFromParent()
        end,220/GAME_FRAME_RATE)
    end

    self:refreshLife()
    self:refreshRound()
    self:refreshLeftNum()
    self:refreshHelper()
    self:refreshGoal()

    -- 统计关卡_战斗次数_胜利次数
    common:javaSaveUserData("NowStage",tostring(game.nowStage))

    game.needPlayAd = true
end

-- 没有可滑物块提示
function GameScene:noLinkTip( )
    MessagePopView.new(9):addTo(self)
end

-- 长连的时候背后的火焰动画
function GameScene:longLinkAni( data)
    local _flag = data.showFlag
    if _flag==true then
        self._mainAni:gotoFrameAndPlay(100,129,true)
    else
        self._mainAni:gotoFrameAndPlay(0,1,true)
    end
end
-- 主角大招屏幕晃动
function GameScene:runComboAni( )
    self._mainAni:gotoFrameAndPlay(0,85,false)
end
-- 战斗胜利弹窗
function GameScene:pushWinPage()
  BattleWinView.new():addTo(self)
end
-- 战斗失败弹窗
function GameScene:pushLosePage()
  BattleFailPopView.new():addTo(self)
end
-- 大招确定弹窗
function GameScene:pushBigSkillPreView(data)
    print("GameScene:pushBigSkillPreView"..data.tag)
    BigSkillPreView.new(data.tag):addTo(self)
end
-- 刷新战斗背景
function GameScene:refreshFightBg(data)
    local _picPath = data.bgPic
    CsbContainer:setSpritesPic(self._mainNode, {
        background = _picPath
    })
end
-- 刷新战斗目标
function GameScene:refreshGoal()
    local _goalId = FightManager:getGoalId()
    if _goalId~=0 then
        CsbContainer:setSpritesPic(self._mainNode, {
            mGoalPic = cellCfg[_goalId].icon
        })
    end
end

-- 刷新帮助角色
function GameScene:refreshHelper()
  -- 可以出战的角色
  local helperTb = {}
  for i=2,#game.helper do
    if game.helper[i]~=0 then
      table.insert(helperTb,i)
    end
  end

  for i=1,2 do
    CsbContainer:setNodesVisible(self._mainNode,{
      ["mHasHelperBtn"..i] = game.helperOnFight[i]~=nil,
      ["mHelperBtn"..i] = game.helperOnFight[i]==nil,
    })
    if game.helperOnFight[i]~=nil then
      local helperBtn = cc.uiloader:seekNodeByName(self._mainNode,"mHasHelperBtn"..i)
      local pic = GameConfig.HasHelperPic[game.helperOnFight[i]]
      CsbContainer:refreshBtnView(helperBtn,pic,pic)
    elseif game.helperOnFight[i]==nil and i<=#helperTb then
      local helperBtn = cc.uiloader:seekNodeByName(self._mainNode,"mHelperBtn"..i)
      local normalPic = GameConfig.HelperPic.normal
      local selectPic = GameConfig.HelperPic.selected
      CsbContainer:refreshBtnView(helperBtn,normalPic,selectPic)
      helperBtn:setEnabled(true)
    elseif game.helperOnFight[i]==nil and i>#helperTb then
      local helperBtn = cc.uiloader:seekNodeByName(self._mainNode,"mHelperBtn"..i)
      local pic = GameConfig.HelperPic.notAble
      CsbContainer:refreshBtnView(helperBtn,pic)
      helperBtn:setEnabled(false)
    end

  end

end

-- 新手引导
function GameScene:guideStep( )
    if game.guideStep<=game.MAXGUIDESTEP then
        if game.nowStage<=2 or game.nowStage==9 then
            GuideView.new():addTo(self)
        elseif game.nowStage==5 then 
            GuideFingerView.new():addTo(self)
        elseif game.guideStep==16 then
            GuideFingerPushView.new():addTo(self)
        end
    end
end
-- 剧情结束后如果有引导走引导
function GameScene:storyViewExit()
    self:guideStep()
end

-- 大招需要购买
function BigSkill_callback(result)
  print("BigSkill_callback"..result)
  if result ~= "fail" then
      if tonumber(result)/100 == 5 then
          sendMessage({msg="GameScene_pushBigSkillPreView",tag=GameConfig.BigSkillCfg.bombAll})
      else
          sendMessage({msg="GameScene_pushBigSkillPreView",tag=GameConfig.BigSkillCfg.freezeRound})
      end
  end
end

function GameScene:bigSkillAni(data)
    if data.tag == GameConfig.BigSkillCfg.bombAll then
        self.boardView:onSkillBombAll()
    else
        game.skillFreezeRound = game.FREEZEROUND
    end
end
function GameScene:createHub()
    -- 暂停按钮
    local pauseButton = cc.uiloader:seekNodeByName(self._mainNode,"pauseBtn")
    CsbContainer:decorateBtn(pauseButton,function()
        self:gamePause()
        self.pauseView:open()
    end)

    -- 呼叫帮忙按钮
    for i=1,2 do
      local helperBtn = cc.uiloader:seekNodeByName(self._mainNode,"mHelperBtn"..i)
      CsbContainer:decorateBtnNoTrans(helperBtn,function()
          SelectHelperView.new(true):addTo(self)
      end)
    end
    -- 有人物的帮忙按钮
    for i=1,2 do
      local helperBtn = cc.uiloader:seekNodeByName(self._mainNode,"mHasHelperBtn"..i)
      CsbContainer:decorateBtn(helperBtn,function()
          if game.guideStep==16 then
              sendMessage({msg="GuideFingerPushView_onNext"})
          end 
          self:onHelper(i)
      end)
    end
    -- 消除全部的大招技能，和冰冻住回合数的技能
    local _skillBombAllBtn = cc.uiloader:seekNodeByName(self._mainNode,"mSkillBombAllBtn")
    CsbContainer:decorateBtn(_skillBombAllBtn,function()
        if device.platform == "android" then
            CostConfirmView.new(GameConfig.BigSkillCfg.bombAllTip,function()
                common:javaOnUseMoney(BigSkill_callback,GameConfig.BigSkillCfg.bombAllCost*100)
            end,GameConfig.BigSkillCfg.bombAllCost):addTo(self)
        end
        
        if device.platform == "windows" then
            CostConfirmView.new(GameConfig.BigSkillCfg.bombAllTip,function()
                -- 炸弹技能
                local data = {tag=GameConfig.BigSkillCfg.bombAll}
                BigSkillPreView.new(data.tag):addTo(self)
            end,GameConfig.BigSkillCfg.bombAllCost):addTo(self)
        end
    end)

    local _freezeRoundBtn = cc.uiloader:seekNodeByName(self._mainNode,"mFreezeRoundBtn")
    CsbContainer:decorateBtn(_freezeRoundBtn,function()
        if device.platform == "android" then
            CostConfirmView.new(GameConfig.BigSkillCfg.freezeRoundTip,function()
                common:javaOnUseMoney(BigSkill_callback,GameConfig.BigSkillCfg.freezeRoundCost*100)
            end,GameConfig.BigSkillCfg.freezeRoundCost):addTo(self)
        end

        if device.platform=="windows" then
            CostConfirmView.new(GameConfig.BigSkillCfg.freezeRoundTip,function()
                -- 冻结3回合技能
                local data = {tag=GameConfig.BigSkillCfg.freezeRound}
                BigSkillPreView.new(data.tag):addTo(self)
            end,GameConfig.BigSkillCfg.freezeRoundCost):addTo(self)
        end
    end)
    -- boss回合数按钮和boss对应的cellId按钮
    local _roundBtn = cc.uiloader:seekNodeByName(self._mainNode,"mBossRoundBtn")
    local _cellBtn = cc.uiloader:seekNodeByName(self._mainNode,"mEnemyAttrBtn")
    CsbContainer:setNodesVisible(self._mainNode, {
        mEnemyIdNode = false,
        mEnemyRoundNode = false,
    })
    _roundBtn:addTouchEventListener(function(sender,eventType)
        if eventType==ccui.TouchEventType.began then
            CsbContainer:setNodesVisible(self._mainNode, {
                mEnemyRoundNode = true,
            })
            return true
        elseif eventType==ccui.TouchEventType.ended or eventType==ccui.TouchEventType.canceled then
            print("ended")
            CsbContainer:setNodesVisible(self._mainNode, {
                mEnemyRoundNode = false,
            })
        end
    end)
    _cellBtn:addTouchEventListener(function(sender,eventType)
        if eventType==ccui.TouchEventType.began then
            CsbContainer:setSpritesPic(self._mainNode,{
                mAttrSprite = GameConfig.EnemyTypeDes[FightManager:getEnemyAttr()]
            })
            CsbContainer:setNodesVisible(self._mainNode, {
                mEnemyIdNode = true,
            })
            return true
        elseif eventType==ccui.TouchEventType.ended or eventType==ccui.TouchEventType.canceled then
            CsbContainer:setNodesVisible(self._mainNode, {
                mEnemyIdNode = false,
            })
        end
    end)
end

-- 角色帮助按钮
function GameScene:onHelper( btnNum )
  print("GameScene:onHelper call helper to fight")
  FightManager:calHelperNum( btnNum )
  FightManager:runHelperAni( btnNum )
  table.remove(game.helperOnFight,btnNum)
  self:refreshHelper()
end

-- 刷新敌人和自己的血量
function GameScene:refreshLife()
  CsbContainer:setStringForLabel(self._mainNode,{
    mainRoleHpLabel = FightManager.lifeNum.."/"..FightManager:getNowRoleMaxLife(),
    enemyHpLabel = FightManager.enemyLife.."/"..FightManager:getNowEnemyMaxLife(),
  })

  -- 玩家血量
  local mainRoleLifeBar = cc.uiloader:seekNodeByName(self._mainNode,"mainRoleHpPro")
  local mainRoleLifePer = math.max((FightManager.lifeNum/FightManager:getNowRoleMaxLife())*100,0)
  mainRoleLifePer = math.min(mainRoleLifePer,100)
  mainRoleLifeBar:setPercent(mainRoleLifePer)

  -- 敌人血量
  local enemyLifeBar = cc.uiloader:seekNodeByName(self._mainNode,"enemyHpPro")
  local enemyLifePer = math.max((FightManager.enemyLife/FightManager:getNowEnemyMaxLife())*100,0)
  enemyLifePer = math.min(enemyLifePer,100)
  enemyLifeBar:setPercent(enemyLifePer)

  -- 减血动画
  if self._roleLastLife~=-1 and self._roleLastLife>FightManager.lifeNum then
      local _lastPer = math.max((self._roleLastLife/FightManager:getNowRoleMaxLife())*100,0)
      _lastPer = math.min(_lastPer,100)
      local _beginF,_endF = math.floor((100-_lastPer)*0.5)+260, math.floor((100-mainRoleLifePer)*0.5)+260
      self._mainAni:gotoFrameAndPlay(_beginF,_endF,false)
  end
  
  if self._enemyLastLife~=-1 and self._enemyLastLife>FightManager.enemyLife then
      local _lastPer = math.max((self._enemyLastLife/FightManager:getNowEnemyMaxLife())*100,0)
      _lastPer = math.min(_lastPer,100)
      local _beginF,_endF = math.floor((100-_lastPer)*0.5)+150, math.floor((100-enemyLifePer)*0.5)+150
      self._mainAni:gotoFrameAndPlay(_beginF,_endF,false)
  end
  self._roleLastLife = FightManager.lifeNum -- 自己上一次的血量
  self._enemyLastLife = FightManager.enemyLife -- 敌人上一次的血量
end

--刷新回合数，敌人死后刷新敌人类型
function GameScene:refreshRound()
  CsbContainer:setStringForLabel(self._mainNode,{
    roundLabel = FightManager:getLeftRound(),
  })
  -- 刷新敌人的属性
  local _cellBtn = cc.uiloader:seekNodeByName(self._mainNode,"mEnemyAttrBtn")
  if FightManager:getEnemyAttr()==0 then
      _cellBtn:setVisible(false)
  else
      _cellBtn:setVisible(true)
      CsbContainer:refreshBtnView(_cellBtn, GameConfig.EnemyAttrPic[FightManager:getEnemyAttr()], GameConfig.EnemyAttrPic[FightManager:getEnemyAttr()])
  end
  
end
-- 刷新怪或是收集物剩余数量
function GameScene:refreshLeftNum()
    CsbContainer:setStringForLabel(self._mainNode,{
        mGoalText = "x "..FightManager:getGoalLeftNum()
    })
end

function GameScene:gamePause()
  -- body
  self.boardView:gamePause()
end

function GameScene:gameResume()
  -- body
   self.boardView:gameResume()
end

-- 遮罩滑动区域，帮助玩家，暂停按钮
function GameScene:gameEnable()
    CsbContainer:setNodesVisible(self._mainNode, {
        mNotouch = false,
        mNotouch2 = false,
    })
end
function GameScene:gameDisable()
    CsbContainer:setNodesVisible(self._mainNode, {
        mNotouch = true,
        mNotouch2 = true,
    })
end

-- 遮住暂停按钮防止bug
function GameScene:pauseEnable()
    CsbContainer:setNodesVisible(self._mainNode, {
        mNotouch2 = false,
    })
end
function GameScene:pauseDisable()
    CsbContainer:setNodesVisible(self._mainNode, {
        mNotouch2 = true,
    })
end

function GameScene:onExit()
  sendMessage({msg ="FIGHT_VIEW_EXIT"})
  sendMessage({msg ="BOARVIEW_EXIT"})
  sendMessage({msg ="LINK_NUM_VIEW_EXIT"})
  sendMessage({msg ="TOPANI_VIEW_EXIT"})

  game.helperOnFight = {}

  removeMessageByTarget(self)
end

return GameScene
