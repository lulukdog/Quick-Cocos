----------------------------------------------------------------------------------
--[[
    FILE:           RoleGetPushView.lua
    DESCRIPTION:    获得人物界面
    AUTHOR:         ZhaoLu
    CREATED:        2016-07-21 
--]]
----------------------------------------------------------------------------------
local helperCfg = require("data.data_helper")
local scheduler = require("framework.scheduler")

local RoleGetPushView = class("RoleGetPushView", function()
    return display.newNode()
end)

function RoleGetPushView:ctor(roleNum)

	self._mainNode = CsbContainer:createPushCsb("RoleGetPushView.csb"):addTo(self)

    print("RoleGetPushView:ctor")

    scheduler.performWithDelayGlobal(function()
        self:removeFromParent()
        self._mainNode = nil
    end,2)

    CsbContainer:setSpritesPic(self._mainNode, {
        mRoleSprite = helperCfg[roleNum].detailPic,
        mNameSprite = helperCfg[roleNum].wordPic,
    })

end

return RoleGetPushView