----------------------------------------------------------------------------------
--[[
    FILE:           UserDefaultUtil.lua
    DESCRIPTION:    UserDefault工具
    AUTHOR:         ZhaoLu
    CREATED:        2016-06-27
--]]
----------------------------------------------------------------------------------
UserDefaultUtil = {}
local common = require("app.common")
--Integer,Double,Bool,Float,String,

-- 系统时间，倒计时，体力
function UserDefaultUtil:SaveEnergy()
    local timeStr = common:getElapsedTime().."_"..game.countTime.."_"..game.myEnergy
    timeStr = common:encString(timeStr)
    cc.UserDefault:getInstance():setStringForKey(game.PLAYERID.."Time",timeStr)
    cc.UserDefault:getInstance():flush()
end
function UserDefaultUtil:GetEnergy()
    local timeStr = cc.UserDefault:getInstance():getStringForKey(game.PLAYERID.."Time")
    -- print("UserDefaultUtil:GetEnergy  "..timeStr)
    if timeStr=="" then
        return nil
    end
    timeStr = common:decString(timeStr)
    local timeTb = common:parseStrOnlyWithUnderline(timeStr)
    return tonumber(timeTb[1]),tonumber(timeTb[2]),tonumber(timeTb[3])
end
-- 购买50体力倒计时
function UserDefaultUtil:Save50EnergyCount()
    local timeStr = common:getElapsedTime().."_"..game.count50EnergyTime
    timeStr = common:encString(timeStr)
    cc.UserDefault:getInstance():setStringForKey(game.PLAYERID.."50EnergyCount",timeStr)
    cc.UserDefault:getInstance():flush()
end
function UserDefaultUtil:Get50EnergyCount()
    local timeStr = cc.UserDefault:getInstance():getStringForKey(game.PLAYERID.."50EnergyCount")
    -- print("UserDefaultUtil:Get50EnergyCount  "..timeStr)
    if timeStr=="" then
        return nil
    end
    timeStr = common:decString(timeStr)
    local timeTb = common:parseStrOnlyWithUnderline(timeStr)
    return tonumber(timeTb[1]),tonumber(timeTb[2])
end
-- 宝箱剩余时间倒计时
function UserDefaultUtil:SaveBoxLeftTime()
    local timeStr = common:getElapsedTime().."_"..game.boxLeftTime
    timeStr = common:encString(timeStr)
    cc.UserDefault:getInstance():setStringForKey(game.PLAYERID.."BoxLeftTime",timeStr)
    cc.UserDefault:getInstance():flush()
end
function UserDefaultUtil:GetBoxLeftTime()
    local timeStr = cc.UserDefault:getInstance():getStringForKey(game.PLAYERID.."BoxLeftTime")
    -- print("UserDefaultUtil:GetBoxLeftTime  "..timeStr)
    if timeStr=="" then
        return nil
    end
    timeStr = common:decString(timeStr)
    local timeTb = common:parseStrOnlyWithUnderline(timeStr)
    return tonumber(timeTb[1]),tonumber(timeTb[2])
end
-- 通关后记录当前关卡
function UserDefaultUtil:SaveNowMaxStage()
    local jsonStr = json.encode({user_stage={nowmaxstage=common:getNowMaxStage()}})
    common:javaSaveUserData(jsonStr)
    local _maxStage = common:encInt(common:getNowMaxStage()) 
    cc.UserDefault:getInstance():setIntegerForKey(game.PLAYERID.."NowMaxStage",_maxStage)
    cc.UserDefault:getInstance():flush()
end
function UserDefaultUtil:GetNowMaxStage()
    local stage = cc.UserDefault:getInstance():getIntegerForKey(game.PLAYERID.."NowMaxStage")
    -- print("UserDefaultUtil:GetNowMaxStage  "..stage)
    if stage==0 then
        return 0
    end
    stage = common:decInt(tonumber(stage))
    return tonumber(stage)
end

-- 记录关卡对应的星星数
function UserDefaultUtil:saveStageStars()
    local starsStr = common:table_to_string(game.stageStars)
    starsStr = common:encString(starsStr)
    cc.UserDefault:getInstance():setStringForKey(game.PLAYERID.."StageStars",starsStr)
    cc.UserDefault:getInstance():flush()
end
function UserDefaultUtil:getStageStars()
    local starsStr = cc.UserDefault:getInstance():getStringForKey(game.PLAYERID.."StageStars")
    -- print("UserDefaultUtil:getStageStars  "..starsStr)
    if starsStr=="" then
        return nil
    end
    starsStr = common:decString(starsStr)
    return common:string_to_table(starsStr)
