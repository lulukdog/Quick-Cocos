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
    local timeStr = os.time().."_"..game.countTime.."_"..game.myEnergy
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

-- 通关后记录当前关卡
function UserDefaultUtil:SaveNowMaxStage()
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

-- 记录帮手等级
function UserDefaultUtil:saveHelperLevel()
    local helperLevelStr = common:table_to_string(game.helper)
    helperLevelStr = common:encString(helperLevelStr)
    cc.UserDefault:getInstance():setStringForKey(game.PLAYERID.."Helper",helperLevelStr)
    cc.UserDefault:getInstance():flush()
end
function UserDefaultUtil:getHelperLevel()
    local helperLevelStr = cc.UserDefault:getInstance():getStringForKey(game.PLAYERID.."Helper")
    -- print("UserDefaultUtil:getHelperLevel  "..helperLevelStr)
    if helperLevelStr=="" then
        return nil
    end
    helperLevelStr = common:decString(helperLevelStr)
    return common:string_to_table(helperLevelStr)
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