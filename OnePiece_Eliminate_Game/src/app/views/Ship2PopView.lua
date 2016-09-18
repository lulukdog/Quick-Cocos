----------------------------------------------------------------------------------
--[[
    FILE:           Ship2PopView.lua
    DESCRIPTION:    
    AUTHOR:         ZhaoLu
    CREATED:        2016-06-24 
--]]
----------------------------------------------------------------------------------
local GameConfig = require("data.GameConfig")
local common = require("app.common")
local scheduler = require("framework.scheduler")


local Ship2PopView = class("Ship2PopView", function()
    return display.newNode()
end)

function Ship2Pop_buy( _result )
    print("Ship2Pop_buy".._result)
    local resultCfg = common:parseStrOnlyWithUnderline(_result)
    if resultCfg[1] ~= "fail" then
        local result = resultCfg[1]
        local payMethod = resultCfg[2]
        UserDefaultUtil:recordRecharge(tonumber(result)/100,payMethod,1,6)

        sendMessage({msg="MapScene_Ship2BuySuccess"})
    else
        local result = resultCfg[2]
        local payMethod = resultCfg[3]
        UserDefaultUtil:recordRecharge(tonumber(result)/100,payMethod,-1,6)
    end
end

function Ship2PopView:ctor()

	self._mainNode = CsbContainer:createPushCsb("Ship2PopView.csb"):addTo(self)
    local _ani = cc.CSLoader:createTimeline("Ship2PopView.csb")
    self._mainNode:runAction(_ani)
    _ani:gotoFrameAndPlay(0,80,true)

    local closeBtn = cc.uiloader:seekNodeByName(self._mainNode,"mCloseBtn")
	CsbContainer:decorateBtn(closeBtn,function()
        if self.scheduler~=nil then
            scheduler.unscheduleGlobal(self.scheduler)
        end
		self:removeFromParent()
		self._mainNode = nil
	end)

    local buyBtn = cc.uiloader:seekNodeByName(self._mainNode,"mBuyBtn")
    CsbContainer:decorateBtn(buyBtn,function()
        common:javaOnUseMoney(Ship2Pop_buy,3000)
        
        if device.platform == "windows" then
            sendMessage({msg="MapScene_Ship2BuySuccess"})
        end
        self:removeFromParent()
        self._mainNode = nil
    end)

    -- CsbContainer:setStringForLabel(self._mainNode, {
    --     mAttackLabel = shipCfg[game.nowShipLevel].attack,
    --     mDefLabel = shipCfg[game.nowShipLevel].def,
    --     mLifeLabel = shipCfg[game.nowShipLevel].life,
    -- })
        -- 添加扫光
    self:addLightSweep("mTitle1Node","mTitle1Sprite",1)
    self:addLightSweep("mTitle2Node","mTitle2Sprite",2)
end

function Ship2PopView:addLightSweep(nodeName,spriteName,tag)
    local _logoNode = cc.uiloader:seekNodeByName(self._mainNode, nodeName)
    local _logoSprite = cc.uiloader:seekNodeByName(self._mainNode, spriteName)
    local clipSize = _logoSprite:getContentSize()

    local spark = display.newSprite("pic/light_forwordsandbutton_item.png")
    spark:setPositionX(-_logoSprite:getContentSize().width)
    local clippingNode = cc.ClippingNode:create():addTo(_logoNode,1,1)

    clippingNode:setAlphaThreshold(0)
    clippingNode:setContentSize(clipSize)

    clippingNode:setStencil(_logoSprite)
    clippingNode:addChild(spark,1)

    if tag==2 then
        self.scheduler = scheduler.performWithDelayGlobal(function()
            spark:runAction(cc.RepeatForever:create(cc.Sequence:create(
                cc.CallFunc:create(function()
                    spark:setPositionX(-_logoSprite:getContentSize().width)
                end),
                cc.MoveTo:create(1.5,cc.p(_logoSprite:getContentSize().width,0)),
                cc.DelayTime:create(1.5)
            )))
        end, 1.5)
    else
        spark:runAction(cc.RepeatForever:create(cc.Sequence:create(
            cc.CallFunc:create(function()
                spark:setPositionX(-_logoSprite:getContentSize().width)
            end),
            cc.MoveTo:create(1.5,cc.p(_logoSprite:getContentSize().width,0)),
            cc.DelayTime:create(1.5)
        )))
    end
end

return Ship2PopView