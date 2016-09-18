----------------------------------------------------------------------------------
--[[
    FILE:           common.lua
    DESCRIPTION:    游戏工具
    AUTHOR:         ZhaoLu
    CREATED:        2016-06-21
    DESCIBE:		为了减少全局方法函数，放一部分不需要经常调用的在common中
--]]
----------------------------------------------------------------------------------
require "bit"

local ENC_KEY = 18
local common = {}

function common:pointInCircle( circleRect,point )
    local _dis = cc.pGetDistance(cc.p(circleRect.centerX,circleRect.centerY),point)
    if _dis<circleRect.r then
        return true
    else
        return false
    end
end


function common:util_split(str, delim, maxNb)
    if string.find(str, delim) == nil then
        return {str}
    end
    if maxNb == nil or maxNb < 1 then
        maxNb = 0    -- No limit
    end
    local result = {}
    local pat = "(.-)" .. delim .. "()"
    local nb = 0
    local lastPos
    for part, pos in string.gfind(str, pat) do
        nb = nb + 1
        result[nb] = part
        lastPos = pos
        if nb == maxNb then break end
    end
    -- Handle the last field
    if nb ~= maxNb then
        result[nb + 1] = string.sub(str, lastPos)
    end
    return result;
end
-- added by zhaolu parse reward like (1_10,2_30)
function common:parseStrWithComma( str )
    local result = {}
    if str ~= nil then
        for _, item in ipairs(self:util_split(str, ",")) do
            local _id, _count = unpack(self:util_split(item, "_"));
            if _count~=nil and _id~=nil then
                table.insert(result, {
                    id      = tonumber(_id),
                    count   = tonumber(_count),
                })
            end
        end
    end
    return result
end

-- added by zhaolu parse sentence like (1_2_3)
function common:parseStrOnlyWithUnderline( cfgStr )
    if cfgStr==nil then return end
    local result = self:util_split(cfgStr, "_")
    return result
end
-- added by zhaolu parse sentence like (1,2,3)
function common:parseStrOnlyWithComma( cfgStr )
    if cfgStr==nil then return end
    local result = self:util_split(cfgStr, ",")
    return result
end

-- 给出概率table，根据概率取1 - #table
function common:getProbabilityWithTable(tb)
    local sum = 0
    for i,v in pairs(tb) do
        sum = sum+v
    end
    local num = math.random(sum)
    local randomSum = 0
    for i,v in pairs(tb) do
        randomSum = randomSum+v
        if num<=randomSum then
            -- print("getProbabilityWithTable num "..i)
            return tonumber(i)
        end
    end
    return 1
end

-- 格式化时间，如：1200 转换成20:00:00
function common:formatSecond( second )
    local h,m,s = 0,0,0
    h = math.floor(second/3600)
    m = math.floor((second - h*3600)/60)
    s = math.floor(second - h*3600 - m*60)
    return string.format("%02d:%02d:%02d",h,m,s)
end

-------------------table util---------------------
function common:is_table_same(tb_1,tb_2)
    for k, v in pairs(tb_1) do
        if v ~= tb_2[k] then
            return false
        end
    end
    for k, v in pairs(tb_2) do
        if v ~= tb_1[k] then
            return false
        end
    end
    return true
end

function common:table_has_value( tb,value )
    if type(value)=="table" then
        for k,v in pairs(tb) do
            if value[k]~=nil then
                return true
            end
        end
    else
        for k,v in pairs(tb) do
            if v==value then
                return true
            end
        end
    end
    return false
end

function common:table_del_repeat_value( tb )
    local tempT,_table = {},{}
    for k,v in pairs(tb) do
        tempT[v] = true
    end
    for k,v in pairs(tempT) do
        table.insert(_table,k)
    end
    return _table
end

function common:table_deep_copy( tb )
    local _tb = {}
    for k,v in pairs(tb) do
        _tb[k] = v
    end
    return _tb
end

function common:table_to_string( tb )
    local str = ""
    for k,v in pairs(tb) do
        str = str..k.."_"..v..","
    end
    return str
end

function common:string_to_table( str )
    local result = {}
    if str ~= nil then
        for _, child in ipairs(self:util_split(str, ",")) do
            local key, value = unpack(self:util_split(child, "_"));
            if key~=nil and value~=nil then
                result[tonumber(key)] = tonumber(value)
            end
        end
    end
    return result
end

