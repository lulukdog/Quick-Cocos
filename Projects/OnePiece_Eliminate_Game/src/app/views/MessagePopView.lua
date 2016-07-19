----------------------------------------------------------------------------------
--[[
    FILE:           MessagePopView.lua
    DESCRIPTION:    错误提示框
    AUTHOR:         ZhaoLu
    CREATED:        2016-06-27 
--]]
----------------------------------------------------------------------------------
local scheduler = require("framework.scheduler")
local errorCode = require("data.errorCode")

MessagePopView = class("MessagePopView", function()
    return display.newNode()
end)

function MessagePopView:ctor(msg)

	self._mainNode = CsbContainer:createPushCsb("MessagePopView.csb"):addTo(self)

    local _msg =""
    if type(msg)=="string" then
        _msg = msg
    elseif type(msg)=="number" then
        _msg = errorCode[msg]~=nil and errorCode[msg] or msg
    end
     
    CsbContainer:setStringForLabel(self._mainNode, {
        mStringLabel = _msg
    })

    self:runAction(cc.Sequence:create(
        cc.DelayTime:create(1),
        cc.CallFunc:create(function()
            self:removeFromParent()    
            self._mainNode = nil
        end)
    ))

end