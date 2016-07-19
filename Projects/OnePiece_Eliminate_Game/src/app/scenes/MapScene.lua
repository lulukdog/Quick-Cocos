local BubbleButton = import("..views.BubbleButton")
local MapDetailView = import("..views.MapDetailView")
local ShipUpgradeView = import("..views.ShipUpgradeView")
local UnlockRoleView = import("..views.UnlockRoleView")
local UnlockConfirmView = import("..views.UnlockConfirmView")
local Ship2PopView = import("..views.Ship2PopView")
local SetView = import("..views.SetView")
local BuyGoldView = import("..views.BuyGoldView")
local BuyEnergyView = import("..views.BuyEnergyView")
local GuideFingerPushView = import("..views.GuideFingerPushView")
local StageNode = import("..views.StageNode")

local common = require("app.common")
local scheduler = require("framework.scheduler")
local stageCfg = require("data.data_stage")
local monsterCfg = require("data.data_monster")
local GameConfig = require("data.GameConfig")
local helperCfg = require("data.data_helper")

local MapScene = class("MapScene", function()
	return display.newScene("MapScene")
end)

function MapScene:ctor()
	self._mainNode = CsbContainer:createMapCsb("MapScene.csb"):addTo(self)
    self._mapNode = cc.uiloader:seekNodeByName(self._mainNode, "Map")

    -- 加上滑动层
    self._touchLayer = display.newLayer():addTo(self)
    self._touchLayer:setTouchSwallowEnabled(false)
    self._touchLayer:setContentSize(display.right,display.top)
    self._touchLayer:setPosition(0,0)
    self._touchLayer:setTouchEnabled(true)

    self:initMapTouch()

    self._moveScheduler = nil

    self:refreshGold()
    self:refreshEnergy()
    self:refreshPage()

    self.updateCount = 1
    self._stageScheduler = nil
    self._oneMapHeight = 1050 -- 一张地图碎片的高度
    self._mapNum = 0 -- 上一次在哪张地图碎片

	-- -- 选关按钮
 --    local stage1Button = cc.uiloader:seekNodeByTag(self._mainNode,101)
 --    CsbContainer:decorateBtn(stage1Button,function()
 --        game.nowStage = 1
 --        -- self:enterGameScene()
 --        MapDetailView.new():addTo(self)
 --        -- test java
 --        self:buyItem()
 --    end)
 --    local stage2Button = cc.uiloader:seekNodeByTag(self._mainNode,102)
 --    CsbContainer:decorateBtn(stage2Button,function()
 --        game.nowStage = 2
 --        -- self:enterGameScene()
 --        MapDetailView.new():addTo(self)
 --        -- test java
 --        self:buySuccess()
 --    end)

    -- 船升级按钮
    local shipUpgradeBtn = cc.uiloader:seekNodeByName(self._mainNode,"ShipUpgradeBtn")
    CsbContainer:decorateBtnNoTrans(shipUpgradeBtn,function()
        ShipUpgradeView.new():addTo(self)
    end)
    -- 解锁角色按钮
    local roleBtn = cc.uiloader:seekNodeByName(self._mainNode,"mRoleBtn")
    CsbContainer:decorateBtnNoTrans(roleBtn,function()
        if game.guideStep==10 then
            sendMessage({msg="GuideFingerPushView_onNext"})
        end
        UnlockRoleView.new():addTo(self)
    end)
    -- 设置按钮
    local setBtn = cc.uiloader:seekNodeByName(self._mainNode,"mSetBtn")
    CsbContainer:decorateBtnNoTrans(setBtn,function()
        SetView.new():addTo(self)
    end)
    -- 购买金币按钮
    local buyGoldBtn = cc.uiloader:seekNodeByName(self._mainNode,"mBuyGoldBtn")
    CsbContainer:decorateBtnNoTrans(buyGoldBtn,function()
        BuyGoldView.new():addTo(self)
    end)
    -- 购买体力按钮
    local buyEnergyBtn = cc.uiloader:seekNodeByName(self._mainNode,"mBuyEnergyBtn")
    CsbContainer:decorateBtnNoTrans(buyEnergyBtn,function()
        BuyEnergyView.new():addTo(self)
    end)
    -- 购买船的按钮
    local buyShipBtn = cc.uiloader:seekNodeByName(self._mainNode,"mBuyShipBtn")
    CsbContainer:decorateBtnNoTrans(buyShipBtn,function()
        Ship2PopView.new():addTo(self)
    end)
    -- 购买无限体力按钮
    local buyInfEnergyBtn = cc.uiloader:seekNodeByName(self._mainNode,"mBuyInfEnergyBtn")
    CsbContainer:decorateBtnNoTrans(buyInfEnergyBtn,function()
        BuyEnergyView.new():addTo(self)
    end)

    addMessage(self, "REFRESHGOLD", self.refreshGold)
    addMessage(self, "Refresh_Energy", self.refreshEnergy)
    addMessage(self, "MapScene_RefreshPage", self.refreshPage)

    -- 如果战斗胜利并且升级播放战舰升级画面
    if game.isShipUpgrade==true then
        game.isShipUpgrade = false
        self:runShipUpgradeAni()
        print("MapScene:ctor runShipUpgradeAni")
    end

    CsbContainer:setSpritesPic(self._mainNode, {
        Map1 = "guanka_map_bg.png"
    })

    -- 新手引导
    if common:getNowMaxStage()==8 and game.guideStep==10 then
        GuideFingerPushView.new():addTo(self)
    end
