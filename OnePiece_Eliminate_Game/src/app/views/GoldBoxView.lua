----------------------------------------------------------------------------------
--[[
    FILE:           GoldBoxView.lua
    DESCRIPTION:    
    AUTHOR:         ZhaoLu
    CREATED:        2016-06-24 
--]]
----------------------------------------------------------------------------------
local GoldBoxView = class("GoldBoxView", function()
    return display.newNode()
end)

function GoldBoxView:ctor()

	self._mainNode = CsbContainer:createPushCsb("GoldBoxView.csb"):addTo(self)

    local getBtn = cc.uiloader:seekNodeByName(self._mainNode,"mGetBtn")
	CsbContainer:decorateBtn(getBtn,function()
        game.boxLeftTime = 3600*6
        UserDefaultUtil:SaveBoxLeftTime()
        game.myGold = game.myGold+1000
        sendMessage({msg="REFRESHGOLD"})
        sendMessage({msg="MapScene_CountBoxTime"})
		self:removeFromParent()
		self._mainNode = nil
	end)

    CsbContainer:setStringForLabel(self._mainNode, {mGoldLabel=1000})

end

return GoldBoxView