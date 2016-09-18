----------------------------------------------------------------------------------
--[[
    FILE:           OneYuanPushView.lua
    DESCRIPTION:    一元购弹出页面
    AUTHOR:         ZhaoLu
    CREATED:        2016-06-24 
--]]
----------------------------------------------------------------------------------
local common = require("app.common")
local GameConfig = require("data.GameConfig")
local scheduler = require("framework.scheduler")

local OneYuanPushView = class("OneYuanPushView", function()
    return display.newNode()
end)

function OneYuanPush_Buy( _result )
    print("OneYuanPush_Buy".._result)
    local resultCfg = common:parseStrOnlyWithUnderline(_result)
    if resultCfg[1] ~= "fail" then
        local result = resultCfg[1]
        local payMethod = resultCfg[2]
        UserDefaultUtil:recordRecharge(tonumber(result)/100,payMethod,1,4)

        sendMessage({msg="OneYuanPushView_buySuccess"})
    else
        local result = resultCfg[2]
        local payMethod = resultCfg[3]
        UserDefaultUtil:recordRecharge(tonumber(result)/100,payMethod,-1,4)
    end
end

function OneYuanPushView:ctor()

	self._mainNode = CsbContainer:createPushCsb("OneYuanPushView.csb"):addTo(self)
    local _ani = cc.CSLoader:createTimeline("OneYuanPushView.csb")
    self._mainNode:runAction(_ani)
    _ani:gotoFrameAndPlay(0,75,true)

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
        common:javaOnUseMoney(OneYuanPush_Buy,GameConfig.OneYuanBuyMoney)
        if device.platform=="windows" then
            self:buySuccess()
        end
    end)

    self.scheduler = nil
    -- 添加扫光
    self:addLightSweep("mTitle1Node","mTitle1Sprite",1)
    self:addLightSweep("mTitle2Node","mTitle2Sprite",2)
    self:addLightSweep("mBuyNode","mBuySprite",3)
    addMessage(self, "OneYuanPushView_buySuccess", self.buySuccess)
end

function OneYuanPushView:buySuccess( )
    scheduler.performWithDelayGlobal(function( )
        game.myGold = game.myGold + GameConfig.OneYuanCfg.money
        UserDefaultUtil:saveGold()
        sendMessage({msg="REFRESHGOLD"})

        game.myEnergy = game.myEnergy + GameConfig.OneYuanCfg.energy
        game.countTime = math.max(0,game.countTime-GameConfig.OneYuanCfg.energy*game.addOneEnergyTime)
        UserDefaultUtil:SaveEnergy()
        sendMessage({msg="Refresh_Energy"})

        if game.helper[GameConfig.OneYuanCfg.helper]==0 then
            game.helper[GameConfig.OneYuanCfg.helper] = 1
            UserDefaultUtil:saveHelperLevel(GameConfig.OneYuanCfg.helper)

            sendMessage({msg="MapScene_PushRoleGetView",_btnNum=GameConfig.OneYuanCfg.helper})
        end
        game.boughtOneYuan = true
        UserDefaultUtil:saveOneYuan()
        sendMessage({msg="MapScene_RefreshPage"})
    end,0.2)
    
    if self.scheduler~=nil then
        scheduler.unscheduleGlobal(self.scheduler)
    end
    removeMessageByTarget(self)
    self:removeFromParent()
    self._mainNode = nil
end

function OneYuanPushView:addLightSweep(nodeName,spriteName,tag)
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

    local delayTime = 0
    if tag==1 or tag==2 then
        delayTime = 1.5
    end

    local moveDelayTime = 1.5
    if tag==3 then
        moveDelayTime = 3
    end

    if tag==2 then
        self.scheduler = scheduler.performWithDelayGlobal(function()
            spark:runAction(cc.RepeatForever:create(cc.Sequence:create(
                cc.CallFunc:create(function()
                    spark:setPositionX(-_logoSprite:getContentSize().width)
                end),
                cc.MoveTo:create(moveDelayTime,cc.p(_logoSprite:getContentSize().width,0)),
                cc.DelayTime:create(delayTime)
            )))
        end, 1.5)
    else
        spark:runAction(cc.RepeatForever:create(cc.Sequence:create(
            cc.CallFunc:create(function()
                spark:setPositionX(-_logoSprite:getContentSize().width)
            end),
            cc.MoveTo:create(moveDelayTime,cc.p(_logoSprite:getContentSize().width,0)),
            cc.DelayTime:create(delayTime)
        )))
    end
end

return OneYuanPushView