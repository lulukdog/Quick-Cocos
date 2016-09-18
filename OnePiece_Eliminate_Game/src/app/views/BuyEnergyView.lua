----------------------------------------------------------------------------------
--[[
    FILE:           BuyEnergyView.lua
    DESCRIPTION:    购买体力页面
    AUTHOR:         ZhaoLu
    CREATED:        2016-06-25
--]]
----------------------------------------------------------------------------------
local scheduler = require("framework.scheduler")
local common = require("app.common")
local GameConfig = require("data.GameConfig")

local BuyEnergyView = class("BuyEnergyView", function()
    return display.newNode()
end)

function BuyEnergyView:ctor()

	self._mainNode = CsbContainer:createPushCsb("BuyEnergyView.csb"):addTo(self)
    local _ani = cc.CSLoader:createTimeline("BuyEnergyView.csb")
    self._mainNode:runAction(_ani)
    _ani:gotoFrameAndPlay(0,80,true)

    local closeBtn = cc.uiloader:seekNodeByName(self._mainNode,"mCloseBtn")
	CsbContainer:decorateBtn(closeBtn,function()
        scheduler.unscheduleGlobal(self.timeHandler)
        removeMessageByTarget(self)
		self:removeFromParent()
		self._mainNode = nil
	end)

    for i=1,4 do
        local buyBtn = cc.uiloader:seekNodeByName(self._mainNode,"mBuyBtn"..i)
        CsbContainer:decorateBtn(buyBtn,function()
            self:buyEnergy(i)
        end)
    end

    self._buy50EnergyBtn = cc.uiloader:seekNodeByName(self._mainNode,"mBuyBtn3")

    self:refreshTime()
    -- 剩余时间,先执行一次后每隔一秒执行一次
    self:countTime()
    self.timeHandler = scheduler.scheduleGlobal(function()
        self:countTime()
    end, 1) 

    addMessage(self, "BuyEnergyView_refreshTime", self.refreshTime)
    addMessage(self, "BuyEnergyView_countTime", self.countTime)
end
function BuyEnergyView:countTime()
    CsbContainer:setNodesVisible(self._mainNode, {
        m50EneryLabel = game.count50EnergyTime>0
    })
    CsbContainer:setStringForLabel(self._mainNode, {
        mTimeLabel = common:formatSecond(game.countTime),
        m50EneryLabel = common:formatSecond(game.count50EnergyTime),
    })
end

function buyEnergy_callback(_result)
    print("buyEnergy_callback ".._result)
    local resultCfg = common:parseStrOnlyWithUnderline(_result)
    if resultCfg[1] ~= "fail" then
        local result = resultCfg[1]
        local payMethod = resultCfg[2]

        game.myEnergy = game.myEnergy + GameConfig.BuyEnergyCfg[tonumber(result)/100]
        UserDefaultUtil:recordRecharge(tonumber(result)/100,payMethod,1,2)
        game.countTime = math.max(0,game.countTime-GameConfig.BuyEnergyCfg[tonumber(result)/100]*game.addOneEnergyTime)
        UserDefaultUtil:SaveEnergy()
        sendMessage({msg="Refresh_Energy"})
        sendMessage({msg="BuyEnergyView_refreshTime"})
    else
        local result = resultCfg[2]
        local payMethod = resultCfg[3]
        UserDefaultUtil:recordRecharge(tonumber(result)/100,payMethod,-1,2)
    end
end

function buyEnergy_video( result )
    if result=="success" then
        game.myEnergy = game.myEnergy + 50
        game.countTime = math.max(0,game.countTime-50*game.addOneEnergyTime)
        UserDefaultUtil:SaveEnergy()
        sendMessage({msg="Refresh_Energy"})
        sendMessage({msg="BuyEnergyView_refreshTime"})

        game.count50EnergyTime = game.energy50Time
        UserDefaultUtil:Save50EnergyCount()
        sendMessage({msg="BuyEnergyView_countTime"})
        -- 统计视频次数
        local jsonStr = json.encode({adv_video={type=GameConfig.AdvType.energy}})
        common:javaSaveUserData(jsonStr)
    else
        MessagePopView.new(10):addTo(self)
    end
end

-- 点击购买相应价格的体力值
function BuyEnergyView:buyEnergy( btnNum )
    if game.myEnergy>5000 then
        MessagePopView.new(4):addTo(self)
        return
    end
    -- 购买50体力要加倒计时
    if btnNum == 3 then
        if game.count50EnergyTime>0 then
            MessagePopView.new(6):addTo(self)
        else
            common:javaOnVideo(buyEnergy_video)
        end
    end

    local _rmbCount = GameConfig.RMBEnergyCfg[btnNum]
    -- print("BuyGoldView:buyItem")
    if device.platform == "android" or device.platform == "ios" then
        common:javaOnUseMoney(buyEnergy_callback,_rmbCount)
    elseif device.platform == "windows" then
        game.myEnergy = game.myEnergy + GameConfig.EnergyTb[btnNum]
        game.countTime = math.max(0,game.countTime-GameConfig.EnergyTb[btnNum]*game.addOneEnergyTime)
        UserDefaultUtil:SaveEnergy()
        self:refreshTime()
        sendMessage({msg="Refresh_Energy"})
    end
end

--刷新体力显示
function BuyEnergyView:refreshTime()
    CsbContainer:setStringForLabel(self._mainNode, {
        mEnergyLabel =  common:getNowEnergyLabel()
    })
end

return BuyEnergyView