function common:serialize(obj)  
    local lua = ""  
    local t = type(obj)  
    if t == "number" then  
        lua = lua .. obj  
    elseif t == "boolean" then  
        lua = lua .. tostring(obj)  
    elseif t == "string" then  
        lua = lua .. string.format("%q", obj)  
    elseif t == "table" then  
        lua = lua .. "{\n"  
        for k, v in pairs(obj) do  
            lua = lua .. "[" .. self:serialize(k) .. "]=" .. self:serialize(v) .. ",\n"  
        end  
        local metatable = getmetatable(obj)  
        if metatable ~= nil and type(metatable.__index) == "table" then  
            for k, v in pairs(metatable.__index) do  
                lua = lua .. "[" .. self:serialize(k) .. "]=" .. self:serialize(v) .. ",\n"  
            end  
        end  
        lua = lua .. "}"  
    elseif t == "nil" then  
        return nil  
    else  
        error("can not serialize a " .. t .. " type.")  
    end  
    return lua  
end  
  
function common:unserialize(lua)  
    local t = type(lua)  
    if t == "nil" or lua == "" then  
        return nil  
    elseif t == "number" or t == "string" or t == "boolean" then  
        lua = tostring(lua)  
    else  
        error("can not unserialize a " .. t .. " type.")  
    end  
    lua = "return " .. lua  
    local func = loadstring(lua)  
    if func == nil then  
        return nil  
    end  
    return func()  
end  
--------------- encrypt util ----------------------
function common:encInt(intValue)
    local _enc = bit.bxor(intValue,ENC_KEY)
    return _enc
end
function common:decInt(intValue)
    local _dec = bit.bxor(intValue,ENC_KEY)
    return _dec
end

function common:encString(stringValue)
    local _tb = {}
    for i=1,string.len(stringValue) do
        local _enc = bit.bxor(string.byte(stringValue,i),ENC_KEY)
        _tb[i] = _enc
    end
    return self:table_to_string(_tb)
end
function common:decString(stringValue)
    local _tb = self:string_to_table(stringValue)
    local _str = ""
    for i,v in ipairs(_tb) do
        local _dec = bit.bxor(v,ENC_KEY)
        _str = _str .. string.char(_dec)
    end
    return _str
end
--------------- 数学部分 ---------------------------------
-- 将num分成parts份，每份值随机，返回table
function common:random_divide_part( num,parts )
    local _tb,_sum = {},0
    local _basicNum = math.ceil(num/parts)
    for i=1,parts do
        local ranNum = math.random(1,4)
        if i==parts then
            table.insert(_tb,num-_sum)
            break
        end
        local _ran = 0
        if i%2==0 then
            _ran = _basicNum + ranNum
        else
            _ran = _basicNum - ranNum
        end
        table.insert(_tb,_ran)
        _sum = _sum + _ran
    end
    return _tb
end

--------------- 跟游戏逻辑有关的工具 ----------------------

-- 金币不足判断+金币消耗
function common:goldCost( needGoldNum )
    if game.myGold<needGoldNum then
        print("common:goldCost gold is not enough")
        return false
    else
        game.myGold = game.myGold - needGoldNum
        UserDefaultUtil:saveGold()
        -- 消耗金币音效
        GameUtil_PlaySound(GAME_SOUND.costCoin)
        return true
    end
end

-- 体力不足判断
function common:energyIsEnough( needEnergyNum )
    if game.myEnergy<needEnergyNum then
        print("common:energyIsEnough energy is not enough")
        return false
    else
        return true
    end
end
-- 消耗体力
function common:energyCost( needEnergyNum )
    if game.myEnergy<needEnergyNum then
        print("common:energyIsEnough energy is not enough")
    else
        game.myEnergy = game.myEnergy - needEnergyNum
        if game.myEnergy<50 then
            game.countTime = game.countTime + needEnergyNum*game.addOneEnergyTime
        end
        UserDefaultUtil:SaveEnergy()
    end
end
-- 获取当前最大关卡
function common:getNowMaxStage()
    if #game.stageStars>0 then
        if #game.stageStars<game.MAXSTAGE then
            return #game.stageStars+1
        else
            return #game.stageStars
        end
    end
    return 1
end

-- 获取当前体力显示内容
function common:getNowEnergyLabel()
    if game.myEnergy>5000 then
        return "永久无限"
    end
    return game.myEnergy.."/"..game.MAXENERGY
end

