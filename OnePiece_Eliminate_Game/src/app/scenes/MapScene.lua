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
local UpgradePushView = import("..views.UpgradePushView")
local RoleGetPushView = import("..views.RoleGetPushView")
local GoldBoxView = import("..views.GoldBoxView")
local CommonConfirmView = import("..views.CommonConfirmView")

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
        CommonConfirmView.new(GameConfig.BuyInfEnergyLabel,function()
            game.myEnergy = game.myEnergy + GameConfig.EnergyTb[4]
            game.countTime = math.max(0,game.countTime-GameConfig.EnergyTb[4]*game.addOneEnergyTime)
            UserDefaultUtil:SaveEnergy()
            self:refreshEnergy()
            self:refreshPage()

        end):addTo(self)
    end)
    -- 打开宝箱按钮
    self._boxBtn = cc.uiloader:seekNodeByName(self._mainNode,"mBoxBtn")
    CsbContainer:decorateBtnNoTrans(self._boxBtn,function()
        GoldBoxView.new():addTo(self)
    end)
    -- 宝箱上的剩余时间
    self:countBoxTime()
    self.timeBoxHandler = scheduler.scheduleGlobal(function()
        self:countBoxTime()
    end, 1) 

    addMessage(self, "REFRESHGOLD", self.refreshGold)
    addMessage(self, "MapScene_CountBoxTime", self.countBoxTime)
    addMessage(self, "Refresh_Energy", self.refreshEnergy)
    addMessage(self, "MapScene_RefreshPage", self.refreshPage)
    addMessage(self, "MapScene_PushRoleGetView", self.pushRoleGetView)

    local _skipShipUpgrade = false -- 是否跳过船舱升级画面，新手引导阶段就跳过
    -- 新手引导
    if common:getNowMaxStage()==8 and game.guideStep==10 then
        GuideFingerPushView.new():addTo(self)
        _skipShipUpgrade = true
    end

    -- 如果战斗胜利并且升级播放战舰升级画面
    if game.isShipUpgrade==true and _skipShipUpgrade==false then
        game.isShipUpgrade = false
        self:runShipUpgradeAni()
        print("MapScene:ctor runShipUpgradeAni")
    end

    -- 12关打过之后获得索隆
    if game.myStarNum>=helperCfg[2].needStar and game.helper[2]==0 then
        game.helper[2] = 1
        UserDefaultUtil:saveHelperLevel()
        self:refreshPage()

        RoleGetPushView.new(2):addTo(self)
    end
    -- 获得乌索普
    if game.myStarNum>=helperCfg[2].needStar+helperCfg[4].needStar and game.helper[4]==0 then
        game.helper[4] = 1
        UserDefaultUtil:saveHelperLevel()
        self:refreshPage()

        RoleGetPushView.new(4):addTo(self)
    end
    math.newrandomseed()

    -- 播放音效
    GameUtil_PlayMusic(GAME_MUSIC.bgMusic)
end

function MapScene:countBoxTime( )
    if game.boxLeftTime>0 then
        self._boxBtn:setEnabled(false)
    else
        self._boxBtn:setEnabled(true)
    end

    CsbContainer:setNodesVisible(self._mainNode, {
        mBoxLeftTimeLabel = game.boxLeftTime>0
    })
    CsbContainer:setStringForLabel(self._mainNode, {
        mBoxLeftTimeLabel = common:formatSecond(game.boxLeftTime),
    })
    
end

function MapScene:pushRoleGetView( data )
    RoleGetPushView.new(data._btnNum):addTo(self)
end