end
-- 记录关卡对应的最高分
function UserDefaultUtil:saveStageMaxScore()
    local maxScoreStr = common:table_to_string(game.stageMaxScore)
    maxScoreStr = common:encString(maxScoreStr)
    cc.UserDefault:getInstance():setStringForKey(game.PLAYERID.."StageMaxScore",maxScoreStr)
    cc.UserDefault:getInstance():flush()
end
function UserDefaultUtil:getStageMaxScore()
    local maxScoreStr = cc.UserDefault:getInstance():getStringForKey(game.PLAYERID.."StageMaxScore")
    -- print("UserDefaultUtil:getStageMaxScore  "..maxScoreStr)
    if maxScoreStr=="" then
        return nil
    end
    maxScoreStr = common:decString(maxScoreStr)
    return common:string_to_table(maxScoreStr)
end

-- 未联网的时候缓存复活购买信息
function UserDefaultUtil:saveRecordRebirthBuy()
    local recordRebirthBuy = common:serialize(game.recordRebirthBuy)
    cc.UserDefault:getInstance():setStringForKey(game.PLAYERID.."RecordRebirthBuy",recordRebirthBuy)
    cc.UserDefault:getInstance():flush()
end
function UserDefaultUtil:getRecordRebirthBuy()
    local recordRebirthBuy = cc.UserDefault:getInstance():getStringForKey(game.PLAYERID.."RecordRebirthBuy")
    -- print("UserDefaultUtil:getRecordRebirthBuy  "..recordRebirthBuy)
    if recordRebirthBuy=="" then
        return nil
    end
    return common:unserialize(recordRebirthBuy)
end
-- 统计失败金币复活消耗金币
function UserDefaultUtil:recordRebirthCost( costNum )
    local _tb = {
        type=3,
        amount=costNum,
        leftcoin=game.myGold,
    }
    local jsonStr = json.encode({shop_buy=_tb})
    -- 如果没有有联网
    if network.getInternetConnectionStatus()==0 then
        table.insert(game.recordRebirthBuy,{shop_buy=_tb})
        self:saveRecordRebirthBuy()
    else
        common:javaSaveUserData(jsonStr)
        for i,v in ipairs(game.recordRebirthBuy) do
            local _jsonStr = json.encode(v)
            common:javaSaveUserData(_jsonStr)
        end
        game.recordRebirthBuy = {}
        self:saveRecordRebirthBuy()
    end
end

-- 记录帮手等级
function UserDefaultUtil:saveHelperLevel(helperNum,costNum)
    local _tb = {
        type=2,
        item=helperNum,
        level=game.helper[helperNum],
        amount=costNum~=nil and costNum or 0,
        leftcoin=game.myGold,
    }
    local jsonStr = json.encode({shop_buy=_tb})
    common:javaSaveUserData(jsonStr)

    local helperLevelStr = common:table_to_string(game.helper)
    helperLevelStr = common:encString(helperLevelStr)
    cc.UserDefault:getInstance():setStringForKey(game.PLAYERID.."HelperLevel",helperLevelStr)
    cc.UserDefault:getInstance():flush()
end
function UserDefaultUtil:getHelperLevel()
    local helperLevelStr = cc.UserDefault:getInstance():getStringForKey(game.PLAYERID.."HelperLevel")
    -- print("UserDefaultUtil:getHelperLevel  "..helperLevelStr)
    if helperLevelStr=="" then
        return nil
    end
    helperLevelStr = common:decString(helperLevelStr)
    return common:string_to_table(helperLevelStr)
end
-- 未联网的时候缓存伙伴使用记录
function UserDefaultUtil:saveRecordHeplerUse()
    local recordHelperUseStr = common:serialize(game.recordHelperUse)
    cc.UserDefault:getInstance():setStringForKey(game.PLAYERID.."RecordHelperUse",recordHelperUseStr)
    cc.UserDefault:getInstance():flush()
end
function UserDefaultUtil:getRecordHeplerUse()
    local recordHelperUseStr = cc.UserDefault:getInstance():getStringForKey(game.PLAYERID.."RecordHelperUse")
    -- print("UserDefaultUtil:getRecordHeplerUse  "..recordHelperUseStr)
    if recordHelperUseStr=="" then
        return nil
    end
    return common:unserialize(recordHelperUseStr)
