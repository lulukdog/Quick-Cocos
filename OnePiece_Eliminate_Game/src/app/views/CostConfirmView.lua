----------------------------------------------------------------------------------
--[[
    FILE:           CostConfirmView.lua
    DESCRIPTION:    
    AUTHOR:         ZhaoLu
    CREATED:        2016-08-19 
--]]
----------------------------------------------------------------------------------
local CostConfirmView = class("CostConfirmView", function()
    return display.newNode()
end)

function CostConfirmView:ctor(content,func,costNum)

	self._mainNode = CsbContainer:createPushCsb("CostConfirmView.csb"):addTo(self)

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

    CsbContainer:setStringForLabel(self._mainNode, {
        mContentLabel = content,
        mCostLabel = costNum,
    })

end

return CostConfirmView