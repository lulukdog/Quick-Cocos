----------------------------------------------------------------------------------
--[[
    FILE:           UnlockShanzhiView.lua
    DESCRIPTION:    
    AUTHOR:         ZhaoLu
    CREATED:        2016-06-24 
--]]
----------------------------------------------------------------------------------
local GameConfig = require("data.GameConfig")
local common = require("app.common")
local scheduler = require("framework.scheduler")

local UnlockShanzhiView = class("UnlockShanzhiView", function()
    return display.newNode()
end)

function UnlockShanzhiView_video( result )
    if result=="success" then
        -- 统计视频次数
        local jsonStr = json.encode({adv_video={type=GameConfig.AdvType.shanzhiHelper}})
        common:javaSaveUserData(jsonStr)

        sendMessage({msg="MapScene_BuyHelperSuccess",helperNum=5})
    end
end

function UnlockShanzhiView:ctor()

	self._mainNode = CsbContainer:createPushCsb("UnlockShanzhiView.csb"):addTo(self)
    local _ani = cc.CSLoader:createTimeline("UnlockShanzhiView.csb")
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
        -- TODO buy
        if game.helper[5]==0 then

            common:javaOnVideo(UnlockShanzhiView_video)

            scheduler.unscheduleGlobal(self.scheduler)
            self:removeFromParent()
            self._mainNode = nil
        end
        if device.platform == "windows" then
            sendMessage({msg="MapScene_BuyHelperSuccess",helperNum=5})
        end
    end)

    -- 添加扫光
    self:addLightSweep("mTitle1Node","mTitle1Sprite",1)
    self:addLightSweep("mTitle2Node","mTitle2Sprite",2)
end

function UnlockShanzhiView:addLightSweep(nodeName,spriteName,tag)
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
        spark:setScaleY(2)
        spark:runAction(cc.RepeatForever:create(cc.Sequence:create(
            cc.CallFunc:create(function()
                spark:setPositionX(-_logoSprite:getContentSize().width)
            end),
            cc.MoveTo:create(1.5,cc.p(_logoSprite:getContentSize().width,0)),
            cc.DelayTime:create(1.5)
        )))
    end
end

return UnlockShanzhiView