end

function MapScene:runShipUpgradeAni()
    --TODO
end

function MapScene:refreshGold()
    CsbContainer:setStringForLabel(self._mainNode,{
        mGoldLabel = game.myGold
    })
end
function MapScene:refreshEnergy()
    CsbContainer:setStringForLabel(self._mainNode,{
        mEnergyLabel = common:getNowEnergyLabel()
    })
end
function MapScene:refreshPage()
    CsbContainer:setNodesVisible(self._mainNode, {
        mBuyShipBtn = game.nowShip<2,
        mBuyInfEnergyBtn = game.myEnergy<5000,
        mBuyHelperBtn = game.helper[GameConfig.BuyHelper[3]]==0,
    })
    -- 设置当前可购买的是哪个人
    local _nowBuyHelperNum = 0
    for i=1,#GameConfig.BuyHelper do
        if game.helper[GameConfig.BuyHelper[i]]==0 then
            _nowBuyHelperNum = GameConfig.BuyHelper[i]
            break
        end
    end
    -- 购买人物按钮
    if _nowBuyHelperNum~=0 then
        local buyHelperBtn = cc.uiloader:seekNodeByName(self._mainNode,"mBuyHelperBtn")
        CsbContainer:decorateBtnNoTrans(buyHelperBtn,function()
            UnlockConfirmView.new(_nowBuyHelperNum):addTo(self)
        end)
        CsbContainer:refreshBtnView(buyHelperBtn,helperCfg[_nowBuyHelperNum].pic,helperCfg[_nowBuyHelperNum].pic)
    end
end

function MapScene:initMapTouch()

    local mdy,dragPressy, mapOriy, premy
    self._touchLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        local y = event.y
        if event.name == "began" then
            self._mapNode:stopAllActions()
            dragPressy = y
            premy = y
            mapOriy = self._mapNode:getPositionY()
            mdy = 0
            if self._moveScheduler~=nil then
                scheduler.unscheduleGlobal(self._moveScheduler)
            end

            return true
        elseif event.name == "moved" then
            if premy == y then
                return
            end
            mdy = y - premy
            premy = y
            dragPressy = dragPressy or y

            local my = mapOriy
            local dy = y - dragPressy
            my = my + dy
            my = math.max(my,display.top*(750/display.right)-game.MAPHEIGHT)
            my = math.min(my,0)
            self._mapNode:setPositionY(my)
            self:refreshMapTex(my)
        elseif event.name == "ended" then
            if self._moveScheduler~=nil then
               scheduler.unscheduleGlobal(self._moveScheduler)
            end
            if mdy~=0 then
                local moveY,oriY = self._mapNode:getPositionY(),self._mapNode:getPositionY()
                self._moveScheduler = scheduler.scheduleUpdateGlobal(function( )
                    mdy = mdy*0.95
                    moveY = moveY + mdy*0.95
                    -- print("moveY"..moveY.." mdy "..mdy .." rate "..rate)
                    if math.abs(mdy)<0.1 then
                        scheduler.unscheduleGlobal(self._moveScheduler)
                        return
                    end
                    moveY = math.max(moveY,display.top*(750/display.right)-game.MAPHEIGHT)
                    moveY = math.min(moveY,0)
                    self._mapNode:setPositionY(moveY)
                    self:refreshMapTex(moveY)
                end)
            end
        end
    end)