function MapScene:runShipUpgradeAni()
    UpgradePushView.new():addTo(self)
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
    })
    -- 设置当前可购买的是哪个人
    local _nowBuyHelperNum = 0
    for i=1,#GameConfig.BuyHelper do
        if game.helper[GameConfig.BuyHelper[i]]==0 then
            _nowBuyHelperNum = GameConfig.BuyHelper[i]
            break
        end
    end
    CsbContainer:setNodesVisible(self._mainNode, {
        mBuyHelperBtn = _nowBuyHelperNum~=0,
    })
    -- 购买人物按钮
    if _nowBuyHelperNum~=0 then
        local buyHelperBtn = cc.uiloader:seekNodeByName(self._mainNode,"mBuyHelperBtn")
        CsbContainer:decorateBtnNoTrans(buyHelperBtn,function()
            UnlockConfirmView.new(_nowBuyHelperNum):addTo(self)
        end)
        CsbContainer:refreshBtnView(buyHelperBtn,GameConfig.BuyHelperPic[_nowBuyHelperNum],GameConfig.BuyHelperPic[_nowBuyHelperNum])
        CsbContainer:setSpritesPic(self._mainNode, {mBuyHelperWordSprite = GameConfig.BuyHelperWordPic[_nowBuyHelperNum]})
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
    if self._leftNum<=0 and self._rightNum>game.MAXSTAGE then
        scheduler.unscheduleGlobal(self._stageScheduler)
        return
    end
    if self._leftNum>0 then
        local leftToNum = math.max(1,self._leftNum-10)
        for i=self._leftNum,leftToNum,-1 do
            self:addStageNode(i)
        end
    end
    if self._rightNum<=game.MAXSTAGE then
        local rightToNum = math.min(game.MAXSTAGE,self._rightNum+10)
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
                    ["mapNode"..i] = "ditu_all_0"..picNum..".png"
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

    -- 地图上的动画
    -- 瀑布动画
    local _mapAni = cc.CSLoader:createTimeline("MapScene.csb")
    self._mainNode:runAction(_mapAni)
    _mapAni:gotoFrameAndPlay(0,10,true)

    -- 鸟的动画
    local _birdAniTb = {}
    for i=1,3 do
        local _birdNode = cc.uiloader:seekNodeByName(self._mainNode, "mBirdAniNode"..i)
        local _birdAniCsb = cc.uiloader:load("BirdAniNode.csb"):addTo(_birdNode)
        _birdAniTb[i] = cc.CSLoader:createTimeline("BirdAniNode.csb")
        _birdAniCsb:runAction(_birdAniTb[i])
    end
    self._birdScheduler = scheduler.scheduleGlobal(function()
        for i=1,3 do
            _birdAniTb[i]:gotoFrameAndPlay(0,310,false)
        end
    end,8)

    -- 水波纹动画
    for i=1,20 do
        local _mapWaveNode = cc.uiloader:seekNodeByName(self._mainNode,"mWaveNode"..i)
        self:addWaveAni(_mapWaveNode,math.random(4,5))
    end
end
function MapScene:addWaveAni( addNode,addNum )
    local _scaleRate = display.top/1334
    if display.right>=1080 then
        _scaleRate = 1.4
    end
    local _scale1,_scale2 = _scaleRate*5,_scaleRate*9
    local _posX,_posY,_delay = 30,0,0.1
    for i=1,addNum do
        _posX = _posX + math.random(10,20)
        _posY = _posY + math.random(20,40)
        _delay = _delay + math.random(1,4)*0.1
        local ranSpriteNum = i<=3 and i or math.random(1,3)
        local scale = math.random(_scale1,_scale2)*0.1
        local waveSprite = display.newSprite("#waterflash_"..ranSpriteNum.."_01.png"):addTo(addNode)
        waveSprite:setPosition(_posX,_posY)
        waveSprite:setScale(scale)
        scheduler.performWithDelayGlobal(function()
            waveSprite:playAnimationForever(display.getAnimationCache("wave"..ranSpriteNum))
        end,_delay)
    end
end

function MapScene:onExit()
    print("MapScene:onExit")
    removeMessageByTarget(self)
    scheduler.unscheduleGlobal(self._stageScheduler)
    scheduler.unscheduleGlobal(self._birdScheduler)
    scheduler.unscheduleGlobal(self.timeBoxHandler)
    if self._moveScheduler~=nil then
        scheduler.unscheduleGlobal(self._moveScheduler)
    end
end

return MapScene