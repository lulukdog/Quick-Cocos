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

    addMessage(self, "WIN",self.pushWinPage)
    addMessage(self, "LOSE",self.pushLosePage)

    addMessage(self, "GAMESCENE_REFRESH_LIFE",self.refreshLife)
    addMessage(self, "GAMESCENE_REFRESH_ROUND",self.refreshRound)
    addMessage(self, "GAMESCENE_REFRESH_LEFTNUM",self.refreshLeftNum)

    addMessage(self, "GAMESCENE_REFRESH_HELPER",self.refreshHelper)
    addMessage(self, "GAMESCENE_CHANGE_FIGHTBG",self.refreshFightBg)

    addMessage(self, "GAMESCENE_ENABLE",self.gameEnable)
    addMessage(self, "GAMESCENE_DISABLE",self.gameDisable)

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
end

-- 战斗胜利弹窗
function GameScene:pushWinPage()
  BattleWinView.new():addTo(self)
end
-- 战斗失败弹窗
function GameScene:pushLosePage()
  BattleFailPopView.new():addTo(self)
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

  for i=1,4 do
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

function GameScene:createHub()
    -- 暂停按钮
    local pauseButton = cc.uiloader:seekNodeByName(self._mainNode,"pauseBtn")
    CsbContainer:decorateBtn(pauseButton,function()
        self:gamePause()
        self.pauseView:open()
    end)

    -- 呼叫帮忙按钮
    for i=1,4 do
      local helperBtn = cc.uiloader:seekNodeByName(self._mainNode,"mHelperBtn"..i)
      CsbContainer:decorateBtnNoTrans(helperBtn,function()
          SelectHelperView.new(true):addTo(self)
      end)
    end
    -- 有人物的帮忙按钮
    for i=1,4 do
      local helperBtn = cc.uiloader:seekNodeByName(self._mainNode,"mHasHelperBtn"..i)
      CsbContainer:decorateBtn(helperBtn,function()
          if game.guideStep==16 then
              sendMessage({msg="GuideFingerPushView_onNext"})
          end 
          self:onHelper(i)
      end)
    end
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
  --TODO
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
      CsbContainer:refreshBtnView(_cellBtn, cellCfg[FightManager:getEnemyAttr()].icon, cellCfg[FightManager:getEnemyAttr()].icon)
  end
  
end
-- 刷新怪或是收集物剩余数量
function GameScene:refreshLeftNum()
    CsbContainer:setStringForLabel(self._mainNode,{
        mGoalText = FightManager:getGoalLeftNum()
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

function GameScene:onExit()
  sendMessage({msg ="FIGHT_VIEW_EXIT"})
  sendMessage({msg ="BOARVIEW_EXIT"})
  sendMessage({msg ="LINK_NUM_VIEW_EXIT"})
  sendMessage({msg ="TOPANI_VIEW_EXIT"})

  game.helperOnFight = {}

  removeMessageByTarget(self)
end

return GameScene