end
-- 统计使用伙伴消耗
function UserDefaultUtil:recordHerlperUse( herlperTb,costTb )
    for i,v in ipairs(herlperTb) do
        local _tb = {
            type=1,
            item=v,
            amount=costTb[i],
            leftcoin=game.myGold
        }
        local jsonStr = json.encode({shop_buy=_tb})

        -- 如果没有有联网
        if network.getInternetConnectionStatus()==0 then
            table.insert(game.recordHelperUse,{shop_buy=_tb})
            self:saveRecordHeplerUse()
        else
            common:javaSaveUserData(jsonStr)
            for i,v in ipairs(game.recordHelperUse) do
                local _jsonStr = json.encode(v)
                common:javaSaveUserData(_jsonStr)
            end
            game.recordHelperUse = {}
            self:saveRecordHeplerUse()
        end
    end
end

-- 记录金币
function UserDefaultUtil:saveGold()
    local _myGold = common:encInt(game.myGold) 
    cc.UserDefault:getInstance():setIntegerForKey(game.PLAYERID.."Gold",_myGold)
    cc.UserDefault:getInstance():flush()
end
function UserDefaultUtil:getGold()
    local goldNum = cc.UserDefault:getInstance():getIntegerForKey(game.PLAYERID.."Gold")
    -- print("UserDefaultUtil:getGold  "..goldNum)
    if goldNum==0 then
        return 0
    end
    goldNum = common:decInt(tonumber(goldNum))
    return goldNum
end

-- 记录音乐
function UserDefaultUtil:saveMusic()
    if game.MusicOn==true then
        cc.UserDefault:getInstance():setIntegerForKey(game.PLAYERID.."Music",1)
    else
        cc.UserDefault:getInstance():setIntegerForKey(game.PLAYERID.."Music",2)
    end
    cc.UserDefault:getInstance():flush()
end
function UserDefaultUtil:getMusic()
    local musicOn = cc.UserDefault:getInstance():getIntegerForKey(game.PLAYERID.."Music")
    -- print("UserDefaultUtil:getMusic  "..musicOn)
    return musicOn
end
-- 记录音效
function UserDefaultUtil:saveSound()
    if game.SoundOn==true then
        cc.UserDefault:getInstance():setIntegerForKey(game.PLAYERID.."Sound",1)
    else
        cc.UserDefault:getInstance():setIntegerForKey(game.PLAYERID.."Sound",2)
    end
    cc.UserDefault:getInstance():flush()
end
function UserDefaultUtil:getSound()
    local soundOn = cc.UserDefault:getInstance():getIntegerForKey(game.PLAYERID.."Sound")
    -- print("UserDefaultUtil:getSound  "..soundOn)
    return soundOn
end
-- 记录船的等级
function UserDefaultUtil:saveShipLevel()
    local jsonStr = json.encode({user_ship_level={level=game.nowShipLevel,type=game.nowShip}})
    common:javaSaveUserData(jsonStr)

    local _shipLevel = common:encInt(game.nowShipLevel) 
    cc.UserDefault:getInstance():setIntegerForKey(game.PLAYERID.."ShipLevel",_shipLevel)
    cc.UserDefault:getInstance():flush()
end
function UserDefaultUtil:getShipLevel()
    local shipLevel = cc.UserDefault:getInstance():getIntegerForKey(game.PLAYERID.."ShipLevel")
    -- print("UserDefaultUtil:getShipLevel  "..shipLevel)
    if shipLevel==0 then
        return 0
    end
    shipLevel = common:decInt(tonumber(shipLevel))
    return shipLevel
end
-- 记录船的当前等级多出部分的经验
function UserDefaultUtil:saveShipExp()
    local _nowShipExp = common:encInt(game.nowShipExp) 
    cc.UserDefault:getInstance():setIntegerForKey(game.PLAYERID.."ShipExp",_nowShipExp)
    cc.UserDefault:getInstance():flush()
end
function UserDefaultUtil:getShipExp()
    local shipExp = cc.UserDefault:getInstance():getIntegerForKey(game.PLAYERID.."ShipExp")
    -- print("UserDefaultUtil:getShipExp  "..shipExp)
    if shipExp==0 then
        return 0
    end
    shipExp = common:decInt(tonumber(shipExp))
    return shipExp
end
-- 记录当前是2艘船中的哪艘船
function UserDefaultUtil:saveShipType()
    local _shipType = common:encInt(game.nowShip) 
    cc.UserDefault:getInstance():setIntegerForKey(game.PLAYERID.."ShipType",_shipType)
    cc.UserDefault:getInstance():flush()