end

--建立100个关卡按钮
function MapScene:initStageNode()
    if self._leftNum<=0 and self._rightNum>=100 then
        scheduler.unscheduleGlobal(self._stageScheduler)
        return
    end
    if self._leftNum>0 then
        local leftToNum = math.max(1,self._leftNum-10)
        for i=self._leftNum,leftToNum,-1 do
            self:addStageNode(i)
        end
    end
    if self._rightNum<100 then
        local rightToNum = math.min(99,self._rightNum+10)
        for i=self._rightNum,rightToNum do
            self:addStageNode(i)
        end
    end
    self._leftNum = self._leftNum-11
    self._rightNum = self._rightNum+11
end

function MapScene:addStageNode(i)
    local _mainNode = cc.uiloader:seekNodeByName(self._mainNode,"mStageNode"..i)
    local _node = cc.uiloader:load("StageNode.csb"):addTo(_mainNode)
    _node:setScale(750/1080)
    CsbContainer:setStringForLabel(_node, {
        mOpenStageLabel = string.format("%02d",i),
        mCloseStageLabel = string.format("%02d",i),
    })
    for j=1,3 do
        if game.stageStars[i]~=nil then
            CsbContainer:setNodesVisible(_node, {
                ["mStar"..j]=j<=game.stageStars[i]
            })
        else
            CsbContainer:setNodesVisible(_node, {
                ["mStar"..j]=false
            })
        end
    end
    
    CsbContainer:setNodesVisible(_mainNode, {
        mOpenNode = i<=common:getNowMaxStage(),
        mCloseNode = i>common:getNowMaxStage(),
        mFlagAni = i==common:getNowMaxStage()
    })
    -- 设置按钮监听函数
    if i<=common:getNowMaxStage() then
        -- 选关按钮,按钮设置不吞噬点击事件却无效，所以用了sprite监听
        local _stageSprite = cc.uiloader:seekNodeByName(_node,"mStageSprite")
        local _moveY = 0
        _stageSprite:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
            if event.name == "began" then
                if game.SoundOn==true then
                    audio.playSound(GAME_SOUND.tapButton)
                end
                _moveY = event.y
                return true
            elseif event.name=="ended" then
                if math.abs(_moveY-event.y)<1 then
                    game.nowStage = i
                    MapDetailView.new():addTo(self)
                end
            end
        end)
        _stageSprite:setTouchEnabled(true)
    -- boss关有介绍
    elseif stageCfg[i].bossId~=nil then
        local _graySprite = cc.uiloader:seekNodeByName(_node,"mGraySprite")
        local _bossSprite = cc.uiloader:seekNodeByName(_node,"mBossSprite")
        local _moveY = 0
        local _monsterId = stageCfg[i].bossId
        _graySprite:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
            if event.name == "began" then
                _moveY = event.y
                return true
            elseif event.name=="ended" then
                if math.abs(_moveY-event.y)<1 then
                    MessagePopView.new(monsterCfg[_monsterId].des):addTo(self)
                end
            end
        end)
        _bossSprite:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
            if event.name == "began" then
                _moveY = event.y
                return true
            elseif event.name=="ended" then
                if math.abs(_moveY-event.y)<1 then
                    MessagePopView.new(monsterCfg[_monsterId].des):addTo(self)
                end
            end
        end)
        _graySprite:setTouchEnabled(true)
        _bossSprite:setTouchEnabled(true)
        CsbContainer:setSpritesPic(_node, {
            mBossSprite = monsterCfg[_monsterId].pic
        })
    end

    -- 按钮图片和动画
    if i<common:getNowMaxStage() then
        CsbContainer:setSpritesPic(_node,{
            mStageSprite = "guanka_blue_btn.png"
        })
    elseif i==common:getNowMaxStage() then
        CsbContainer:setSpritesPic(_node,{
            mStageSprite = "guanka_red_btn.png"
        })
        local _screenPixHight = display.top*(1080/display.right)
        local _crollToPosY = math.min(0,-_mainNode:getPositionY()+500) 
        _crollToPosY = math.max(_screenPixHight-game.MAPHEIGHT,_crollToPosY) 
        self._mapNode:setPositionY(_crollToPosY)
        self:refreshMapTex(_crollToPosY)
        for j=1,3 do
            CsbContainer:setNodesVisible(_mainNode, {
                ["star-gray"..j] = false
            })
        end
        local _flagAni = cc.CSLoader:createTimeline("StageNode.csb")
        _mainNode:runAction(_flagAni)
        _flagAni:gotoFrameAndPlay(0,49,true)
    end
