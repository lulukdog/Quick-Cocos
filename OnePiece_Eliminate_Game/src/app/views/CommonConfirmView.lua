----------------------------------------------------------------------------------
--[[
    FILE:           CommonConfirmView.lua
    DESCRIPTION:    
    AUTHOR:         ZhaoLu
    CREATED:        2016-06-24 
--]]
----------------------------------------------------------------------------------
local CommonConfirmView = class("CommonConfirmView", function()
    return display.newNode()
end)

function CommonConfirmView:ctor(content,func)

	self._mainNode = CsbContainer:createPushCsb("CommonConfirmView.csb"):addTo(self)

    local closeBtn = cc.uiloader:seekNodeByName(self._mainNode,"mCloseBtn")
	CsbContainer:decorateBtn(closeBtn,function()
		self:removeFromParent()
		self._mainNode = nil
	end)

    local confirmBtn = cc.uiloader:seekNodeByName(self._mainNode,"mConfirmBtn")
    CsbContainer:decorateBtn(confirmBtn,function()
        func()
        self:removeFromParent()
        self._mainNode = nil
    end)

    CsbContainer:setStringForLabel(self._mainNode, {mContentLabel = content})

end

return CommonConfirmView