----------------------------------------------------------------------------------
--[[
    FILE:           LinkNumView.lua
    DESCRIPTION:    战斗界面
    AUTHOR:         ZhaoLu
    CREATED:        2016-06-06
--]]
----------------------------------------------------------------------------------
local FightManager = require("app.game.FightManager")
local GameConfig = require("data.GameConfig")

local LinkNumView = class("LinkNumView", function()
    return display.newNode()
end)

function LinkNumView:ctor(gameOverCallback)

    self._mainRoleAni = nil
    self._mainRoleNode = nil

    self._enemyAni = nil
    self._enemyNode = nil

    self:addMainRole()
    self:addEnemy()

    addMessage(self, "LINKNUMVIEW_REFRESH_HARM",self.refreshHarm)
    addMessage(self, "LINKNUMVIEW_ONCE_END_ANI",self.runEndAni)
    addMessage(self, "LINKNUMVIEW_HIDE",self.hideAllNode)

    addMessage(self, "LINK_NUM_VIEW_EXIT",self.onExit)

end

function LinkNumView:addMainRole( )
    print("LinkNumView:addMainRole")
    self._mainRoleNode =cc.CSLoader:createNode("LinkNum.csb"):addTo(self)
    self._mainRoleNode:setPosition(-200,0)
    self._mainRoleAni = cc.CSLoader:createTimeline("LinkNum.csb")
    self._mainRoleNode:runAction(self._mainRoleAni)
end

function LinkNumView:addEnemy( )
    print("LinkNumView:addEnemy")
    self._enemyNode = cc.CSLoader:createNode("LinkNum.csb"):addTo(self)
    self._enemyNode:setPosition(300,0)
    self._enemyAni = cc.CSLoader:createTimeline("LinkNum.csb")
    self._enemyNode:runAction(self._enemyAni)
    self:hideAllNode()
end

function LinkNumView:hideAllNode(data)
    self._enemyAni:gotoFrameAndPlay(0,1,true)
    self._mainRoleAni:gotoFrameAndPlay(0,1,true)
end
function LinkNumView:enemyNormalHarmAni()
  self._enemyAni:gotoFrameAndPlay(113,114,true)
end
function LinkNumView:enemyBigHarmAni()
  self._enemyAni:gotoFrameAndPlay(118,131,true)
end
function LinkNumView:enemyEndHarmAni()
  self._enemyAni:gotoFrameAndPlay(61,111,false)
end
function LinkNumView:enemyLoseAni()
  self._enemyAni:gotoFrameAndPlay(1,60,false)
end
function LinkNumView:roleEndHarmAni()
  self._mainRoleAni:gotoFrameAndPlay(61,111,false)
end
function LinkNumView:roleMeatAni()
  self._mainRoleAni:gotoFrameAndPlay(133,134,true)
end
function LinkNumView:roleMeatEndAni()
  self._mainRoleAni:gotoFrameAndPlay(136,152,false)
end

-- 连接的同时刷新伤害值
function LinkNumView:refreshHarm(data)
  cellId,linkCount = data.cellId,data.count
  if linkCount>=3 and cellId>=1 and cellId<=4 then
      self:enemyNormalHarmAni()
      if linkCount>=6 then
          self:enemyBigHarmAni()
      end
      local harmNum =  FightManager:calLinkHarm( cellId,linkCount )
      CsbContainer:setStringForLabel(self._enemyNode, {
          mNormalLabel = harmNum,
          mBigLabel = harmNum,
      })
  elseif linkCount>=3 and cellId==6 then
      self:roleMeatAni()
      CsbContainer:setStringForLabel(self._mainRoleNode, {
          mMeatLabel = FightManager:calLinkMeat( linkCount ),
      })
  else
      self:hideAllNode()
  end

end

-- 连接结束后，播放动作时弹出的伤害动画
function LinkNumView:runEndAni( data )
    local _tag = data.aniTag
    if _tag==GameConfig.LinkNum.enemyBeat then
        self:enemyEndHarmAni()
        CsbContainer:setStringForLabel(self._enemyNode, {mEndLabel = FightManager._onceEnemyHarm})
    elseif _tag==GameConfig.LinkNum.enemyLose then
        self:enemyLoseAni()
        CsbContainer:setStringForLabel(self._enemyNode, {mEndLabel = FightManager._onceEnemyHarm})
    elseif _tag==GameConfig.LinkNum.roleBeat then
        self:roleEndHarmAni()
        CsbContainer:setStringForLabel(self._mainRoleNode, {mEndLabel = FightManager._onceRoleHarm})
    elseif _tag==GameConfig.LinkNum.roleMeat then
        self:roleMeatEndAni()
        CsbContainer:setStringForLabel(self._mainRoleNode, {mMeatEndLabel = FightManager._onceRoleMeat})
    end
end

function LinkNumView:onExit()
    removeMessageByTarget(self)

    self:removeAllChildren()
    self._mainRoleAni = nil
    self._mainRoleNode = nil

    self._enemyAni = nil
    self._enemyNode = nil
end

return LinkNumView