end

-- 根据位置加载地图。因为加载高度超过4000的图会因为内存过大导致安卓机地图变黑，所以该成实时加载
-- param midY:当前位置的屏幕中点y坐标
function MapScene:refreshMapTex(posY)
    local midY = math.abs(posY)+display.cy
    -- 算出应该加载第几张图
    local _mapNum = math.ceil(midY/self._oneMapHeight)
    if self._mapNum ~= _mapNum then
        self._mapNum = _mapNum
        local _up,_down = _mapNum+1,_mapNum-1
        if _mapNum==1 then
            _down = 1
        elseif _mapNum==8 then
            _up = 8
        end

        for i=1,8 do
            if (i<_down or i>_up) then
                CsbContainer:setSpritesPic(self._mainNode, {
                    ["mapNode"..i] = "empty.png"
                })
            elseif i>=_down and i<=_up then
                local picNum = 9-i
                CsbContainer:setSpritesPic(self._mainNode, {
                    ["mapNode"..i] = "guanka_map_bg_0"..picNum..".png"
                })
            end
        end
    end
end

function MapScene:enterGameScene(  )
	app:enterScene("GameScene", nil, "fade", 0.6, display.COLOR_WHITE)
end

function MapScene:onEnter()
	print("MapScene:onEnter")
    self._leftNum=common:getNowMaxStage()
    self._rightNum = common:getNowMaxStage()+1

    self:initStageNode()
    self._stageScheduler = scheduler.scheduleGlobal(function()
        self:initStageNode()
    end,0.3)

end
function MapScene:onExit()
    print("MapScene:onExit")
    removeMessageByTarget(self)
    scheduler.unscheduleGlobal(self._stageScheduler)
    if self._moveScheduler~=nil then
        scheduler.unscheduleGlobal(self._moveScheduler)
    end
end

local function callback(result)
    if result == "success" then
        print("MapScene:buyItem callback is success")
    end
end

function MapScene:buyItem()
	local args = {
        "items",
        10,
        8,
        callback,
    }
    print("MapScene:buyItem")
    if device.platform == "android" then

        -- Java 类的名称
        local className = "org/cocos2dx/sdk/EyeCat"
        -- 调用 Java 方法
        print("MapScene:buyItem"..className)
        local ok, ret = luaj.callStaticMethod(className, "eye_buy", args, "(Ljava/lang/String;III)I")
        if not ok then
            print("luaj error:", ret)
        else
            print("ret:", ret) -- 输出 ret: 5
        end
    end
	
end

function MapScene:buySuccess(  )
	print("MapScene:buySuccess")
	if device.platform == "android" then

        -- Java 类的名称
        local className = "org/cocos2dx/sdk/EyeCat"
        -- 调用 Java 方法
        local ok = luaj.callStaticMethod(className, "rechargeSuccess")
        if not ok then
            print("luaj error:")
        else
            print("ret:")
        end
    end
end

return MapScene