----------------------------------------------------------------------------------
--[[
    FILE:           MessageManager.lua
    DESCRIPTION:    消息传递
    AUTHOR:         ZhaoLu
    CREATED:        2016-06-06
--]]
----------------------------------------------------------------------------------

Msglisteners = {}
    
function addMessage(target,msg,backFunc)
    local msgObj = {body = target,func = backFunc}
    if Msglisteners[msg] == nil then
        Msglisteners[msg] = {}
    end
    if hasMessage(msg,backFunc) then
        return
    end
    table.insert(Msglisteners[msg], msgObj)
end
function sendMessage(data)
    -- body
    local msgs = Msglisteners[data.msg]
    if msgs == nil then
        return
    end
    for k,l in pairs(msgs) do
        local func = l["func"]
        local body = l["body"]
        func(body,data)
    end
end
function hasMessage(msg,func)
    -- body
    local msgs = Msglisteners[msg]
    for k,v in pairs(msgs) do
        if v["func"] == func then
            return true;
        end
    end
    return false
end
--[[
* [removeMessageByName 删除某个消息的所有事件]
* @param  {[type]} msgNa
* @return {[type]}
]]
function removeMessageByName(msgNa)
    -- body
    Msglisteners[msgNa] = nil
end
--[[
* [removeMessageByTarget 删除某个对象的所有事件]
* @param  {[type]} target
* @return {[type]}
]]
function removeMessageByTarget(target)
    -- body
    for i,j in pairs(Msglisteners) do
        for k,l in pairs(j) do        
            local tempTarget = l["body"]
            if tempTarget == target then
                table.remove(j, k)
            end
        end
    end
end
--[[
* [removeMessageFromTargetByName 删除某个对象的某个事件]
* @param  {[type]} target
* @param  {[type]} msg
* @return {[type]}
]]
function removeMessageFromTargetByName(target,msg)
    -- body
    local msgs = Msglisteners[msg]
    for k,v in pairs(msgs) do
        if v["body"] == target then
            table.remove(msgs, k)
        end
    end
end
function removeAllMessage( ... )
    -- body
    Msglisteners = {}
end