-- 更新版本号计算
function common:chageVersionStrToTb( versionStr )
    local _tb = {}
    local firstPoint = string.find(versionStr, "%.")
    local firstNum = string.sub(versionStr,1,firstPoint-1)
    table.insert(_tb,firstNum)
    local secondPoint = string.find(versionStr, "%.",firstPoint+1)
    local secondNum = string.sub(versionStr,firstPoint+1,secondPoint-1)
    table.insert(_tb,secondNum)
    local thirdNum = string.sub(versionStr,secondPoint+1,string.len(versionStr))
    table.insert(_tb,thirdNum)
    return _tb
end

--------------- 调用安卓方法 ----------------------
-- 错误代码    描述
-- -1  不支持的参数类型或返回值类型
-- -2  无效的签名
-- -3  没有找到指定的方法
-- -4  Java 方法执行时抛出了异常
-- -5  Java 虚拟机出错
-- -6  Java 虚拟机出错

-- 观看视频
function common:javaOnVideo(luaCallFunc)
    -- print("ccommon:javaOnVideo")
    -- luaCallFunc("success")
    -- 运营商的包直接成功
    if game.TOMOBILE == true then
        luaCallFunc("success")
        return
    end    

    -- 观看视频
    if device.platform == "android" then
        local args = {
            luaCallFunc,
        }
        local className = "org/cocos2dx/sdk/YoumiSDK"
        local ok,ret = luaj.callStaticMethod(className, "YoumiSDK_ShowVideo", args, "(I)V")
        print("YoumiSDK_ShowVideo")
        if not ok then
            print("YoumiSDK_ShowVideo error "..ret)
        end
    end
end

-- 获取开机时间
function common:getElapsedTime()
    if device.platform == "android" then
        local args = {}
        local className = "org/cocos2dx/sdk/EyeCat"
        local ok, _elapsedTime = luaj.callStaticMethod(className, "eye_getElapsedTime", args, "()Ljava/lang/String;")
        print("common:getElapsedTime():",_elapsedTime)
        if not ok then
            return os.time()
        else
            return math.ceil(tonumber(_elapsedTime)/1000)
        end
    elseif device.platform == "ios" then
        local args = {}
        local ok, _elapsedTime = luaoc.callStaticMethod("CatEye", "eye_getElapsedTime", args)
        print("common:getElapsedTime():",_elapsedTime)
        if not ok then
            return os.time()
        else
            return math.ceil(tonumber(_elapsedTime))
        end
    elseif device.platform == "windows" then
        return os.time()
    end
end

-- 保存统计计费点
function common:javaSaveUserData(jsonStr)
    if device.platform == "android" then
        local args = {
            jsonStr
        }
        local className = "org/cocos2dx/sdk/EyeCat"
        local ok,ret = luaj.callStaticMethod(className, "eye_saveUserData", args, "(Ljava/lang/String;)V")
        print("common:javaSaveUserData")
        if not ok then
            print("common:javaSaveUserData error "..ret)
        end
    elseif device.platform == "windows" then
        print("common:javaSaveUserData jsonStr "..jsonStr)
    end
end

-- 支付
function common:javaOnUseMoney(luaCallFunc,moneyCount)
	-- 运营商的包直接成功
    if game.TOMOBILE == true then
        luaCallFunc(moneyCount.."_2")
        return
    end    

    local args = {
        "jinbi",
        moneyCount,
        1,
        luaCallFunc,
        1,
    }
    print("common:javaOnUseMoney")
    if device.platform == "android" then
        -- Java 类的名称
        local className = "org/cocos2dx/sdk/EyeCat"
        -- 调用 Java 方法
        print("common:javaOnUseMoney android "..className)
        local ok, ret = luaj.callStaticMethod(className, "wxpee", args, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;II)V")
        if not ok then
            print("luaj error:", ret)
        else
            print("ret:", ret)
        end
    elseif device.platform == "ios" then
        -- appstore的商品ID
        local rmbCount = tonumber(moneyCount)/100
        local appStoreProductId = "com.cateyes.app.rmb"..rmbCount
        local args = {
            productId = appStoreProductId,
            callFunc = luaCallFunc,
            moneyCount = rmbCount,
        }
        local ok, ret = luaoc.callStaticMethod("CatEye", "eye_pay", args)
        print("common:javaOnUseMoney() ios :",ret)
        if not ok then
            print("luaoc error:", ret)
        end
    end
end
--------------- 跟网络有关的部分 --------------------------------


return common