----------------------------------------------------------------------------------
--[[
    FILE:           TopAniView.lua
    DESCRIPTION:    
    AUTHOR:         ZhaoLu
    CREATED:        2016-06-24 
--]]
----------------------------------------------------------------------------------
local GameConfig = require("data.GameConfig")
local scheduler = require("framework.scheduler")

local TopAniView = class("TopAniView", function()
    return display.newNode()
end)

function TopAniView:ctor()

	self._mainNode = nil
    self._mainAni = nil

    self:addLuffieBlink()

    addMessage(self, "LUFFIE_TOP_ANI",self.luffieAni)
    addMessage(self, "HELPER_ANI",self.addHelperAni)

    addMessage(self, "TOPANI_VIEW_EXIT",self.onExit)
end

-- 路飞大招特效要在敌人上一层
function TopAniView:addLuffieBlink( )
    print("TopAniView:addLuffieBlink")
    self._mainNode =cc.CSLoader:createNode("luffieAttack2.csb"):addTo(self)
    self._mainNode:setPosition(0,-220)
    self._mainAni = cc.CSLoader:createTimeline("luffieAttack2.csb")
    self._mainNode:runAction(self._mainAni)
    self._mainNode:setVisible(false)
end

function TopAniView:luffieAni()
    self._mainNode:runAction(cc.Sequence:create(
        cc.CallFunc:create(function()
            self._mainNode:setVisible(true)
            self._mainAni:gotoFrameAndPlay(0,GameConfig.Attack2AniEnd.luffie,false)
        end),
        cc.DelayTime:create(GameConfig.Attack2AniEnd.luffie/GAME_FRAME_RATE),
        cc.CallFunc:create(function()
            self._mainNode:setVisible(false)
        end)
    ))
end

function TopAniView:addHelperAni(data)
    print("TopAniView:addHelperAni")
    sendMessage({msg="GAMESCENE_DISABLE"})
    local helperNode =cc.CSLoader:createNode(data.csbFile):addTo(self)
    helperNode:setPosition(0,-250)
    local helperAni = cc.CSLoader:createTimeline(data.csbFile)
    helperNode:runAction(helperAni)
    helperAni:gotoFrameAndPlay(0,GameConfig.Attack2AniEnd.zoro,false)
    helperAni:setFrameEventCallFunc(function(frame)
        local event = frame:getEvent() 
        print("TopAniView:addHelperAni **** " .. event)
        if frame:getEvent()=="beatAni" then           
            sendMessage({msg ="ENEMY_ROLE",aniStr = "beat"})
        elseif frame:getEvent()=="shieldAni" then
            sendMessage({msg ="MAIN_ROLE",aniStr = "shield2"})
        elseif frame:getEvent()=="meatAni" then
            sendMessage({msg ="MAIN_ROLE",aniStr = "meat"})
        end
    end) 
    scheduler.performWithDelayGlobal(function()
        sendMessage({msg="GAMESCENE_ENABLE"})
        helperNode:removeFromParent()
    end,GameConfig.Attack2AniEnd.zoro/GAME_FRAME_RATE)
end

function TopAniView:onExit()
    removeMessageByTarget(self)

    self:removeAllChildren()

    self._mainNode = nil
    self._mainAni = nil
end

return TopAniView