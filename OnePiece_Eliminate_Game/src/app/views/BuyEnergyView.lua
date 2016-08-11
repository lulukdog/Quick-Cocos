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

    self:refreshEnergy()
    -- 剩余时间,先执行一次后每隔一秒执行一次
    self:countTime()
    self.timeHandler = scheduler.scheduleGlobal(function()
        self:countTime()
    end, 1) 

    addMessage(self, "BuyEnergyView_refreshTime", self.refreshEnergy)
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

function buyEnergy_callback(result)
    if result == "fail" then
        MessagePopView.new(8):addTo(self)
    else
        game.myEnergy = game.myEnergy + GameConfig.BuyEnergyCfg[tonumber(result)/100]
        game.countTime = math.max(0,game.countTime-GameConfig.BuyEnergyCfg[tonumber(result)/100]*game.addOneEnergyTime)
        UserDefaultUtil:SaveEnergy()
        self:refreshEnergy()
        sendMessage({msg="Refresh_Energy"})
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
            game.count50EnergyTime = game.energy50Time
            UserDefaultUtil:Save50EnergyCount()
            self:countTime()
            -- 统计视频次数
            common:javaSaveUserData("AdvVideo",tostring(GameConfig.AdvType.energy))
        end
        return
    end


    local _rmbCount = GameConfig.RMBEnergyCfg[btnNum]
    local args = {
        "jinbi",
        _rmbCount,
        1,
        buyEnergy_callback,
        1,
    }
    print("BuyGoldView:buyItem")
    if device.platform == "android" then
        -- Java 类的名称
        local className = "org/cocos2dx/sdk/EyeCat"
        -- 调用 Java 方法
        print("BuyGoldView:buyItem"..className)
        local ok, ret = luaj.callStaticMethod(className, "wxpee", args, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;II)V")
        if not ok then
            print("luaj error:", ret)
        else
            print("ret:", ret)
        end
    elseif device.platform == "windows" then
        game.myEnergy = game.myEnergy + GameConfig.EnergyTb[btnNum]
        game.countTime = math.max(0,game.countTime-GameConfig.EnergyTb[btnNum]*game.addOneEnergyTime)
        UserDefaultUtil:SaveEnergy()
        self:refreshEnergy()
        sendMessage({msg="Refresh_Energy"})
    end
end

--刷新体力显示
function BuyEnergyView:refreshEnergy()
    CsbContainer:setStringForLabel(self._mainNode, {
        mEnergyLabel =  common:getNowEnergyLabel()
    })
end

return BuyEnergyView