end
function UserDefaultUtil:getShipType()
    local shipType = cc.UserDefault:getInstance():getIntegerForKey(game.PLAYERID.."ShipType")
    -- print(" test userdefault getShipType is  "..game.nowShip)
    if shipType==0 then
        return 0
    end
    shipType = common:decInt(tonumber(shipType))
    return shipType
end
-- 记录当前引导步数
function UserDefaultUtil:saveGuideStep()
    local _guideStep = common:encInt(game.guideStep) 
    cc.UserDefault:getInstance():setIntegerForKey(game.PLAYERID.."GuideStep",_guideStep)
    cc.UserDefault:getInstance():flush()
end
function UserDefaultUtil:getGuideStep()
    local guideStep = cc.UserDefault:getInstance():getIntegerForKey(game.PLAYERID.."GuideStep")
    -- print(" test userdefault getGuideStep is  "..game.guideStep)
    if guideStep==0 then
        return 0
    end
    guideStep = common:decInt(tonumber(guideStep))
    return guideStep
end
-- 记录当前是否第一次开始游戏
function UserDefaultUtil:saveFirstGame()
    if game.firstEnterGame==true then
        cc.UserDefault:getInstance():setIntegerForKey(game.PLAYERID.."FirstGame",1)
    else
        cc.UserDefault:getInstance():setIntegerForKey(game.PLAYERID.."FirstGame",2)
    end
    cc.UserDefault:getInstance():flush()
end
function UserDefaultUtil:getFirstGame()
    local firstGame = cc.UserDefault:getInstance():getIntegerForKey(game.PLAYERID.."FirstGame")
    -- print("UserDefaultUtil:getFirstGame  "..firstGame)
    return firstGame
end
-- 记录是否买过一元购
function UserDefaultUtil:saveOneYuan()
    if game.boughtOneYuan==true then
        cc.UserDefault:getInstance():setIntegerForKey(game.PLAYERID.."OneYuan",1)
    else
        cc.UserDefault:getInstance():setIntegerForKey(game.PLAYERID.."OneYuan",2)
    end
    cc.UserDefault:getInstance():flush()
end
function UserDefaultUtil:getOneYuan()
    local oneYuan = cc.UserDefault:getInstance():getIntegerForKey(game.PLAYERID.."OneYuan")
    -- print("UserDefaultUtil:getFirstGame  "..firstGame)
    return oneYuan
end

-- 缓存战斗结果信息
function UserDefaultUtil:saveRecordResult()
    local recordResult = common:serialize(game.recordResult)
    cc.UserDefault:getInstance():setStringForKey(game.PLAYERID.."RecordResult",recordResult)
    cc.UserDefault:getInstance():flush()
end
function UserDefaultUtil:getRecordResult()
    local recordResult = cc.UserDefault:getInstance():getStringForKey(game.PLAYERID.."RecordResult")
    -- print("UserDefaultUtil:getRecordResult  "..recordResult)
    if recordResult=="" then
        return nil
    end
    return common:unserialize(recordResult)
end
-- 战斗结果信息
function UserDefaultUtil:recordResult(_result,_stage,_rebirthtype)
    local _tb = {
        result=_result,
        nowstage=_stage,
        rebirthtype=_rebirthtype,
    }
    local jsonStr = json.encode({user_stage_result=_tb})
    -- 如果没有有联网
    if network.getInternetConnectionStatus()==0 then
        table.insert(game.recordResult,{user_stage_result=_tb})
        self:saveRecordResult()
    else
        common:javaSaveUserData(jsonStr)
        for i,v in ipairs(game.recordResult) do
            local _jsonStr = json.encode(v)
            common:javaSaveUserData(_jsonStr)
        end
        game.recordResult = {}
        self:saveRecordResult()
    end
end

function UserDefaultUtil:recordRecharge(_money,_channel,_status,_itemType)
    local _tb = {
        money=_money,
        leftcoin = game.myGold,
        leftenergy = game.myEnergy,
        channel=_channel,
        status=_status,
        itemtype=_itemType,
    }
    local jsonStr = json.encode({recharge=_tb})
    common:javaSaveUserData(jsonStr)
end

function UserDefaultUtil:recordCreateRole(roleName)
    local _tb = {
        username=roleName,
    }
    local jsonStr = json.encode({create_role=_tb})
    common:javaSaveUserData(jsonStr)
end