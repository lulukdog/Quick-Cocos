----------------------------------------------------------------------------------
--[[
    FILE:           UnlockConfirmView.lua
    DESCRIPTION:    
    AUTHOR:         ZhaoLu
    CREATED:        2016-06-24 
--]]
----------------------------------------------------------------------------------
local helperCfg = require("data.data_helper")

local UnlockConfirmView = class("UnlockConfirmView", function()
    return display.newNode()
end)

function UnlockConfirmView:ctor(btnNum)

	self._mainNode = CsbContainer:createPushCsb("UnlockConfirmView.csb"):addTo(self)

    CsbContainer:setStringForLabel(self._mainNode,{
        mNameLabel = helperCfg[btnNum].name,
    })

    local closeBtn = cc.uiloader:seekNodeByName(self._mainNode,"mCloseBtn")
	CsbContainer:decorateBtn(closeBtn,function()
		self:removeFromParent()
		self._mainNode = nil
	end)

    local confirmBtn = cc.uiloader:seekNodeByName(self._mainNode,"mConfirmBtn")
    CsbContainer:decorateBtnNoTrans(confirmBtn,function()
        -- TODO buy
        game.helper[btnNum] = 1
        UserDefaultUtil:saveHelperLevel()
        sendMessage({msg="UnlockRoleView_refreshUnlockNode"})
        sendMessage({msg="MapScene_RefreshPage"})
        self:removeFromParent()
        self._mainNode = nil
    end)

end

return UnlockConfirmView