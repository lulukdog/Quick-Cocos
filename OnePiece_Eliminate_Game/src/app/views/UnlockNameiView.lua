----------------------------------------------------------------------------------
--[[
    FILE:           UnlockNameiView.lua
    DESCRIPTION:    
    AUTHOR:         ZhaoLu
    CREATED:        2016-06-24 
--]]
----------------------------------------------------------------------------------
local GameConfig = require("data.GameConfig")
local common = require("app.common")
local scheduler = require("framework.scheduler")

local UnlockNameiView = class("UnlockNameiView", function()
    return display.newNode()
end)

function UnlockConfirm_namei( _result )
    print("UnlockConfirm_namei ".._result)
    local resultCfg = common:parseStrOnlyWithUnderline(_result)
    if resultCfg[1] ~= "fail" then
        local result = resultCfg[1]
        local payMethod = resultCfg[2]
        UserDefaultUtil:recordRecharge(tonumber(result)/100,payMethod,1,3)

        sendMessage({msg="MapScene_BuyHelperSuccess",helperNum=3})
    else
        local result = resultCfg[2]
        local payMethod = resultCfg[3]
        UserDefaultUtil:recordRecharge(tonumber(result)/100,payMethod,-1,3)
    end
end

function UnlockNameiView:ctor()

	self._mainNode = CsbContainer:createPushCsb("UnlockNameiView.csb"):addTo(self)
    local _ani = cc.CSLoader:createTimeline("UnlockNameiView.csb")
    self._mainNode:runAction(_ani)
    _ani:gotoFrameAndPlay(0,60,true)

    local closeBtn = cc.uiloader:seekNodeByName(self._mainNode,"mCloseBtn")
	CsbContainer:decorateBtn(closeBtn,function()
        scheduler.unscheduleGlobal(self.scheduler)
		self:removeFromParent()
		self._mainNode = nil
	end)

    local confirmBtn = cc.uiloader:seekNodeByName(self._mainNode,"mConfirmBtn")
    CsbContainer:decorateBtn(confirmBtn,function()
        if game.helper[3]==0 then

            common:javaOnUseMoney(UnlockConfirm_namei,3000)
            
            scheduler.unscheduleGlobal(self.scheduler)
            self:removeFromParent()
            self._mainNode = nil
        end
        if device.platform == "windows" then
            sendMessage({msg="MapScene_BuyHelperSuccess",helperNum=3})
        end
    end)

    -- 添加扫光
    self:addLightSweep("mTitle1Node","mTitle1Sprite",1)
    self:addLightSweep("mTitle2Node","mTitle2Sprite",2)
end

function UnlockNameiView:addLightSweep(nodeName,spriteName,tag)
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

    spark:setScaleY(2)
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

return UnlockNameiView